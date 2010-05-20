class OrderObserver < ActiveRecord::Observer
  def after_create(order)
    if supplier = order.supplier
      if send_notification_by_text_message?(supplier)
        SupplierOrderNotificationConversation.create!(
          :with => supplier,
          :topic => "supplier_order_notification"
        ).move_along!(order)
      end
    end
  end
  
  def after_reject(order, transition)
    supplier = order.supplier
    seller = order.product.seller
    if seller != supplier
      if send_notification_by_text_message?(seller)
        RejectOrderNotificationConversation.create!(
          :with => seller,
          :topic => "reject_order_notification"
        ).move_along!(order)
      end
    end
  end
  
  def after_accept(order, transition)
    supplier = order.supplier
    if send_notification_by_text_message?(supplier)
      OrderDetailsNotificationConversation.create!(
        :with => supplier,
        :topic => "order_details_conversation"
      ).move_along!(order)
    end
  end
  
  private
    def send_notification_by_text_message?(user)
      user.mobile_number # do more here...
    end
end
