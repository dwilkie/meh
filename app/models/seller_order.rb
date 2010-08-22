class SellerOrder < ActiveRecord::Base

  belongs_to :seller,
             :class_name => "User"

  belongs_to :order_notification, :polymorphic => true

  has_many   :supplier_orders

  validates :seller,
            :order_notification,
            :presence => true

  after_create :trigger_event, :create_supplier_orders

  def create_supplier_orders
    order_notification = self.order_notification
    seller = self.seller
    order_notification.number_of_cart_items.times do |index|
      item_number = order_notification.item_number(index)
      item_name = order_notification.item_name(index)
      item_quantity = order_notification.item_quantity(index)
      product = seller.selling_product(
        :product_number => item_number,
        :product_name => item_name,
        :exact_match => true
      )
      if product
        self.supplier_orders.create(
          :product => product,
          :quantity => item_quantity
        )
      else
        product = seller.selling_product(
          :product_number => item_number,
          :product_name => item_name,
          :exact_match => false
        )
        if product
          notify(
            "product_does_not_match_item_in_customer_order",
            :product => product
          )
        else
          notify(
            "product_does_not_exist_in_customer_order",
            :item_number => item_number,
            :item_name => item_name,
            :item_quantity => item_quantity
          )
        end
      end
    end
  end

  private
    def notify(event, options = {})
      seller = self.seller
      notifications = seller.notifications.for_event(event)
      seller_order_notification = SellerOrderNotification.new(:with => seller)
      notifications.each do |notification|
        seller_order_notification.notify(
          notification,
          options.merge(
            :seller => seller,
            :order_notification => self.order_notification
          )
        )
      end
    end

    def trigger_event
      notify("customer_order_created")
    end
end

