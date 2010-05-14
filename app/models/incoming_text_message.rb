class IncomingTextMessage < ActiveRecord::Base
  serialize  :params
  belongs_to :smsable,  :polymorphic => true
  
  validates :message_id, :presence => true, :uniqueness => true
  validates :originator, :presence => true
end
