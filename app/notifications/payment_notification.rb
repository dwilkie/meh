class PaymentNotification < Conversation
  def confirm(payment)
    supplier_order = payment.supplier_order
    supplier = supplier_order.supplier
    supplier_contact_details = contact_details(supplier)
    amount = payment.amount
    amount = amount.format(:symbol => false) << " " << amount.currency.iso_code
    say I18n.t(
      "messages.confirm_payment_notification",
      :seller => user.name,
      :supplier => supplier.name,
      :supplier_contact_details => supplier_contact_details,
      :supplier_order_number => supplier_order.id,
      :customer_order_number => supplier_order.seller_order.id,
      :quantity => supplier_order.quantity,
      :product_code => supplier_order.product.external_id,
      :processed => supplier_order.status,
      :amount => amount
    )
  end
  
  def invalid(payment)
    supplier_order = payment.supplier_order
    supplier = supplier_order.supplier
    supplier_contact_details = contact_details(supplier)
    say I18n.t(
      "messages.payment_invalid",
      :seller => user.name,
      :supplier => supplier.name,
      :supplier_contact_details => supplier_contact_details,
      :supplier_order_number => supplier_order.id,
      :customer_order_number => supplier_order.seller_order.id,
      :quantity => supplier_order.quantity,
      :product_code => supplier_order.product.external_id,
      :processed => supplier_order.status,
      :errors => payment.errors.full_messages.to_sentence
    )
  end
  
  private
    def contact_details(user)
      user.mobile_number.nil? ? user.email : user.mobile_number.humanize
    end
end
