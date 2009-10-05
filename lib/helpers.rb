require File.join(File.dirname(__FILE__), "helpers/application")
require File.join(File.dirname(__FILE__), "helpers/haml")
require File.join(File.dirname(__FILE__), "helpers/rendering")
require File.join(File.dirname(__FILE__), "helpers/resume")
require File.join(File.dirname(__FILE__), "helpers/starters")
require File.join(File.dirname(__FILE__), "helpers/recaptcha")

module JibJob
  module Helpers
    include AppHelper
    include HamlHelper
    include ResumeHelper
    include RenderingHelper
    include StarterHelper
    include Rack::Utils
    include Recaptcha::ClientHelper
    include Recaptcha::Verify
    alias :h :escape_html
  end
end