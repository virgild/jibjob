# coding: utf-8

RACK_ENV = ENV["RACK_ENV"] ||= "development" unless defined? RACK_ENV
ROOT_DIR = $0 unless defined? ROOT_DIR

require 'rubygems'

gems = [
  ['extlib', '>= 0.9.13'],
  ['nakajima-rack-flash', '>= 0.1.0'],
  ['haml', '>= 2.2.4'],
  ['bcrypt-ruby', '>= 2.1.2'],
  ['uuidtools', '>= 2.0.0'],
  ['resumetools', '>= 0.2.7.1'],
  ['dm-core', '>= 0.10.1'],
  ['dm-timestamps', '>= 0.10.1'],
  ['dm-aggregates', '>= 0.10.1'],
  ['dm-constraints', '>= 0.10.1'],
  ['dm-validations', '>= 0.10.1'],
  ['sanitize', '>= 1.0.8.4'],
  ['sinatra', '>= 0.10.1']
]

gems.each do |name, version|
  if File.directory?(File.expand_path(File.dirname(__FILE__) + "/vendor/#{name}"))
    $:.unshift "#{File.dirname(__FILE__)}/vendor/#{name}/lib"
    require name
  else
    if version
      gem name, version
    else
      gem name
    end
  end
end

require 'extlib'
require 'iconv'
require 'sinatra/base'
require 'rack/flash'
require 'haml'
require 'sass'
require 'bcrypt'
require 'uuidtools'
require 'resumetools'
require 'net/http'
require 'cgi'
require 'sanitize'

require 'dm-core'
require 'dm-timestamps'
require 'dm-aggregates'
require 'dm-constraints'
require 'dm-validations'


dir = Pathname(__FILE__).dirname.expand_path

require dir / 'lib' / 'user'
require dir / 'lib' / 'resume'
require dir / 'lib' / 'message'
require dir / 'lib' / 'helpers'
require dir / 'lib' / 'mail'


def root_path(*args)
  File.join(ROOT_DIR, *args)
end

