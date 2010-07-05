class IncomingTextMessage < ActiveRecord::Base
  serialize  :params
  belongs_to :smsable,  :polymorphic => true
  before_create :link_to_smsable

  validates :from, :presence => true
  validates :params, :uniqueness => true

  private
    def link_to_smsable
      self.smsable = MobileNumber.where("number = ?", from).first
    end
end

