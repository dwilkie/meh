class SellerOrder < ActiveRecord::Base

  belongs_to :seller,
             :class_name => "User"

  belongs_to :order_notification, :polymorphic => true

  has_many   :supplier_orders

  validates :seller,
            :order_notification,
            :presence => true
end

