class IncomingTextMessage < ActiveRecord::Base

  class CreateIncomingTextMessageJob < Struct.new(:params)
    attr_reader :attempt_job

    def max_attempts
      1
    end

    def perform
      IncomingTextMessage.create(params)
    end
  end

  serialize  :params
  belongs_to :mobile_number

  validates :params,
            :presence => true,
            :uniqueness => true

  validates :mobile_number,
            :presence => true

  before_validation :link_to_mobile_number, :on => :create

  validate :authenticate, :on => :create

  def self.create_later(params)
    Delayed::Job.enqueue(
      CreateIncomingTextMessageJob.new(params), :priority => 2
    )
  end

  def text
    ActionSms::Base.message_text(self.params)
  end

  private
    def link_to_mobile_number
      if params
        from = ActionSms::Base.sender(params)
        self.mobile_number = MobileNumber.where("number = ?", from).first if from
      end
    end

    def authenticate
      errors[:base] << "Not authenticated" unless params.nil? ||
        ActionSms::Base.authenticate(params)
    end
end

