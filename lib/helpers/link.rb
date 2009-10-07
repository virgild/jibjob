# coding: utf-8

module JibJob
  module Helpers
    module LinkHelper

      def powered_link
        port = (request.port == 80) ? nil : ":#{request.port}"
        %Q(<a class="powered" href="#{home_url}"></a>)
      end
      
      def home_url
        port = (request.port == 80) ? nil : ":#{request.port}"
        %Q(#{request.scheme}://#{request.host}#{port})
      end

    end
  end
end
