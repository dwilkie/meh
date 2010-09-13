class IncomingTextMessage < ActiveRecord::Base
  serialize  :params
  belongs_to :mobile_number

  validates :params,
            :presence => true,
            :uniqueness => true

  validates :mobile_number,
            :presence => true

  before_validation :link_to_mobile_number, :on => :create

  validate :authenticate, :on => :create

  def text
    SMSNotifier.connection.message_text(self.params)
  end

  private
    def link_to_mobile_number
      if params
        from = SMSNotifier.connection.sender(params)
        self.mobile_number = MobileNumber.where("number = ?", from).first if from
      end
    end

    def authenticate
      errors[:base] << "Not authenticated" unless
        SMSNotifier.connection.authenticate(params)
    end
end

