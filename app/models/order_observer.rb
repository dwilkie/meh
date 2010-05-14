class OrderObserver < ActiveRecord::Observer
  def after_create(order)
    if supplier = order.supplier
      SupplierOrderNotificationConversation.create!(
        :with => supplier,
        :topic => "supplier_order_notification"
      ).move_along!(order)
    end
  end
end
