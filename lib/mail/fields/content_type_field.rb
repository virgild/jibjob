# encoding: utf-8
# 
# 
# 
module Mail
  class ContentTypeField < StructuredField
    
    FIELD_NAME = 'content-type'

    def initialize(*args)
      super(FIELD_NAME, strip_field(FIELD_NAME, args.last))
    end
    
    def tree
      @element ||= Mail::ContentTypeElement.new(value)
      @tree ||= @element.tree
    end
    
    def element
      @element ||= Mail::ContentTypeElement.new(value)
    end
    
    def main_type
      element.main_type
    end

    def sub_type
      element.sub_type
    end
    
    def content_type
      "#{main_type}/#{sub_type}"
    end
    
    def parameters
      @parameters = Hash.new
      element.parameters.each { |p| @parameters.merge!(p) }
      @parameters
    end

    def ContentTypeField.with_boundary(type)
      new("#{type}; boundary=#{generate_boundary}")
    end
    
    def ContentTypeField.generate_boundary
      "--==_mimepart_#{Mail.random_tag}"
    end

  end
end
