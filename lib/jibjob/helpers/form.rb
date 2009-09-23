module JibJob
  module Helpers
    module Form
      def text_field(object, property, opts={})
        input_field(object, property, "text", opts)
      end
      
      def password_field(object, property, opts={})
        input_field(object, property, "password", opts)
      end
      
      private
      def input_field(object, property, type, opts={})
        label = opts[:label] || property
        required = opts[:required] || false
        var = instance_variable_get("@#{object}")
        value = var.send(property.to_sym)
        #errors = var.errors[property.to_sym]
        #has_errors = !errors.nil? && errors.length > 0
        #error_msgs = errors.join(", ") if has_errors        
        
        #errors_attr = has_errors ? %Q(<strong>#{error_msgs}</strong>) : ""
        required_attr = required ? %Q(<em>*</em>) : ""
        label = %Q(<label for="#{object}_#{property}">#{label}:#{required_attr}</label>)
        input = %Q(<input type="#{type}" id="#{object}_#{property}" name="#{object}[#{property}]" value="#{value}" size="30" maxlength="50" />)
        label + input
      end
    end
  end
end