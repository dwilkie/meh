module I18nHelpers
  # Maps a name to a key so they are more readable
  # in the cucumber steps
  def translation_key(translation_name, options = {})
    case translation_name

    when /^supplier order notification$/
      "messages.supplier_order_notification"

    when /^not matching order quantity$/
      "errors.messages.not_matching_order_quantity"
      
    when /^not matching pv code$/
      "errors.messages.not_matching_product_verification_code"

    when /^order not found when processing order$/
      "activemodel.errors.models.abstract_process_order_conversation/order_message.attributes.order.blank"

    when /^unauthorized message action$/
      "messages.unauthorized"
      
    when /^cannot process order$/
      "messages.cannot_process_order"
      
    when /^confirm reject order$/
      "messages.confirm_reject_order"
      
    when /^confirmation invalid when rejecting an order$/
      "activemodel.errors.models.rejectorder_conversation/reject_order_message.attributes.confirmation.invalid"
    
    when /^supplier processed seller's order$/
      "messages.supplier_processed_sellers_order_notification"
      
    when /^confirm payment$/
      "messages.confirm_payment_notification"

    when /^successfully processed order$/
      "messages.successfully_processed_order"

    when /^mobile pin number blank$/
      "activemodel.errors.models.not_authenticated_conversation/unauthenticated_message.attributes.pin_number.blank"

    when /^mobile pin number format invalid$/
      "activemodel.errors.models.not_authenticated_conversation/unauthenticated_message.attributes.pin_number.invalid"
      
    when /^mobile pin number incorrect$/
      "activemodel.errors.models.not_authenticated_conversation/unauthenticated_message.attributes.pin_number.incorrect"

    when /^payment not greater than$/
      "activerecord.errors.models.payment.attributes.cents.greater_than"

    when /^payment already exists for this order$/
      "activerecord.errors.models.payment.attributes.supplier_order_id.taken"

    when /^order details$/
      "messages.order_details_notification"

    else
      raise "Can't find mapping from \"#{translation_name}\" to a translation.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(I18nHelpers)

