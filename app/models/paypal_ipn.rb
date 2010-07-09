class PaypalIpn < ActiveRecord::Base
  include HTTParty

  after_create :verify

  belongs_to :seller,
             :class_name => "User"

  belongs_to :customer_order,
             :class_name => "Order"

  serialize  :params

  validates :params,
            :presence => true

  validates :transaction_id,
            :presence => true,
            :uniqueness => true

  validates :seller,
            :presence => true

  before_validation(:on => :create) do
    if self.params
      self.transaction_id = self.params["txn_id"]
      self.seller = User.with_role("seller").where(
        ["email = ?", self.params["receiver_email"]]
      ).first
    end
  end

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
end

