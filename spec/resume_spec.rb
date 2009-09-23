require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe JibJob::Resume do
  
  before do
    @user = JibJob::User.create!({
      :username => "tester",
      :password => "secret",
      :email => "tester@jibjob.local"
    })
    
    @valid_attributes = {
      :name => "Test Resume",
      :content => "#N Test User",
      :slug => "test-resume"
    }
  end
  
  describe "creation" do
    it "should be created with valid attributes" do
      resume = @user.resumes.create(@valid_attributes)
      resume.should be_valid
    end
  end

  describe "requirements" do
    it "should be invalid without a name" do
      resume = @user.resumes.new(@valid_attributes)
      resume.name = nil
      resume.should_not be_valid
      resume.errors[:name].should include("A name is required")
      resume.name = ""
      resume.should_not be_valid
      resume.errors[:name].should include("A name is required")
    end

    it "should be invalid without a slug" do
      resume = @user.resumes.new(@valid_attributes)
      resume.slug = nil
      resume.should_not be_valid
      resume.errors[:slug].should include("A friendly name is required")
    end

    it "should be invalid without a user" do
      resume = JibJob::Resume.new(@valid_attributes)
      resume.should_not be_valid
      resume.errors[:user].should include("User must not be blank")
    end

    it "should not allow creation of resumes with existing slug" do
      resume1 = @user.resumes.new(@valid_attributes)
      resume1.save!
      resume2 = @user.resumes.new(@valid_attributes)
      resume2.should_not be_valid
      resume2.errors[:slug].should include("This friendly name is already used")
    end

    it "should not allow same names from the same user" do
      resume1 = @user.resumes.create(@valid_attributes)
      resume2 = @user.resumes.new(@valid_attributes)
      resume2.slug = "my-resume"
      resume2.should_not be_valid
      resume2.errors[:name].should include("This name is already used")
    end

    it "should allow same names from different users" do
      resume1 = @user.resumes.create(@valid_attributes)
      user2 = JibJob::User.create(:username => "tester2", :email => "tester2@local", :password => "secret")
      resume2 = user2.resumes.new(@valid_attributes)
      resume2.slug = "my-resume"
      lambda { resume2.save }.should_not raise_error
    end
    
    it "should have no access code" do
      resume = @user.resumes.create(@valid_attributes)
      resume.requires_access_code?.should be_false
    end
    
    it "should set access code" do
      resume = @user.resumes.create(@valid_attributes)
      resume.access_code = "SECRET"
      resume.requires_access_code?.should be_true
      resume.save.should be_true
    end
  end
  
  describe "model checks" do
    it "should check if a name exists" do
      resume = @user.resumes.create(@valid_attributes)
      JibJob::Resume.name_exists?(@valid_attributes[:name]).should be_true
      JibJob::Resume.name_exists?("Fake Resume").should be_false
      JibJob::Resume.name_exists?(@valid_attributes[:name], @user).should be_true
    end

    it "should check if a slug exists" do
      resume = @user.resumes.create(@valid_attributes)
      JibJob::Resume.slug_exists?(@valid_attributes[:slug]).should be_true
      JibJob::Resume.slug_exists?("fake-slug").should be_false
    end
  end
  
end