module JibJob
  class App < Sinatra::Base
    @@_app_config = YAML.load_file(File.expand_path("#{File.dirname(__FILE__)}/config.yml")).freeze
    
    # Default config
    set :app_file, __FILE__
    set :root, File.dirname(__FILE__)
    set :views, Proc.new { File.join(File.dirname(__FILE__), "lib/views") }
    enable :methodoverride
    set :cookie_secret, Proc.new { @@_app_config[environment][:cookie_secret] }
    set :noreply_email, Proc.new { @@_app_config[environment][:email][:noreply] }
    set :email_server, Proc.new { @@_app_config[environment][:email][:server] }
    set :recaptcha_pubkey, Proc.new { @@_app_config[environment][:recaptcha][:public_key] }
    set :recaptcha_privkey, Proc.new { @@_app_config[environment][:recaptcha][:private_key] }
    set :google_analytics_id, Proc.new { @@_app_config[environment][:google_analytics_id] }
    
    db_config = @@_app_config[environment][:db]
    
    if environment == :development
      #DataMapper::Logger.new(STDOUT, :debug)
    end
    DataMapper.setup(:default, db_config)
    
    # Production config
    configure :production do      
      error do
        "Application Error: Something went wrong"
      end
    end
    
    # Development config
    configure :development do
      require 'ruby-debug'
      require 'lib/reloader'
      
      enable :static
      set :public, Proc.new { File.join(root, "static") }
      use JibJob::Reloader, self
    end
    
    # Test config
    configure :test do
      # There is no Rack::Flash in testing, so do not test flash
      # in controllers and views yet
      def flash
        {}
      end
    end
    
    # Helpers
    helpers JibJob::Helpers

    # Racks
    configure :development, :production do
      use Rack::Session::Cookie, :key => "jibjob.session",
                                 :httponly => true,
                                 :path => "/",
                                 :expire_after => 3600 * 24,
                                 :secret => self.cookie_secret
      use Rack::Flash
    end
    
    # SMTP server
    smtp_server = self.email_server
    Mail.defaults do
      smtp smtp_server
      disable_tls
    end

    # Before filter
    before do
    end
    
    # 404 Handler
    not_found do
      haml :"404"
    end
    
    # Stylesheet
    get '/css/main.css' do
      content_type "text/css; utf-8"
      last_modified(File.stat(File.join(options.views, "main.sass")).mtime)
      etag ::Digest::MD5.file(options.views + "/main.sass").hexdigest
      sass :main
    end

    # Home page
    ['/', '/home/?'].each do |path|
      get path do
        haml :home
      end
    end

    # Login
    get '/login/?' do
      show :login, :locals => { :username => params[:username] }
    end
    
    post '/login/?' do
      user = User.authenticate(params[:username], params[:password])
      if user
        session[:user] = user.username
        if session[:return_to]
          return redirect_to_stored
        else
          return redirect("/resumes")
        end
      end
      flash.now[:login_notice] = "Invalid username/password"
      show :login, :locals => { :username => params[:username] }
    end
    
    # Logout
    get '/logout/?' do
      return redirect("/") unless current_user
      session[:user] = nil
      session.clear
      redirect "/"
    end
    
    # Welcome
    get '/welcome/?' do
      if request.cookies['jibjob.welcome']
        show :welcome
      else
        status 404
      end
    end

    # About
    get '/about/?' do
      show :about
    end
    
    get '/terms/?' do
      show :terms
    end
    
    get '/privacy/?' do
      show :privacy
    end
    
    get '/help/resume' do
      show :"resume_help"
    end

    # Register user
    get '/signup' do
      @user = JibJob::User.new
      show :register
    end
    
    post '/signup' do
      @user = User.new(params[:user])
                  
      if verify_recaptcha()
        if @user.save
          send_welcome_email(@user) if (self.class.environment == :production)
          write_welcome_cookie
          session[:user] = @user.username
          return redirect("/welcome")
        end
      else
        @user.valid?
        @user.errors.add :human_check, "You must type the two words below correctly"
      end

      show :register
    end
    
    # Resumes - list
    get '/resumes/?' do
      require_user
      show :"resumes/list"
    end

    # Resumes - new form
    get '/resumes/new/?' do
      require_user
      check_resume_count_limit    
      @resume = current_user.resumes.new(:content => resume_starter)
      show :"resumes/new"
    end
    
    # Resumes - create
    post '/resumes/?' do
      require_user
      check_resume_count_limit

      @resume = current_user.resumes.new
      @resume.name = Sanitize.clean(h params[:resume][:name])
      @resume.slug = slugify(Sanitize.clean(h params[:resume][:slug]))
      @resume.access_code = Sanitize.clean(h params[:resume][:access_code])
      @resume.content = params[:resume][:content]
      
      if @resume.save
        return redirect("/resumes")
      end    
      show :"resumes/new"
    end

    # Resumes - edit resume
    get '/resumes/:id/edit/?' do
      require_user
      @resume = current_user.resumes.get(params[:id])
      show :"resumes/edit"
    end

    # Resumes - zipped pdf
    get '/resumes/:id.pdf.zip' do
      require_user
      @resume = current_user.resumes.get(params[:id])
      pdf = @resume.data.render_pdf

      tmpfile = Tempfile.new("jibjob.pdf")
      tmpfile << pdf
      tmpfile.close

      zip_filename = File.join(File.dirname(__FILE__), "zips", "#{@resume.id}.zip")
      File.delete zip_filename if File.exists? zip_filename

      Zip::ZipFile.open(zip_filename, Zip::ZipFile::CREATE) do |zipfile|      
        zipfile.add("#{@resume.name}.pdf", tmpfile.path)
      end
      tmpfile.unlink

      zip = File.read(zip_filename)

      download_name = @resume.name.snake_case
      headers["Content-Disposition"] = "attachment; filename=#{download_name}.zip"
      content_type("application/zip")
      body(zip)
    end

    # Resume - get resume
    get '/resumes/:id.:format' do |resume_id, format|
      require_user
      @resume = current_user.resumes.get(params[:id])
      
      case format
      when 'html'
        return show(:"resumes/show")
      when 'pdf'
        content_type "application/pdf"
        return body(@resume.render_pdf)
      when 'txt'
        content_type "text/plain"
        return body(@resume.render_text)
      when 'json'
        content_type "application/json"
        return body(@resume.render_json)
      when 'resume'
        content_type "text/plain"
        return body(@resume.data.export)
      end
      status 404
      ""
    end

    # Resumes - update resume
    put '/resumes/:id/?' do
      require_user
      @resume = current_user.resumes.get(params[:id])
      
      @resume.name = Sanitize.clean(h params[:resume][:name])
      @resume.slug = slugify(Sanitize.clean(h params[:resume][:slug]))
      @resume.access_code = Sanitize.clean(h params[:resume][:access_code])
      @resume.content = params[:resume][:content]
      
      if @resume.save
        flash.now[:notice] = "Resume saved"
      end
      
      show :"resumes/edit"
    end

    # Resumes - delete
    get '/resumes/:id/delete/?' do
      require_user
      @resume = current_user.resumes.get(params[:id])
      show :"resumes/delete"
    end

    delete '/resumes/:id/?' do
      require_user
      @resume = current_user.resumes.get(params[:id])
      @resume.destroy
      redirect "/resumes"
    end
    
    # Resumes - list messages
    get '/resumes/:id/messages' do
      require_user
      @resume = current_user.resumes.get(params[:id])
      @messages = @resume.messages(:order => [:created_at.desc])
      show :"resumes/messages"
    end
    
    # Resume - write message
    post '/resumes/:id/messages' do |resume_id|
      @resume = Resume.get(resume_id)
      if @resume.nil?
        status 404
        return "NOT FOUND"
      end
      
      msg = @resume.messages.new
      msg.from = Sanitize.clean(params[:message][:from])
      msg.subject = Sanitize.clean(params[:message][:subject])
      msg.email = Sanitize.clean(params[:message][:email])
      msg.body = Sanitize.clean(params[:message][:body])
      
      if msg.save
        send_message_notification(msg)
        "OK".to_json
      else
        status 409
        content_type "text/html"
        haml :"resumes/message_errors", :layout => false, :locals => { :message => msg }
      end
    end
    
    # Resume - get message
    get '/resumes/:resume_id/messages/:message_id' do |resume_id, message_id|
      require_user
      @resume = current_user.resumes.get(resume_id)
      @message = @resume.messages.get(message_id)
      
      @message.mark_as_read!
      
      show :"resumes/message"
    end
    
    # Resume - delete message
    delete '/resumes/:resume_id/messages/:message_id' do |resume_id, message_id|
      require_user
      @resume = current_user.resumes.get(resume_id)
      @message = @resume.messages.get(message_id)
      
      if @message.destroy
        "OK"
      else
        status 409
        "ERROR"
      end      
    end
    
    get %r{/view/([\w-]+)$} do |slug|
      return redirect("/view/#{slug}.html")
    end
    
    # GET - resume public view
    get '/view/:slug.:format' do |slug, format|
      @resume = Resume.first(:slug => slug)
      
      if @resume.nil?
        status 404
        return
      end
      
      unless has_public_access?(@resume)
        return redirect("/access/#{slug}.#{format}")
      end
      
      write_public_view_cookie(@resume)
      
      case format
        when 'pdf'
          content_type "application/pdf"
          return body(@resume.render_pdf)
        when 'txt'
          content_type "text/plain"
          return body(@resume.render_text)
        when 'json'
          content_type "application/json"
          return body(@resume.render_json)
        when 'html'
          @title = @resume.data.full_name
          show :"resumes/public_show", :layout => :"layouts/public_layout", :locals => { :resume => @resume.data }
        else
          status 404
      end
    end

    # Resume access form
    get '/access/:slug.:format' do |slug, format|
      @resume = Resume.first(:slug => slug)
      if @resume.nil?
        status 404
        return
      end
      
      format = :html if format.blank?
      
      if has_public_access?(@resume)
        return redirect(resume_url(@resume, format))
      end
      
      @format = format
      show :"resumes/access", :layout => :"layouts/public_layout"
    end

    # Resume submit access code form
    post '/access/:slug.:format' do |slug, format|
      @resume = Resume.first(:slug => slug)
      if @resume.nil?
        status 404
        return
      end
      
      @format = format
      
      if has_public_access?(@resume)
        return redirect(resume_url(@resume, format))
      end
      
      if !@resume.requires_access_code? || params[:access_code] == @resume.access_code
        if verify_recaptcha()
          write_public_view_cookie @resume
          return redirect(resume_url(@resume,format))
        else
          flash.now[:access_recaptcha_error] = true
        end
      else
        flash.now[:access_code_error] = true
      end
      
      show :"resumes/access", :layout => :"layouts/public_layout"
    end
    
    # Account
    get '/account/?' do
      require_user
      show :"account/edit"
    end
  
    # Account update e-mail
    put '/account/email/?' do
      require_user
      current_user.email = params[:user][:email]
      if current_user.save
        flash.now[:notice] = "E-mail updated"
      end
      show :"account/edit"
    end
    
    # Account update password
    put '/account/password/?' do
      require_user
      current_user.password = params[:user][:password]
      current_user.password_confirmation = params[:user][:password_confirmation]
      if current_user.save
        flash.now[:notice] = "Password updated"
      end
      show :"account/edit"
    end
    
    # Message dialog
    get '/message/:slug' do |slug|
      @resume = Resume.first(:slug => slug)
      if @resume.nil?
        status 404
        return
      end
      show :"resumes/message_dialog", :layout => false
    end

  end #class App < Sinatra::Base
end #module JibJob
