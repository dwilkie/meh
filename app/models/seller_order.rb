class SellerOrder < ActiveRecord::Base

  belongs_to :seller,
             :class_name => "User"

  belongs_to :order_notification, :polymorphic => true

  has_many   :supplier_orders

  validates :seller,
            :order_notification,
            :presence => true

  after_create :create_supplier_orders

  def create_supplier_orders
    order_notification = self.order_notification
    seller = self.seller
    number_of_missing_products = 0
    order_notification.number_of_cart_items.times do |index|
      item_number = order_notification.item_number(index)
      item_quantity = order_notification.item_quantity(index)
      product = seller.selling_product(item_number)
      if product
        self.supplier_orders.create(
          :product => product,
          :quantity => item_quantity
        )
      else
        number_of_missing_products += 1
      end
    end
    SellerOrderNotification.new(
      :with => seller
    ).products_not_found(
      self,
      number_of_missing_products,
      order_notification.number_of_cart_items
    ) if number_of_missing_products > 0
  end

  private
    def notify(event)
      notifications = seller.notifications.for_event(event)
      seller_order_notification = SellerOrderNotification.new(:with => self.seller)
      notifications.each do |notification|
        seller_order_notification.notify(notification, self)
      end
    end
end

