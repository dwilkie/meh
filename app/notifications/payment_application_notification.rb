class PaymentApplicationNotification < Conversation
  def invalid(payment_application, payment)
    supplier_order = payment.supplier_order
    supplier = supplier_order.supplier
    supplier_contact_details = contact_details(supplier)
    amount = payment.amount
    amount = amount.format(:symbol => false) << " " << amount.currency.iso_code
    status = payment_application.status if payment_application
    say I18n.t(
      "messages.payment_application_invalid",
      :seller => user.name,
      :supplier => supplier.name,
      :supplier_contact_details => supplier_contact_details,
      :supplier_order_number => supplier_order.id,
      :amount => amount,
      :status => status
    )
  end
  
  private
    def contact_details(user)
      user.mobile_number.nil? ? user.email : user.mobile_number.humanize
    end
end
