class OutgoingTextMessage < ActiveRecord::Base
  serialize :params
  belongs_to :smsable, :polymorphic => true
  belongs_to :conversation
end
