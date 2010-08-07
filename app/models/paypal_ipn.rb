class PaypalIpn < ActiveRecord::Base
  include HTTParty

  has_one :seller_order, :as => :order_notification

  has_one :seller,
          :through => :seller_order

  serialize  :params

  before_validation(:on => :create) do
    self.transaction_id = self.params["txn_id"] if self.params
  end

  before_create :set_payment_status

  after_create  :verify

  validates :params,
            :presence => true

  validates :transaction_id,
            :presence => true,
            :uniqueness => true

  validate :seller_must_exist

  def verify
    request_uri = URI.parse(APP_CONFIG["paypal_ipn_postback_uri"])
    request_uri.scheme = "https" # force https

    if self.class.post(
        request_uri.to_s,
        :body => self.params.merge("cmd"=>"_notify-validate")
      ).body == "VERIFIED"
      self.update_attribute(:verified_at, Time.now)
    else
      self.update_attribute(:fraudulent, true)
    end
  end
  handle_asynchronously :verify

  private
    def seller_must_exist
      if self.params
        errors[:base] << "Receiver must be registered as a seller" unless
        User.with_role("seller").where(
          ["email = ?", self.params["receiver_email"]]
        ).first
      end
    end

    def set_payment_status
      self.payment_status = self.params["payment_status"] if self.params
    end
end

