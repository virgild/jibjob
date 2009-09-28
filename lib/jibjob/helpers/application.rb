# General app helpers
module JibJob
  module Helpers
    module App
      
      def login_required
        if session[:user]
          return true
        else
          session[:return_to] = request.fullpath
          redirect '/login'
          return false
        end
      end
      
      def require_user
        login_required
      end

      def current_user
        return @current_user if @current_user
        if session[:user]
          @current_user = User.first(:username => session[:user])
        end
        @current_user
      end

      def redirect_to_stored
        if return_to = session[:return_to]
          session[:return_to] = nil
          redirect return_to
        else
          redirect '/'
        end
      end
      
      def check_resume_count_limit
        unless current_user.can_add_resume?
          redirect "/resumes"
        end
      end
      
      def slugify(text)
        return "" if text.blank?
        str = Iconv.iconv('ascii//ignore//translit', 'utf-8', text).to_s
        str.downcase!
        str.gsub! /<.*?>/, ''
        str.gsub! /[\'\"\#\$\,\.\!\?\%\@\(\)]+/, ''
        str.gsub! /\&/, 'and'
        str.gsub! /\_/, '-'
        str.gsub! /[\W^-_]+/, '-'
        str.gsub! /(\-)+/, '-'
        str
      end
      
      def write_welcome_cookie
        response.set_cookie("jibjob.welcome", :domain => options.cookie_domain, 
          :path => "/", 
          :value => "1", 
          :expires => Time.now + (60 * 5),
          :secure => false, 
          :httponly => true)
      end
      
      def write_public_view_cookie(resume)
        response.set_cookie("jibjob.resume.#{resume.slug}",
          :domain => options.cookie_domain,
          :path => "/",
          :value => resume.generate_access_cookie(request.ip),
          :expires => Time.now + 3600,
          :secure => false,
          :httponly => true)
      end
      
      def error_messages_for(subject)
        haml(:complaints, :layout => false, :locals => { :subject => subject })
      end
      
      def send_welcome_email(user)
        body = erb(:welcome_email, {}, :user => user)
        Pony.mail(:to => user.email, :from => JibJob::App.noreply_email, 
          :subject => "Welcome to JibJob", :body => body, :via => :sendmail)
      end
      
      def unread_messages_count(resume)
        if resume.has_unread_messages?
          %{<span class="unread_count">#{resume.unread_messages_count}</span>}
        else
          ''
        end
      end
      
    end #App
  end #Helpers
end #JibJob
