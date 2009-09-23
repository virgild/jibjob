require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

require 'rack/test'
require 'webrat'
require 'webrat/rack'
require 'webrat/sinatra'

Webrat.configure do |c|
  c.mode = :rack
  c.application_framework = :sinatra
end

describe JibJob::App do

  def session
    last_request.env['rack.session']
  end

  def create_valid_user
    @user = JibJob::User.create!(:username => "tester", :password => "secret", 
      :password_confirmation => "secret", :agreed_terms => "on", :email => "tester@local")
  end
  
  before(:all) do
    @browser = Rack::Test::Session.new(Rack::MockSession.new(JibJob::App))
    @b = @browser
  end
  
  def login
    @b.get "/login"
    @b.last_response.should be_ok
    
    @b.post "/login", { :username => @user.username, :password => "secret" }
    @b.follow_redirect!
    @b.last_request.url.should == "http://example.org/resumes"
  end

  def location
    @b.last_request.url.gsub(/^http:\/\/example.org/, '')
  end
  
  def status
    @b.last_response.status
  end
  
  def get(uri, data={}, env={}, &block)
    @b.get(uri, data, env, &block)
  end
  
  def logged_in_user_get(uri, data={}, env={}, &block)
    @b.get(uri, data, env.merge('rack.session' => { :user => @user.username }), &block)
  end
  
  def post(uri, data={}, env={}, &block)
    @b.post(uri, data, env, &block)
  end
  
  def logged_in_user_post(uri, data={}, env={}, &block)
    @b.post(uri, data, env.merge('rack.session' => { :user => @user.username }), &block)
  end
  
  def follow_redirect!
    @b.follow_redirect!
  end

  describe "Static pages" do
    it "should show the home page" do
      get "/"
      location.should == "/"
    end
  end
  
  describe "Login as user" do
    it "should login" do
      create_valid_user
      login
      
      logged_in_user_get "/resumes"
      location.should == "/resumes"
    end
    
    it "should show login page on non-auth access" do
      create_valid_user
      
      get "/resumes"
      follow_redirect!
      location.should == "/login"
    end
    
    it "should not login on invalid account" do
      get "/login"
      status.should == 200
      
      post "/login", { :username => "false_username", :password => "incorrect" }
      status.should == 200
      location.should == "/login"
    end
    
    it "should log out" do
      create_valid_user
      login
      logged_in_user_get "/logout"
      status.should == 302
      follow_redirect!
      location.should == "/"
    end
  end
  
  describe "user registration" do
    it "should show the registration page" do
      get "/register"
      status.should == 200
    end
    
    it "should register valid form" do
      get "/register"
      status.should == 200
      
      form_data = {
        "user[username]" => "test_user",
        "user[password]" => "secret",
        "user[password_confirmation]" => "secret",
        "user[agreed_terms]" => "on",
        "user[email]" => "tester@local"
      }
      post "/register", form_data
      follow_redirect!
      location.should == "/welcome"
    end
    
    it "should not register invalid form" do
      get "/register"
      status.should == 200
      
      form_data = {
        "user[username]" => "",
        "user[password]" => "secret",
        "user[password_confirmation]" => "secret",
        "user[agreed_terms]" => "on",
        "user[email]" => "tester@local"
      }
      post "/register", form_data
      status.should == 200
      location.should == "/register"
    end
    
    it "should not display registration page when user is logged in" do
      create_valid_user
      login
      
      get "/register", {}, 'rack.session' => { :user => "tester" }
      follow_redirect!
      location.should == "/"
    end
  end
  
  describe "resume" do
    before do
      create_valid_user
    end
    
    it "should create a resume on valid data" do
      logged_in_user_get "/resumes/new"

      form = {
        :resume => {
          :name => "Test Resume",
          :slug => "test-resume",
          :content => "#N Test User"
        }
      }
      
      logged_in_user_post "/resumes", form
      status.should == 302
      location.should == "/resumes"
    end
    
    it "should not create a resume on invalid data"
    
    it "should edit resume" do
      logged_in_user_get "/resumes/new"
      form = {
        :resume => {
          :name => "Test Resume",
          :slug => "test-resume",
          :content => "#N Test User"
        }
      }
      
      logged_in_user_post "/resumes", form
      status.should == 302
      location.should == "/resumes"
    end
  end
  
end
