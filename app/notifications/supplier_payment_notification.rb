class SupplierPaymentNotification < Conversation
  def did_not_pay(supplier_payment, options = {})
    options[:seller] ||= supplier_payment.seller
    options[:supplier] ||= supplier_payment.supplier
    options[:supplier_mobile_number] ||= Notification::EVENT_ATTRIBUTES[:supplier][:supplier_mobile_number].call(:supplier => options[:supplier])
    options[:supplier_order] ||= supplier_payment.supplier_order
    options[:product] ||= options[:supplier_order].product

    options[:errors] ||= supplier_payment.errors
    options[:errors] = options[:errors].full_messages.to_sentence if
      options[:errors].is_a?(Hash)
    error_words = options[:errors].split
    error_words.first.try(:downcase!)
    error_words = error_words.first == "the" ?
      error_words[1..-1] : error_words
    options[:errors] = error_words.join(" ")

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
