dir = Pathname(__FILE__).dirname.expand_path

require dir / 'core_ext' / 'object'
require dir / 'user'
require dir / 'resume'
require dir / 'helpers'


class Sinatra::Reloader < Rack::Reloader
  def safe_load(file, mtime, stderr=$stderr)
    if file == __FILE__
      ::JibJob::App.reset!
    end
    super
  end
end

module JibJob
  class App < Sinatra::Base
    @@_app_config = YAML.load_file(File.expand_path("#{File.dirname(__FILE__)}/../../config.yml")).freeze
    
    # Default config
    set :app_file, __FILE__
    set :root, File.dirname(__FILE__) + "/../.."
    set :views, Proc.new { File.join(File.dirname(__FILE__), "views") }
    enable :methodoverride, :logging
    set :cookie_domain, Proc.new { @@_app_config[environment][:cookie_domain] }
    set :cookie_secret, Proc.new { @@_app_config[environment][:cookie_secret] }
    set :noreply_email, Proc.new { @@_app_config[environment][:email][:noreply] }
    
    db_config = @@_app_config[environment][:db]
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
      
      enable :show_exceptions, :static, :dump_errors
      set :public, Proc.new { File.join(root, "static") }
      use Sinatra::Reloader, 0
      use Rack::Lint    
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
                                 :domain => self.cookie_domain,
                                 :path => "/",
                                 :expire_after => 3600,
                                 :secret => self.cookie_secret
      use Rack::Flash
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
      flash[:login_notice] = "Invalid username/password"
      show :login, :locals => { :username => params[:username] }
    end
    
    # Logout
    get '/logout/?' do
      return redirect("/") unless current_user
      session[:user] = nil
      flash[:notice] = "You have successfully logged out."
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

    # Register user
    get '/register' do
      @user = JibJob::User.new
      show :register
    end
    
    post '/register' do      
      @user = User.new(params[:user])
      
      if @user.save
        send_welcome_email(@user)
        write_welcome_cookie
        return redirect("/welcome")
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
      slug = slugify(params[:resume][:slug])
      @resume = current_user.resumes.new(params[:resume])
      @resume.slug = slug
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
      end
      status 404
      ""
    end

    # Resumes - update resume
    put '/resumes/:id/?' do
      require_user
      @resume = current_user.resumes.get(params[:id])

      @resume.name = params[:resume][:name]
      @resume.slug = slugify(params[:resume][:slug])
      @resume.content = params[:resume][:content]
      @resume.access_code = params[:resume][:access_code]
      
      if @resume.save
        return redirect("/resumes")
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

    # GET - resume public view
    get %r{/view/([\w-]+)(\.(\w+))?} do |slug, ext, format|
      @resume = Resume.first(:slug => slug)
      
      if @resume.nil?
        status 404
        return
      end
      
      format ||= 'html'
      
      unless has_public_access?(@resume)
        return redirect("/access/#{slug}.#{format}")
      end
      
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
          show :"resumes/public_show", :layout => :"layouts/public_view", :locals => { :resume => @resume.data }
        else
          status 404
      end
    end
        
    # Resume access form
    get '/access/:slug.:format/?' do |slug, format|
      @resume = Resume.first(:slug => slug)
      if @resume.nil?
        status 404
        return
      end
      @format = format
      show :"resumes/access", :layout => :"layouts/public_view"
    end

    # Resume submit access code form
    post '/access/:slug/?' do |slug|
      @resume = Resume.first(:slug => slug)
      if @resume.nil?
        status 404
        return
      end
      
      format = params[:format]
      
      if @resume.access_code == params[:access_code]
        return redirect("/view/#{slug}.#{format}?c=#{@resume.access_code}")
      end
      
      show :"resumes/access", :layout => :"layouts/public_view"
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

  end #class App < Sinatra::Base
end #module JibJob
