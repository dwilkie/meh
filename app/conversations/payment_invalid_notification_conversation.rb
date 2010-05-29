class PaymentInvalidNotificationConversation < AbstractSellerNotificationConversation
  def move_along!(payment)
    say notify_seller(
      payment.supplier_order,
      "messages.payment_invalid",
      :errors => payment.errors.full_messages.to_sentence
    )
  end
end
