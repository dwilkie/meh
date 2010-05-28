class SupplierProcessedOrderNotificationConversation < AbstractSellerNotificationConversation
  def move_along!(order)
    say notify_seller(order, "messages.supplier_processed_sellers_order_notification")
  end
end
