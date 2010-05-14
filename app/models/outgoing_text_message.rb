class OutgoingTextMessage < ActiveRecord::Base
  serialize :params
  belongs_to :smsable, :polymorphic => true
end
