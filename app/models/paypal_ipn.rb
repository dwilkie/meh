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
  after_update  :link_seller

  validates :params,
            :presence => true

  validates :transaction_id,
            :presence => true,
            :uniqueness => true

  validate :seller_exists, :at_least_one_cart_item

  # Instance methods that must be implemented for all order notifications

  def payment_completed?
    self.payment_status == "Completed"
  end

  def verified?
    self.verified_at
  end

  def item_name(index)
    self.params["item_name#{index + 1}"]
  end

  def item_quantity(index)
    self.params["quantity#{index + 1}"].to_i
  end
.to_s
  def item_number(index)
    self.params["item_number#{index + 1}"]
  end

  def number_of_cart_items
    self.params["num_cart_items"].to_i
  end

  def customer_address(delimeter = ",\n")
    [
      customer_address_name,
      customer_address_street,
      customer_address_city,
      customer_address_state,
      customer_address_country + " " + customer_address_zip,
    ].join(delimeter)
  end

  def customer_address_name
    self.params["address_name"].to_s
  end

  def customer_address_street
    self.params["address_street"].to_s
  end

  def customer_address_city
    self.params["address_city"].to_s
  end

  def customer_address_state
    self.params["address_state"].to_s
  end

  def customer_address_zip
    self.params["address_zip"].to_s
  end

  def customer_address_country
    self.params["address_country"].to_s
  end

  def verify
    request_uri = URI.parse(APP_CONFIG["paypal_ipn_postback_uri"])
    request_uri.scheme = "https" # force https

    if self.class.post(
        request_uri.to_s,
        :body => self.params.merge("cmd"=>"_notify-validate")
      ).body == "VERIFIED"
      self.update_attributes!(:verified_at => Time.now)
    else
      self.update_attributes!(:fraudulent => true)
    end
  end
  handle_asynchronously :verify

  private
    def seller_exists
      errors[:base] << "Receiver must be registered as a seller" if self.params && find_seller.nil?
    end

    def at_least_one_cart_item
      errors[:base] << "Must be at least one cart item" if self.params && (self.number_of_cart_items < 1 || self.item_name(0).nil? || self.item_number(0).nil? || self.item_quantity(0).nil?)
    end

    def set_payment_status
      self.payment_status = self.params["payment_status"] if self.params
    end

    def link_seller
      self.seller = find_seller if self.verified_at_changed? && self.verified? && self.payment_completed?
    end

    def find_seller
      User.with_role("seller").where(
        ["email = ?", self.params["receiver_email"]]
      ).first
    end
end

