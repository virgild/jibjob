ENV['RACK_ENV'] ||= 'test'

require 'rubygems'
require 'spec'
require 'spec/interop/test'

require File.join(File.dirname(__FILE__), "..", "app")
require File.join(File.dirname(__FILE__), "../lib/migrations")


# TestCase additions
class Test::Unit::TestCase
  
  def capture_stdout
    output = StringIO.new
    $stdout = output
    yield
    $stdout = STDOUT
    output
  end
  
  before(:each) do
    capture_stdout do
      JibJob::Migrations.migrate_up!
    end
  end
    
  after(:each) do
    capture_stdout do
      JibJob::Migrations.migrate_down!
    end
  end
  
end

# Configure app
JibJob::App.set :environment, :test
