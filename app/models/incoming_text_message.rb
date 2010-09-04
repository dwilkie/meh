class IncomingTextMessage < ActiveRecord::Base
  serialize  :params
  belongs_to :mobile_number

  before_create :link_to_mobile_number

  validates :params,
            :presence => true,
            :uniqueness => true

  validates :from,
            :presence => true

  before_validation(:on => :create) do
    self.from = SMSNotifier.connection.sender(self.params) if self.params
  end

  def text
    SMSNotifier.connection.message_text(self.params)
  end

  def authenticated?
    SMSNotifier.connection.authenticated?(
      self.params,
      Rails.application.config.secret_token
    )
  end

  private
    def link_to_mobile_number
      self.mobile_number = MobileNumber.where("number = ?", from).first
      self.mobile_number = MobileNumber.create!(
        :number => from
      ) unless self.mobile_number
    end
end

