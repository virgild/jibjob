module JibJob
  class Message
    include DataMapper::Resource
    storage_names[:default] = 'messages'
    property :id, Serial, :writer => :protected
    property :subject, String
    property :body, Text
    property :from, String
    property :is_read, Boolean
    property :created_at, DateTime
        
    belongs_to :resume, :model => "JibJob::Resume"
    
    validates_present :from, :message => "Your name is required"
    validates_present :subject, :message => "A subject is required"
    validates_present :body, :message => "Enter a message"
    
    def is_read?
      self.is_read || false
    end
    
    def mark_as_read!
      self.is_read = true
      self.save
    end
    
    def mark_as_unread!
      self.is_read = false
      self.save
    end
    
  end
end