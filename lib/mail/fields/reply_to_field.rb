# encoding: utf-8
# 
# = Reply-To Field
# 
# The Reply-To field inherits reply-to StructuredField and handles the Reply-To: header
# field in the email.
# 
# Sending reply_to to a mail message will instantiate a Mail::Field object that
# has a ReplyToField as it's field type.  This includes all Mail::CommonAddress
# module instance metods.
# 
# Only one Reply-To field can appear in a header, though it can have multiple
# addresses and groups of addresses.
# 
# == Examples:
# 
#  mail = Mail.new
#  mail.reply_to = 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail.reply_to    #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ReplyToField:0x180e1c4
#  mail[:reply_to]  #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ReplyToField:0x180e1c4
#  mail['reply-to'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ReplyToField:0x180e1c4
#  mail['Reply-To'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ReplyToField:0x180e1c4
# 
#  mail.reply_to.to_s  #=> 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail.reply_to.addresses #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
#  mail.reply_to.formatted #=> ['Mikel Lindsaar <mikel@test.lindsaar.net>', 'ada@test.lindsaar.net']
# 
module Mail
  class ReplyToField < StructuredField
    
    include Mail::CommonAddress
    
    FIELD_NAME = 'reply-to'
    
    def initialize(*args)
      super(FIELD_NAME, strip_field(FIELD_NAME, args.last))
    end
    
  end
end
