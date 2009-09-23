require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe JibJob::User do
  
  before do
    @valid_attributes = {
      :username => "someuser",
      :email => "someuser@jibjob.local",
      :password => "secret",
      :password_confirmation => "secret",
      :agreed_terms => "on"
    }
  end
  
  describe "model checks" do
    it "should check existing username" do
      JibJob::User.create!(@valid_attributes)
      JibJob::User.username_exists?(@valid_attributes[:username]).should be_true
      JibJob::User.username_exists?("unknown").should be_false
    end

    it "should check existing e-mail" do
      JibJob::User.create!(@valid_attributes)
      JibJob::User.email_exists?(@valid_attributes[:email]).should be_true
      JibJob::User.email_exists?("unknown@email.com").should be_false
    end
    
    it "should authenticate valid user" do
      user = JibJob::User.create(@valid_attributes)
      user.should be_valid
      JibJob::User.authenticate("someuser", "secret").should == user
    end

    it "should not authenticate invalid user" do
      JibJob::User.authenticate("faker_user", "password").should be_nil
    end

    it "should count the resumes belonging to a user" do
      user = JibJob::User.create!(@valid_attributes)
      user.resume_count.should == 0

      resume1 = user.resumes.create(:name => "Test 1", :slug => "test-1", :content => "")
      user.resume_count.should == 1

      resume2 = user.resumes.create(:name => "Test 2", :slug => "test-2", :content => "")
      user.resume_count.should == 2

      resume1.destroy.should == true
      user.resume_count.should == 1

      resume2.destroy.should == true
      user.resume_count.should == 0
    end

    it "should determine if a resume can be added" do
      user = JibJob::User.create!(@valid_attributes)
      user.can_add_resume?.should == true

      (1..9).each do |n|
        user.resumes.create(:name => "Resume #{n}", :slug => "resume-#{n}", :content => "")
        user.can_add_resume?.should == true
      end
      user.resumes.create(:name => "Resume 10", :slug => "resume-10", :content => "")
      user.can_add_resume?.should == false
    end
  end
  
  describe "creation" do
    it "should be created with valid attributes" do
      user = JibJob::User.new(@valid_attributes)
      user.should be_valid
      user.save.should be_true
    end

    it "should have no resumes" do
      user = JibJob::User.create!(@valid_attributes)
      user.should have(0).resumes
    end
    
    it "should require a username" do
      user = JibJob::User.new(@valid_attributes)
      user.username = nil
      user.should_not be_valid
      user.errors[:username].should include("A username is required")
    end
    
    it "should not allow invalid usernames" do
      user = JibJob::User.new(@valid_attributes)
      user.username = "!myname"
      user.should_not be_valid
      user.errors[:username].should include("The username is invalid")
      
      user.username = "1username"
      user.should_not be_valid
      user.errors[:username].should include("The username is invalid")
      
      user.username = "Hello my name is test."
      user.should_not be_valid
      user.errors[:username].should include("The username is invalid")
      
      user.username = "username1"
      user.should be_valid
      
      user.username = "test_user"
      user.should be_valid
    end
    
    it "should require 5 character min username" do
      user = JibJob::User.new(@valid_attributes)
      user.username = 'user1'
      user.should be_valid
    end
        
    it "should not allow duplicate usernames on creation" do
      user = JibJob::User.create!(@valid_attributes)

      user2 = JibJob::User.new :username => @valid_attributes[:username],
        :email => "tester@jibjob.local", :password => "secret"
      user2.should_not be_valid
      user2.errors[:username].should include("This username is already used")
    end
    
    it "should not allow duplicate e-mails on creation" do
      user = JibJob::User.create!(@valid_attributes)

      user2 = JibJob::User.new(:username => "tester", :email => @valid_attributes[:email], :password => "secret")
      user2.should_not be_valid
      user2.errors[:email].should include("This e-mail is already used")
    end
    
    it "should not allow blank password on create" do
      user = JibJob::User.new(:username => "tester", :email => "tester@email.org")
      user.should_not be_valid
      user.errors[:password].should include("A password is required")
    end
    
    it "should not allow non-matching passwords" do
      user = JibJob::User.new(@valid_attributes)
      user.password_confirmation = "wrong"
      user.should_not be_valid
      user.password_confirmation = @valid_attributes[:password_confirmation]
      user.should be_valid
    end
  end  
  
  describe "updating" do
    it "should downcase username on save" do
      user = JibJob::User.new(@valid_attributes)
      user.username = 'SOMEUSER'
      user.save.should be_true
      user.username.should_not == 'SOMEUSER'
      user.username.should == 'someuser'
    end

    it "should downcase e-mail on save" do
      user = JibJob::User.new(@valid_attributes)
      user.email = 'SomeUser@JibJob.LOCAL'
      user.save.should be_true
      user.email.should_not == 'SomeUser@JibJob.LOCAL'
      user.email.should == 'someuser@jibjob.local'
    end

    it "should not allow duplicated usernames on edit" do
      user = JibJob::User.create!(@valid_attributes)
      user2 = JibJob::User.create!(:username => "tester", :email => "tester@email.org", :password => "secret")

      user2.username = @valid_attributes[:username]
      user2.should_not be_valid
      user2.errors[:username].should include("This username is already used")
    end

    it "should not allow duplicate e-mails on edit" do
      user = JibJob::User.create!(@valid_attributes)
      user2 = JibJob::User.create!(:username => "tester", :email => "tester@email.org", :password => "secret")

      user2.email = @valid_attributes[:email]
      user2.should_not be_valid
      user2.errors[:email].should include("This e-mail is already used")
    end
    
    it "should update e-mail" do
      user = JibJob::User.create(@valid_attributes)
      user.reload
      user.email = "updated.email@local"
      user.should be_valid
    end
    
    it "should update password" do
      user = JibJob::User.create(@valid_attributes)
      user.reload
      user.password = ""
      user.password_confirmation = ""
      user.should_not be_valid
      
      user.password = "test"
      user.password_confirmation = "test"
      user.should_not be_valid
      
      user.password = "secret"
      user.password_confirmation = "secrep"
      user.should_not be_valid
      
      user.password = "secret"
      user.password_confirmation = "secret"
      user.should be_valid
      user.save.should be_true
    end
  end

end