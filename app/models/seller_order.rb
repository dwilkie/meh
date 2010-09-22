class SellerOrder < ActiveRecord::Base

  belongs_to :seller,
             :class_name => "User"

  belongs_to :order_notification, :polymorphic => true

  has_many   :supplier_orders

  validates :seller,
            :order_notification,
            :presence => true

  def order_notification_with_type
    order_notification = order_notification_without_type
    order_notification.respond_to?(:type) ?
      order_notification.type :
      order_notification
  end

  alias_method_chain :order_notification, :type

end

