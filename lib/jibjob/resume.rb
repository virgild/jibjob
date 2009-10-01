# coding: utf-8

module JibJob
  class Resume
    include DataMapper::Resource

    storage_names[:default] = 'resumes'
    property :id, String, :key => true, :length => 32,
             :default => Proc.new { |r, p| ::UUIDTools::UUID.random_create.hexdigest }
    property :name, String
    property :content, Text
    property :slug, String
    property :access_code, String
    property :created_at, DateTime
    property :updated_at, DateTime
        
    belongs_to :user, :model => "JibJob::User", :child_key => [:user_id]
    has n, :messages, :model => "JibJob::Message"
    
    validates_present :user
    validates_present :name, :message => "A name is required"
    validates_present :slug, :message => "A friendly name is required"
    validates_is_unique :name, :scope => :user_id, :message => "This name is already used"
    validates_is_unique :slug, :message => "This friendly name is already used"
    validates_length :name, :min => 4, :max => 50, 
      :unless => Proc.new { |r| r.name.blank? }, 
      :message => "The name must be 4 to 30 characters"
    validates_length :slug, :min => 4, :max => 30,
      :unless => Proc.new { |r| r.slug.blank? },
      :message => "The friendly name must be 4 to 30 characters"
    validates_length :content, :max => 24000,
      :unless => Proc.new { |r| r.content.blank? },
      :message => "The content is exceedingly long"
    validates_length :access_code, :max => 12,
      :unless => Proc.new { |r| r.access_code.blank? }
             
    default_scope(:default).update(:order => [:created_at.desc])
    
    before :save, :convert_newlines
    before :save, :add_final_newline
      
    def data
      @data ||= ResumeTools::Resume.from_text(self.content)
    rescue ResumeTools::TextReader::ParseException => e
      data = nil
    end
    
    def full_name
      data.full_name
    end
    
    def address1
      data.address1
    end
    
    def address2
      data.address2
    end
    
    def telephone
      data.telephone
    end
    
    def email
      data.email
    end
    
    def url
      data.url
    end
    
    def sections
      data.sections
    end
    
    def add_final_newline
      if self.content[-1] != "\n"
        self.content << "\n"
      end
    end
    
    def header_lines(options={})
      elements = Array.new
      [:address1, :address2, :telephone, :email, :url].each do |element|
        elements << self.send(element) unless self.send(element).blank?
      end
      lines = Array.new
      elements.each_slice(2) { |pair| lines << pair.join(" • ") }
      lines
    end
    
    def render_pdf(options={})
      self.data.render_pdf
    end
    
    def render_text(options={})
      self.data.render_plain_text
    end
    
    def render_json(options={})
      self.data.render_json      
    end
    
    def convert_newlines
      self.content.gsub!(/\r\n/, "\n") if self.content
    end
    
    def requires_access_code?
      !self.access_code.blank?
    end
    
    def valid_access_cookie?(value, ip_address)
      self.generate_access_cookie(ip_address) == value
    end
    
    def generate_access_cookie(ip_address)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, self.access_code, ip_address)
    end
    
    def has_unread_messages?
      self.unread_messages_count > 0
    end
    
    def unread_messages_count
      self.unread_messages.count
    end
    
    def unread_messages
      self.messages.all(:is_read => false)
    end
        
    def self.name_exists?(name, user=nil)
      if user
        self.first(:user_id => user.id, :name => name) != nil
      else
        self.first(:name => name) != nil
      end
    end
    
    def self.slug_exists?(slug)
      self.first(:slug => slug) != nil
    end
    
  end
end