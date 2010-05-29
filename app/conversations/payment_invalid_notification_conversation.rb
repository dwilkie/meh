class PaymentInvalidNotificationConversation < AbstractConversation
  def move_along!(payment)
    say invalid(payment)
  end
  
  private
    def invalid(payment)
      supplier_order = payment.supplier_order
      supplier = supplier_order.supplier
      supplier_contact_details = supplier.mobile_number.nil? ?
        supplier.email : supplier.mobile_number.humanize
      I18n.t(
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
end
