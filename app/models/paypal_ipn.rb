class PaypalIpn < ActiveRecord::Base
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
end

