class OrderObserver < ActiveRecord::Observer
  def after_create(order)
    if supplier = order.supplier
      SupplierOrderNotificationConversation.create!(
        :with => supplier,
        :topic => "supplier_order_notification"
      ).move_along!(order)
    end
  end
  def after_reject(order, transition)
    supplier = order.supplier
    seller = order.product.seller
    if seller != supplier
      RejectOrderNotificationConversation.create!(
        :with => seller,
        :topic => "reject_order_notification"
      ).move_along!(order)
    end
  end
end
