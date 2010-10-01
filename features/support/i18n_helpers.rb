module I18nHelpers
  # Maps a name to a key so they are more readable
  # in the cucumber steps
  def translation_key(translation_name, options = {})
    case translation_name

    when /^you do not have any supplier orders$/
      "notifications.messages.built_in.you_do_not_have_any_supplier_orders"

    when /^supplier order was already processed$/
      "notifications.messages.built_in.supplier_order_was_already_processed"

    when /^be specific about the supplier order number$/
      "notifications.messages.built_in.be_specific_about_the_supplier_order_number"

    when /^invalid action given for the supplier order$/
      "notifications.messages.built_in.invalid_action_for_supplier_order"

    when /^what would you like to do with the supplier order\?$/
      "notifications.messages.built_in.no_action_for_supplier_order"

    when /^you successfully processed the supplier order$/
      "notifications.messages.built_in.you_successfully_processed_the_supplier_order"

    when /^this tracking number was already used by you$/
      "notifications.messages.built_in.this_tracking_number_was_already_used_by_you"

    when /^the tracking number is missing or invalid$/
      "notifications.messages.built_in.the_tracking_number_is_missing_or_invalid"

    when /^you must accept the supplier order first$/
      "notifications.messages.built_in.you_must_accept_the_supplier_order_first"

    when /^verify your mobile number$/
      "notifications.messages.built_in.verify_your_mobile_number"

    when /^invalid action for mobile number$/
      "notifications.messages.built_in.invalid_action_for_mobile_number"

    when /^no action for mobile number$/
      "notifications.messages.built_in.no_action_for_mobile_number"

    when /^you successfully verified your mobile number$/
      "notifications.messages.built_in.you_successfully_verified_your_mobile_number"

    when /^we did not pay your supplier$/
      "notifications.messages.built_in.we_did_not_pay_your_supplier"

    when /^we paid your supplier but the payment was unclaimed$/
      "notifications.messages.built_in.we_paid_your_supplier_but_the_payment_was_unclaimed"

    when /^open a paypal account to claim your payment$/
      "notifications.messages.built_in.open_a_paypal_account_to_claim_your_payment"

    when /^the name is missing or incorrect$/
      "notifications.messages.built_in.the_name_is_missing_or_incorrect"

    when /^you must verify your mobile number to use this feature$/
      "notifications.messages.built_in.you_must_verify_your_mobile_number_to_use_this_feature"

    when /^valid message commands are$/
      "notifications.messages.built_in.valid_message_commands_are"

    when /^you do not have enough message credits left$/
      "notifications.messages.built_in.you_do_not_have_enough_message_credits_left"


    when /^name is incorrect$/
      "activemodel.errors.models.mobile_number_conversation/verify_mobile_number_message.attributes.name.incorrect"

    when /^is incorrect$/
      "errors.messages.incorrect"

    when /^order quantity must be confirmed$/
      "activemodel.errors.models.supplier_order_conversation/accept_supplier_order_message.attributes.quantity.blank"

    when /^is required$/
      "errors.messages.blank"

    else
      raise "Can't find mapping from \"#{translation_name}\" to a translation.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(I18nHelpers)

