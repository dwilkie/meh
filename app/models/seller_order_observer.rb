class SellerOrderObserver < ActiveRecord::Observer
  def after_create(seller_order)
    notify(seller_order, "customer_order_created")
    create_supplier_orders(seller_order)
  end

  def after_update(seller_order)
    if seller_order.confirmed? && seller_order.confirmed_at_changed? && seller_order.confirmed_at_was.nil?
      notify seller_order, "customer_order_confirmed"
    elsif seller_order.completed? && seller_order.completed_at_changed? && seller_order.completed_at_was.nil?
      notify seller_order, "customer_order_completed"
    end
  end

  private

    def create_supplier_orders(seller_order)
      supplier_orders = build_supplier_orders(seller_order)
      supplier_orders.each do |supplier_id, line_items|
        build_line_item_indexes(line_items)
        supplier_order = seller_order.supplier_orders.create!(
          :supplier_id => supplier_id,
          :number_of_line_items => line_items.length
        )
        supplier_order.line_items = line_items
        supplier_order.save!
      end
    end

    def build_supplier_orders(seller_order)
      order_notification = seller_order.order_notification
      seller = seller_order.seller
      supplier_orders = {}
      order_notification.number_of_cart_items.times do |index|
        product = find_or_create_product(seller, order_notification, index)
        item_quantity = order_notification.item_quantity(index)
        supplier = product.supplier
        line_item = supplier.line_items.build(
          :seller_order => seller_order,
          :product => product,
          :quantity => item_quantity
        )
        line_item.seller_order_index = index + 1
        supplier_key = supplier.id
        supplier_orders[supplier_key] ||= []
        supplier_orders[supplier_key] << line_item
      end
      supplier_orders
    end

    def build_line_item_indexes(line_items)
      line_items.each_with_index do |line_item, index|
        line_item.supplier_order_index = index + 1
      end
    end

    def find_or_create_product(seller, order_notification, index)
      item_number = order_notification.item_number(index)
      item_name = order_notification.item_name(index)
      item_price = order_notification.item_amount(index)
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
          product.update_attributes!(
            :number => item_number,
            :name => item_name
          )
        else
          product = seller.selling_products.create!(
            :number => item_number,
            :name => item_name
          )
        end
      end
      unless product.price == item_price
        product.price = item_price
        product.save!
      end
      product
    end

    def notify(seller_order, event)
      seller = seller_order.seller
      supplier = seller_order.supplier
      notifications = seller.notifications.for_event(
        event,
        :supplier => supplier
      )
      seller_order_notification = GeneralNotification.new(:with => seller)
      notifications.each do |notification|
        seller_order_notification.notify(
          notification,
          :seller => seller,
          :seller_order => seller_order,
          :order_notification => seller_order.order_notification
        )
      end
    end
end

