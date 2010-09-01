class SellerOrderObserver < ActiveRecord::Observer
  def after_create(seller_order)
    notify(seller_order)
    create_supplier_orders(seller_order)
  end

  private
    def create_supplier_orders(seller_order)
      order_notification = seller_order.order_notification
      seller = seller_order.seller
      order_notification.number_of_cart_items.times do |index|
        item_number = order_notification.item_number(index)
        item_name = order_notification.item_name(index)
        item_quantity = order_notification.item_quantity(index)
        product = seller.selling_products.with_number_and_name(
          item_number,
          item_name
        ).first
        unless product
          products = seller.selling_products.with_number_or_name(
            item_number,
            item_name
          )
          if products.count == 2
            products.where(
              "products.name = ?", item_name
            ).first.destroy
          end
          product = products.first
          if product
            product.update_attributes!(:number => item_number, :name => item_name)
          else
            product = Product.create!(
              :seller => seller,
              :supplier => seller,
              :number => item_number,
              :name => item_name
            )
          end
        end
        seller_order.supplier_orders.create!(
          :product => product,
          :quantity => item_quantity
        )
      end
    end

    def notify(seller_order)
      seller = seller_order.seller
      notifications = seller.notifications.for_event(
        "customer_order_created"
      )
      seller_order_notification = GeneralNotification.new(:with => seller)
      notifications.each do |notification|
        seller_order_notification.notify(
          notification,
          :seller => seller,
          :customer_order => seller_order,
          :order_notification => seller_order.order_notification
        )
      end
    end
end

