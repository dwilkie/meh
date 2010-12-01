module I18nHelpers
  # Maps a name to a key so they are more readable
  # in the cucumber steps
  def translation_key(translation_name, options = {})
    case translation_name

    when /^you have no line items to confirm$/
      "notifications.messages.built_in.you_have_no_line_items_to_confirm"

    when /^you have no orders to complete$/
      "notifications.messages.built_in.you_have_no_orders_to_complete"

    when /^be specific about the line item number$/
      "notifications.messages.built_in.be_specific_about_the_line_item_number"

    when /^be specific about the order number$/
      "notifications.messages.built_in.be_specific_about_the_order_number"

    when /^you must confirm the line items first$/
      "notifications.messages.built_in.you_must_confirm_the_line_items_first"

    when /^verify your mobile number$/
      "notifications.messages.built_in.verify_your_mobile_number"

    when /^your mobile number is verified$/
      "notifications.messages.built_in.your_mobile_number_is_verified"

    when /^we paid your supplier but the payment was unclaimed$/
      "notifications.messages.built_in.we_paid_your_supplier_but_the_payment_was_unclaimed"

    when /^open a paypal account to claim your payment$/
      "notifications.messages.built_in.open_a_paypal_account_to_claim_your_payment"

    when /^valid message commands are$/
      "notifications.messages.built_in.valid_message_commands_are"

    when /^you do not have enough message credits left$/
      "notifications.messages.built_in.you_do_not_have_enough_message_credits_left"

    when /^name is incorrect$/
      "activemodel.errors.models.unknown_topic_conversation.verify_mobile_number_message.attributes.name.incorrect"

    when /^line item quantity must be confirmed$/
      "activemodel.errors.models.line_item_conversation.confirm_line_item_message.attributes.quantity.blank"

    when /^tracking number already used by you$/
      "activerecord.errors.models.supplier_order.attributes.tracking_number.taken"

    when /^tracking number is invalid$/
      "activemodel.errors.models.order_conversation.complete_order_message.attributes.tracking_number.invalid"

    when /^supplier payment amount invalid$/
      "activerecord.errors.models.supplier_payment.attributes.amount.greater_than"

    when /^insufficient funds for supplier payment$/
      "activerecord.errors.models.supplier_payment.payment.insufficient_funds"

    when /^unauthorized supplier payment$/
      "activerecord.errors.models.supplier_payment.payment.unauthorized"

    when /^unknown error for supplier payment$/
      "activerecord.errors.models.supplier_payment.payment.unknown"

    when /^# does not exist$/
      "errors.messages.does_not_exist"

    when /^is required$/
      "errors.messages.blank"

    when /^is incorrect$/
      "errors.messages.incorrect"

    else
      raise "Can't find mapping from \"#{translation_name}\" to a translation.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(I18nHelpers)

