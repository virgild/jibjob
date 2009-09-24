module JibJob
  module Helpers
    module Resume
      
      def resume_link(resume, format = :html)
        url = resume_url(resume, format)
        %Q(<a href="#{url}" rel="external">#{url}</a>)
      end
      
      def resume_url(resume, format = :html)
        format = 'html' if format.blank?
        port = (request.port == 80) ? nil : ":#{request.port}"        
        ext = (format.to_s == 'html') ? '' : ".#{format.to_s}"
        file = "#{h resume.slug}#{ext}"
        %Q(#{request.scheme}://#{request.host}#{port}/view/#{file})
      end
      
      def period_line(period)
        elements = Array.new
        elements << period.organization unless period.organization.blank?
        elements << period.location unless period.location.blank?
        if !period.dtstart.blank? && !period.dtend.blank?
          date = " (#{period.dtstart} - #{period.dtend})"
        elsif !period.dtstart.blank? || !period.dtend.blank?
          value = period.dtstart.blank? ? period.dtend : period.dtstart
          date = " (#{value})"
        else
          date = ''
        end
        elements.join(", ").concat("#{date}")
      end
      
      def has_public_access?(resume)
        resume.valid_access_cookie? request.cookies["jibjob.resume.#{resume.slug}"], request.ip
      end
      
    end
  end
end