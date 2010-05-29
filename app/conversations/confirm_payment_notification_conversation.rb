class ConfirmPaymentNotificationConversation < AbstractConversation
  def move_along!(payment)
    say confirm(payment)
  end
  
  private
    def confirm(payment)
      supplier_order = payment.supplier_order
      supplier = supplier_order.supplier
      supplier_contact_details = supplier.mobile_number.nil? ?
        supplier.email : supplier.mobile_number.humanize
      amount = payment.amount
      amount = amount.format(:symbol => false) << " " << amount.currency.iso_code
      I18n.t(
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
end
