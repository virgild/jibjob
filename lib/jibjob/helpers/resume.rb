module JibJob
  module Helpers
    module Resume
      
      def resume_link(resume)
        port = (request.port == 80) ? nil : ":#{request.port}"
        url = %Q(#{request.scheme}://#{request.host}#{port}/view/#{h resume.slug})
        %Q(<a href="#{url}">#{url}</a>)
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
        return true if (!resume.requires_access_code? || (params[:c] == resume.access_code))
        false
      end
      
    end
  end
end