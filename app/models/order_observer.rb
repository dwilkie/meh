class OrderObserver < ActiveRecord::Observer
  def after_create(order)
    if supplier = order.supplier
      if supplier.mobile_number # check their preference
        SupplierOrderNotificationConversation.create!(
          :with => supplier,
          :topic => "supplier_order_notification"
        ).move_along!(order)
      else
        # send an email
      end
    end
  end
  def after_reject(order, transition)
    supplier = order.supplier
    seller = order.product.seller
    if seller != supplier
      if seller.mobile_number # check their preference
        RejectOrderNotificationConversation.create!(
          :with => seller,
          :topic => "reject_order_notification"
        ).move_along!(order)
      else
        # send an email
      end
    end
  end
end
