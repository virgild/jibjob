# coding: utf-8

# General app helpers
module JibJob
  module Helpers
    module AppHelper
      
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
      
      def error_messages_for(subject)
        haml(:complaints, :layout => false, :locals => { :subject => subject })
      end
      
      def google_analytics
        unless options.google_analytics_id.blank?
          gastr = <<-SCRIPT
            <script type="text/javascript">
            var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
            document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
            </script>
            <script type="text/javascript">
            try {
            var pageTracker = _gat._getTracker("#{options.google_analytics_id}");
            pageTracker._trackPageview();
            } catch(err) {}</script>
          SCRIPT
        end
      end
            
    end #App
  end #Helpers
end #JibJob
