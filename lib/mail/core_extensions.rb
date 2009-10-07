# encoding: utf-8
#:nodoc:
# From the nice guys at rubyonrails.org -> ActiveSupport
class ::Object
  # An object is blank if it's nil, empty, or a whitespace string.
  # For example, "", "   ", nil, [], and {} are blank.
  #
  # This simplifies
  #   if !address.nil? && !address.empty?
  # to
  #   if !address.blank?
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

class NilClass #:nodoc:
  def blank?
    true
  end
  
  def to_crlf
    ''
  end
  
  def to_lf
    ''
  end
end

class FalseClass #:nodoc:
  def blank?
    true
  end
end

class TrueClass #:nodoc:
  def blank?
    false
  end
end

class Array #:nodoc:
  alias_method :blank?, :empty?
end

class Hash #:nodoc:
  alias_method :blank?, :empty?
end

class String #:nodoc:
  def blank?
    self !~ /\S/
  end
  
  def to_crlf
    self.gsub(/\n|\r\n|\r/) { "\r\n" }
  end

  def to_lf
    self.gsub(/\n|\r\n|\r/) { "\n" }
  end

  if RUBY_VERSION <= "1.9"

    # Provides all strings with the Ruby 1.9 method of .ascii_only? and
    # returns true or false
    US_ASCII_REGEXP = %Q{\x00-\x7f}
    def ascii_only?
      !(self =~ /[^#{US_ASCII_REGEXP}]/)
    end
    
  end
  
end


class Numeric #:nodoc:
  def blank?
    false
  end
end
