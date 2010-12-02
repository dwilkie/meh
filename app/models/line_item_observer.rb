class LineItemObserver < ActiveRecord::Observer
  def after_create(line_item)
    notify line_item, "line_item_created"
  end

  def after_update(line_item)
    if line_item.confirmed? && line_item.confirmed_at_changed? && line_item.confirmed_at_was.nil?
      notify line_item, "line_item_confirmed"
      line_item.supplier_order.confirm
    end
  end

  private
    def notify(line_item, event)
      product = line_item.product
      supplier_order = line_item.supplier_order
      seller_order = line_item.seller_order
      seller = seller_order.seller
      supplier = line_item.supplier
      order_notification = seller_order.order_notification

      notifications = seller.notifications.for_event(
        event, :supplier => supplier
      )
      notifications.each do |notification|
        with = notification.send_to(seller, supplier)
        notifier = GeneralNotification.new(:with => with)
        notifier.payer = seller
        notifier.notify(
          notification,
          :line_item => line_item,
          :product => product,
          :supplier_order => supplier_order,
          :seller_order => seller_order,
          :seller => seller,
          :supplier => supplier,
          :order_notification => order_notification
        )
      end
    end
end

