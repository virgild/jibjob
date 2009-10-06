# coding: utf-8

module JibJob
  module Helpers
    module ResumeHelper
      
      def resume_link(resume, format = :html)
        url = resume_url(resume, format)
        %Q(<a href="#{url}" rel="external">#{url}</a>)
      end
      
      def resume_url(resume, format = :html)
        format = 'html' if format.blank?
        port = (request.port == 80) ? nil : ":#{request.port}"        
        ext = ".#{format.to_s}"
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
      
      def check_resume_count_limit
        unless current_user.can_add_resume?
          redirect "/resumes"
        end
      end
      
      def has_public_access?(resume)
        resume.valid_access_cookie? request.cookies["jibjob.resume.#{resume.id}"], request.ip
      end
      
      def slugify(text)
        return "" if text.blank?
        str = text.strip
        if RUBY_VERSION.split('.')[1].to_i < 9
          str = Iconv.iconv('ascii//ignore//translit', 'utf-8', text).to_s
        end
        str.downcase!
        str.gsub! /<.*?>/, ''
        str.gsub! /[\'\"\#\$\,\.\!\?\%\@\(\)]+/, ''
        str.gsub! /\&/, 'and'
        str.gsub! /\_/, '-'
        str.gsub! /[\W^-_]+/, '-'
        str.gsub! /(\-)+/, '-'
        str
      end
      
      def unread_messages_count(subject)
        if subject.has_unread_messages?
          %{<span class="unread_count">#{subject.unread_messages_count}</span>}
        else
          ''
        end
      end
      
    end
  end
end