Dir["#{File.dirname(__FILE__)}/helpers/*.rb"].each &method(:require)

module JibJob
  module Helpers
    include App
    include Haml
    include Resume
    include Debug
    include Rendering
    include Starters
    include Rack::Utils
    include Recaptcha::ClientHelper
    include Recaptcha::Verify
    alias :h :escape_html
  end
end