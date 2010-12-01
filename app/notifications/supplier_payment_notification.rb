class SupplierPaymentNotification < Conversation
  def did_not_pay(supplier_payment, options = {})
    populate_interpolations(supplier_payment, options)
    self.payer = options[:seller]
    say I18n.t(
      "notifications.messages.built_in.we_did_not_pay_your_supplier",
      :seller_name => options[:seller].name,
      :supplier_name => options[:supplier].name,
      :supplier_mobile_number => options[:supplier].active_mobile_number.humanize,
      :seller_order_number => options[:seller_order].id.to_s,
      :errors => options[:errors]
    )
  end

  def populate_interpolations(supplier_payment, options = {})
    options[:seller] ||= supplier_payment.seller
    options[:supplier] ||= supplier_payment.supplier
    options[:supplier_order] ||= supplier_payment.supplier_order
    options[:seller_order] ||= options[:supplier_order].seller_order
  end

  def unclaimed_for_seller(supplier_payment)
    options = {:seller => user}
    populate_interpolations(supplier_payment, options)
    say I18n.t(
      "notifications.messages.built_in.we_paid_your_supplier_but_the_payment_was_unclaimed",
      :seller_name => user.name,
      :supplier_name => options[:supplier].name,
      :supplier_mobile_number => options[:supplier_mobile_number],
      :supplier_email => options[:supplier].email,
      :supplier_payment_amount => supplier_payment.amount.to_s,
      :supplier_payment_currency => supplier_payment.amount.currency.to_s,
      :seller_order_number => options[:seller_order].id.to_s
    )
  end

  def unclaimed_for_supplier(supplier_payment)
    options = {:supplier => user}
    populate_interpolations(supplier_payment, options)
    say I18n.t(
      "notifications.messages.built_in.open_a_paypal_account_to_claim_your_payment",
      :seller_name => options[:seller].name,
      :supplier_name => user.name,
      :seller_mobile_number => options[:seller_mobile_number],
      :supplier_order_number => options[:supplier_order].id.to_s,
      :supplier_payment_amount => supplier_payment.amount.to_s,
      :supplier_payment_currency => supplier_payment.amount.currency.to_s
    )
  end
end

