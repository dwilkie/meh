class SupplierOrderNotificationConversation < AbstractConversation
  def move_along!(order)
    message = I18n.t(
      "messages.supplier_order_notification",
      :supplier => order.supplier.name,
      :quantity => order.quantity,
      :product_code => order.product.external_id,
      :order_number => order.id
    )
    say message
    finish
  end
end
