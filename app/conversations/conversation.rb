class Conversation
  include Conversational::Conversation

  attr_accessor :user
  alias :user :with

  converse do |with, notice|
    OutgoingTextMessage.create!(:smsable => with.mobile_number, :body => notice)
  end

end

