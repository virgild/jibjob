module JibJob
  module MailHelper
    
    def send_welcome_email(user)
      no_reply = options.noreply_email
      server_details = {
        :home_url => home_url
      }
      email_body = erb(:welcome_email, {}, :user => user, :server => server_details)
      
      Mail.deliver do
        to user.email
        from no_reply
        subject "Welcome to JibJob"
        body email_body
      end
    end
    
    def send_message_notification(message)
      no_reply = options.noreply_email
      server_details = {
        :home_url => home_url
      }
      resume = message.resume
      user = resume.user
      
      email_body = erb(:message_notification, {}, 
        :resume => resume, 
        :user => user, 
        :message => message, 
        :server => server_details)
      
      Mail.deliver do
        to user.email
        from no_reply
        subject "JibJob Message - #{resume.name}"
        body email_body
      end
    end
    
  end
end