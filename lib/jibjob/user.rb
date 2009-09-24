module JibJob
  class User
    include DataMapper::Resource
    attr_accessor :password_confirmation

    storage_names[:default] = 'users'
    property :id, Serial, :writer => :protected
    property :username, String
    property :email, String
    property :crypted_password, String, :length => 64
    property :created_at, DateTime
    property :updated_at, DateTime
    property :agreed_terms, String    
    
    has n, :resumes, :model => "JibJob::Resume"
    has n, :api_keys, :model => "JibJob::APIKey"
    
    validates_present :username, :message => "A username is required"
    validates_present :email, :message => "An e-mail is required"
    validates_present :password, :message => "A password is required", :if => Proc.new { |u| u.crypted_password.blank? }
    validates_length :username, :min => 5, :max => 30, :unless => Proc.new { |u| u.username.blank? },
      :message => "Username must be at least 5 characters"
    validates_is_unique :username, :message => "This username is already used", :unless => Proc.new { |u| u.username.blank? }
    validates_is_unique :email, :message => "This e-mail is already used", :unless => Proc.new { |u| u.email.blank? }
    validates_length :password, :min => 6, :unless => Proc.new { |u| u.password.blank? }, 
      :message => "The password must be at least 6 characters"
    validates_is_accepted :agreed_terms, :accept => "on", :allow_nil => false, :message => "You must accept the terms of service"
    validates_is_confirmed :password, :message => "The passwords must match", :unless => Proc.new { |u| u.password.blank? }
    validates_format :username, :with => /^[a-zA-Z][a-zA-Z_0-9]+$/, :unless => Proc.new { |u| u.username.blank? },
      :message => "The username is invalid"
    validates_format :email, :as => :email_address, :unless => Proc.new { |u| u.email.blank? }
    
    before :save, :normalize_fields
    before :destroy, :destroy_resumes    
    
    def password
      @password
    end
    
    def password=(value)
      if value.blank?
        self.crypted_password = nil
      else
        self.crypted_password = BCrypt::Password.create(value)
      end
      @password = value
    end
        
    def resume_count
      self.resumes.count
    end
    
    def has_resume?
      self.resume_count > 0
    end
    
    def can_add_resume?
      self.resume_count < 10
    end
    
    def has_api_key?
      self.api_keys.count > 0
    end
    
    def self.authenticate(username, password)
      user = self.first(:username => username)
      return nil if (user.nil? || (BCrypt::Password.new(user.crypted_password) != password))
      user
    end
    
    def self.username_exists?(username)
      !self.first(:username => username).nil?
    end
    
    def self.email_exists?(email)
      !self.first(:email => email).nil?
    end
    
    private
    
    def normalize_fields
      self.username.downcase! if self.username
      self.email.downcase! if self.email
    end
      
    def destroy_resumes
      self.resumes.destroy!
    end    

  end
  
  class APIKey
    include DataMapper::Resource
    storage_names[:default] = 'api_keys'
    property :id, Serial, :writer => :protected
    property :value, String
    belongs_to :user, :model => "JibJob::User"
    
    validates_present :value
    validates_is_unique :value
    
    def self.user_of(value)
      api_key = self.first(:value => value)
      api_key.user if api_key
    end
  end
end