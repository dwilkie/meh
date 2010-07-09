class PaypalIpn < ActiveRecord::Base
  belongs_to :seller,
             :class_name => "User"

  belongs_to :customer_order,
             :class_name => "Order"

  serialize  :params

  validates :transaction_id,
            :presence => true,
            :uniqueness => true

  validates :seller,
            :params,
            :presence => true

  before_validation(:on => :create) do
    self.transaction_id = params["txn_id"]
    self.seller = User.with_role("seller").where(
      ["email = ?", params["receiver_email"]]
    ).first
  end
end

