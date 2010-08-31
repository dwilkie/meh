module I18nHelpers
  # Maps a name to a key so they are more readable
  # in the cucumber steps
  def translation_key(translation_name, options = {})
    case translation_name

    when /^a customer completed payment for\.\.\.$/
       "notifications.messages.a_customer_completed_payment_for"

    when /^product order was sent to\.\.\.$/
      "notifications.messages.supplier_order_was_sent_to"

    when /^you have a new product order from\.\.\. for the following item\.\.\.$/
      "notifications.messages.new_supplier_order_from_seller_for_the_following_item"

    when /^your customer bought the following item\.\.\.$/
      "notifications.messages.your_customer_bought_the_following_item"

    when /^your supplier processed their product order\.\.\.$/
      "notifications.messages.your_supplier_processed_their_supplier_order"

    when /^you successfully processed the product order\.\.\.$/
      "notifications.messages.you_successfully_processed_the_supplier_order"

    when /^send the product to\.\.\.$/
      "notifications.messages.send_the_product_to"

    when /^you do not have any supplier orders$/
      "notifications.messages.built_in.you_do_not_have_any_supplier_orders"

    when /^supplier order was already confirmed$/
      "notifications.messages.built_in.supplier_order_was_already_confirmed"

    when /^be specific about the supplier order number$/
      "notifications.messages.built_in.be_specific_about_the_supplier_order_number"

    when /^your pin number is incorrect$/
      "notifications.messages.built_in.your_pin_number_is_incorrect"

    when /^invalid action given for the supplier order$/
      "notifications.messages.built_in.invalid_action_for_supplier_order"

    when /^what would you like to do with the supplier order\?$/
      "notifications.messages.built_in.no_action_for_supplier_order"

    when /^is incorrect$/
      "errors.messages.incorrect"

    when /^order quantity is blank$/
      "activemodel.errors.models.supplier_order_conversation/accept_supplier_order_message.attributes.quantity.blank"

    when /^product verification code is blank$/
      "activemodel.errors.models.supplier_order_conversation/accept_supplier_order_message.attributes.product_verification_code.blank"



    when /^supplier order notification$/
      "messages.supplier_order_notification"


    when /^not matching pv code$/
      "errors.messages.not_matching_product_verification_code"

    when /^order not found when processing order$/
      "activemodel.errors.models.abstract_process_order_conversation/supplier_order_message.attributes.order.blank"

    when /^order not found when pay4order$/
      "activemodel.errors.models.pay4order_conversation/message.blank"

    when /^unauthorized message action$/
      "messages.unauthorized"

    when /^cannot process order$/
      "messages.cannot_process_order"

    when /^confirm reject order$/
      "messages.confirm_reject_order"

    when /^confirmation invalid when rejecting an order$/
      "activemodel.errors.models.rejectorder_conversation/message.attributes.confirmation.invalid"

    when /^confirmation invalid when pay4order$/
      "activemodel.errors.models.pay4order_conversation/message.attributes.confirmation.invalid"

    when /^supplier processed seller's order$/
      "messages.supplier_processed_sellers_order_notification"

    when /^confirm payment$/
      "messages.confirm_payment_notification"

    when /^successfully processed order$/
      "messages.successfully_processed_order"

    when /^mobile pin number blank$/
      "activemodel.errors.models.abstract_authenticated_conversation/message.attributes.pin_number.blank"

    when /^mobile pin number format invalid$/
      "activemodel.errors.models.abstract_authenticated_conversation/message.attributes.pin_number.invalid"

    when /^mobile pin number incorrect$/
      "activemodel.errors.models.abstract_authenticated_conversation/message.attributes.pin_number.incorrect"

    when /^payment not greater than$/
      "activerecord.errors.models.payment.attributes.cents.greater_than"

    when /^payment already exists for this order$/
      "activerecord.errors.models.payment.attributes.supplier_order_id.taken"

    when /^invalid payment application$/
      "messages.payment_application_invalid"

    when /^order details$/
      "messages.order_details_notification"

    when /^payee not found error$/
      "activerecord.errors.models.payment_request.attributes.notification.payee_not_found"

    when /^payee maximum amount exceeded error$/
      "activerecord.errors.models.payment_request.attributes.notification.payee_maximum_amount_exceeded"

    when /^payee currency invalid error$/
      "activerecord.errors.models.payment_request.attributes.notification.payee_currency_invalid"

    when /^payment request notification$/
      "messages.payment_request_notification"

    when /^products not found notification$/
      "messages.products_not_found_notification"

    when /^invalid attribute$/
      "errors.messages.invalid"

    when /^invalid command$/
      "messages.invalid_command"

    when /^the welcome message$/
      "messages.welcome"

    else
      raise "Can't find mapping from \"#{translation_name}\" to a translation.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(I18nHelpers)

