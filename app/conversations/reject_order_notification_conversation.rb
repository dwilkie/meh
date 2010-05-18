class RejectOrderNotificationConversation < AbstractConversation
  def move_along!(order)
    say reject_order_notification_message(order)
  end
  
  private
    def reject_order_notification_message(order)
      supplier = order.supplier
      supplier_contact_details = supplier.mobile_number.nil? ?
        supplier.email : supplier.mobile_number.humanize
      I18n.t(
        "messages.supplier_rejected_sellers_order",
        :seller => order.product.seller.name,
        :supplier => supplier.name,
        :supplier_contact_details => supplier_contact_details,
        :order_number => order.id,
        :product_code => order.product.external_id
      )
    end
end
