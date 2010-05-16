module I18nHelpers
  # Maps a name to a key so they are more readable
  # in the cucumber steps
  def translation_key(translation_name, options = {})
    case translation_name

    when /^supplier order notification for sellers product$/
      "messages.supplier_order_notification_for_sellers_product"
      
    when /^supplier order notification for own product$/
      "messages.supplier_order_notification_for_own_product"
      
    when /^not matching order quantity$/
      "errors.messages.not_matching_order_quantity"
      
    when /^not matching pv code$/
      "errors.messages.not_matching_product_verification_code"

    when /^order not found when accepting order$/
      "activemodel.errors.models.acceptorder_conversation/accept_order_message.attributes.order.blank"

    when /^unauthorized message action$/
      "messages.unauthorized"
      
    when /^order already confirmed$/
      "messages.order_already_confirmed"

    else
      raise "Can't find mapping from \"#{translation_name}\" to a translation.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(I18nHelpers)

