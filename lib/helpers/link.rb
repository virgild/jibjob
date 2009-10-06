# coding: utf-8

module JibJob
  module Helpers
    module LinkHelper

      def powered_link
        port = (request.port == 80) ? nil : ":#{request.port}"
        %Q(<a class="powered" href="#{request.scheme}://#{request.host}#{port}"></a>)
      end

    end
  end
end
