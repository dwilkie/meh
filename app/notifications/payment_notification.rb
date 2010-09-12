class PaymentNotification < Conversation
  def did_not_pay(payment, options = {})
    options[:seller] ||= payment.seller
    options[:supplier] ||= payment.supplier
    options[:supplier_mobile_number] ||= Notification::EVENT_ATTRIBUTES[:supplier][:supplier_mobile_number].call(:supplier => options[:supplier])
    options[:supplier_order] ||= payment.supplier_order
    options[:product] ||= options[:supplier_order].product
    options[:errors] ||= payment.errors
    options[:errors] = options[:errors].full_messages.to_sentence if
      options[:errors].is_a?(Array)

    say I18n.t(
      "notifications.messages.built_in.we_did_not_pay_your_supplier",
      :seller_name => options[:seller].name,
      :supplier_name => options[:supplier].name,
      :supplier_mobile_number => Notification::EVENT_ATTRIBUTES[:supplier][:supplier_mobile_number].call(:supplier => options[:supplier]),
      :supplier_order_quantity => options[:supplier_order].quantity,
      :product_number => options[:product].number,
      :product_name => options[:product].name,
      :errors => options[:errors]
    )
  end
end

