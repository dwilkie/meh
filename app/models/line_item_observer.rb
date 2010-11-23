class LineItemObserver < ActiveRecord::Observer
  def after_create(line_item)
    notify line_item, "line_item_created"
  end

  def after_update(line_item)
    if line_item.accepted? && line_item.accepted_at_changed? && line_item.accepted_at_was.nil?
      notify line_item, "line_item_accepted"
    end
  end

  private
    def notify(line_item, event)
      product = line_item.product
      supplier_order = line_item.supplier_order
      seller_order = supplier_order.seller_order
      seller = seller_order.seller
      supplier = line_item.supplier
      order_notification = seller_order.order_notification

      notifications = seller.notifications.for_event(
        event,
        :supplier => supplier,
        :product => product
      )
      notifications.each do |notification|
        with = notification.send_to(seller, supplier)
        notifier = GeneralNotification.new(:with => with)
        notifier.payer = seller
        notifier.notify(
          notification,
          :product => product,
          :line_item => line_item,
          :supplier_order => supplier_order,
          :seller_order => seller_order,
          :seller => seller,
          :supplier => supplier,
          :order_notification => order_notification
        )
      end
    end
end

