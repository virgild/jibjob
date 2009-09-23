require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe "User and Resume constraints" do
  before do
    @user_attributes = {
      :username => "tester",
      :email => "tester@jibjob.local",
      :password => "secret",
      :password_confirmation => "secret",
      :agreed_terms => "on"
    }
    @resume_attributes = {
      :name => "Test Resume",
      :slug => "test-resume",
      :content => "#N Mister Tester"
    }
  end
  
  it "should destroy associated resumes when a user is destroyed" do
    user = JibJob::User.create(@user_attributes)
    resume = user.resumes.create(@resume_attributes)
    resume.should_not be_new
    
    assert user.destroy
    JibJob::User.get(user.id).should be_nil
    JibJob::Resume.get(resume.id).should be_nil
  end
  
end