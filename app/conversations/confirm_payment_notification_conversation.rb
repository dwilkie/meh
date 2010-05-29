class ConfirmPaymentNotificationConversation < AbstractSellerNotificationConversation
  def move_along!(order)
    amount = order.supplier_total
    amount = amount.format(:symbol => false) << " " << amount.currency.iso_code
    say notify_seller(
      order,
      "messages.confirm_payment_notification", :amount => amount
    )
  end
end
