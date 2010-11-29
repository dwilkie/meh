class SellerOrderPaypalIpn < PaypalIpn
  include Paypal::Ipn::Item
  include Paypal::Ipn::Buyer
  include Paypal::Ipn::Payment

  has_one :seller_order, :as => :order_notification
  has_one :seller,
          :through => :seller_order

  after_update  :link_seller

  validate :seller_exists,
           :at_least_one_cart_item

  private
    def at_least_one_cart_item
      errors[:base] << "Must be at least one cart item" unless
        params.nil? ||
        (item_name && item_number && item_quantity)
    end

    def link_seller
      self.seller = find_seller if
        verified_at_changed? && verified? &&
        verified_at_was.nil? && payment_completed?
    end

    def find_seller
      User.with_role("seller").where(
        "email = ?", receiver_email
      ).first
    end

    def seller_exists
      errors[:base] << "Receiver must be registered as a seller" unless
      params.nil? || find_seller
    end
end

