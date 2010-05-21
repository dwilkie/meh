class SupplierProcessedOrderNotificationConversation < AbstractConversation
  def move_along!(order)
    say supplier_processed(order)
  end
  
  private
    def supplier_processed(order)
      supplier = order.supplier
      supplier_contact_details = supplier.mobile_number.nil? ?
        supplier.email : supplier.mobile_number.humanize
      I18n.t(
        "messages.supplier_processed_sellers_order_notification",
        :seller => user.name,
        :supplier => supplier.name,
        :supplier_contact_details => supplier_contact_details,
        :supplier_order_number => order.id,
        :seller_order_number => order.seller_order.id,
        :product_code => order.product.external_id,
        :processed => order.status
      )
    end
end
