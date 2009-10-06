module JibJob
  module CookieHelper
    
    def write_welcome_cookie
      response.set_cookie("jibjob.welcome",
        :path => "/", 
        :value => "1", 
        :expires => Time.now + (60 * 5),
        :secure => false, 
        :httponly => true)
    end
    
    def write_public_view_cookie(resume)
      response.set_cookie("jibjob.resume.#{resume.id}",
        :path => "/",
        :value => resume.generate_access_cookie(request.ip),
        :expires => Time.now + 3600 * 24,
        :secure => false,
        :httponly => true)
    end
    
  end
end