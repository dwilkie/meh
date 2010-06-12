class PaymentRequestNotification < Conversation
  def completed(payment_request)
    payment = payment_request.payment
    supplier_order = payment.supplier_order
    supplier = payment.supplier
    supplier_contact_details = contact_details(supplier)
    amount = payment.amount
    amount = amount.format(:symbol => false) << " " << amount.currency.iso_code
    say I18n.t(
      "messages.payment_request_notification",
      :seller => user.name,
      :amount => amount,
      :supplier => supplier.name,
      :supplier_contact_details => supplier_contact_details,
      :supplier_order_number => supplier_order.id,
      :customer_order_number => supplier_order.seller_order.id,
      :product_code => supplier_order.product.external_id,
      :quantity => supplier_order.quantity,
      :error => payment_request.error
    )
  end

  private
    def contact_details(user)
      user.mobile_number.nil? ? user.email : user.mobile_number.humanize
    end
end

