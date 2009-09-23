Dir["#{File.dirname(__FILE__)}/helpers/*.rb"].each &method(:require)

module JibJob
  module Helpers
    include App
    include Haml
    include Resume
    include Debug
    include Rendering
    include Form
    include Starters
    include Rack::Utils
    alias :h :escape_html
  end
end