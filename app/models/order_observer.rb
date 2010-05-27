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

  def after_accept(order, transition)
    supplier = order.supplier
    if send_notification_by_text_message?(supplier)
      OrderDetailsNotificationConversation.create!(
        :with => supplier,
        :topic => "order_details_conversation"
      ).move_along!(order)
    end
    notify_seller(order)
    pay_supplier(order)
  end

  def after_reject(order, transition)
    notify_seller(order)
  end
    
  def after_complete(order, transition)
    notify_seller(order)
    pay_supplier(order)
  end
  
  private
    def notify_seller(order)
      seller = order.product.seller
      unless seller == order.supplier
        if send_notification_by_text_message?(seller)
          SupplierProcessedOrderNotificationConversation.create!(
            :with => seller,
            :topic => "supplier_processed_order_notification_conversation"
          ).move_along!(order)
        end
      end
    end
    
    def pay_supplier(order)
      payment = order.product.seller.outgoing_payments.build(
        :supplier_order => order,
        :supplier => order.supplier,
        :amount => order.supplier_total
      )
      payment.pay if payment.save
    end

    def send_notification_by_text_message?(user)
      user.mobile_number # do more here...
    end
end
