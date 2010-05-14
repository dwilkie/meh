class IncomingTextMessage < ActiveRecord::Base
  serialize  :params
  belongs_to :smsable,  :polymorphic => true
  belongs_to :conversation
  
  validates :message_id, :presence => true, :uniqueness => true
  validates :originator, :presence => true
end
