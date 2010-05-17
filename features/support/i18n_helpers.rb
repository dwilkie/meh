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

    when /^order not found when confirming order$/
      "activemodel.errors.models.abstract_confirm_order_conversation/abstract_message.attributes.order.blank"

    when /^unauthorized message action$/
      "messages.unauthorized"
      
    when /^order already confirmed$/
      "messages.order_already_confirmed"
      
    when /^confirm reject order for sellers product$/
      "messages.confirm_reject_order_for_sellers_product"

    when /^confirm reject order for own product$/
      "messages.confirm_reject_order_for_own_product"

    else
      raise "Can't find mapping from \"#{translation_name}\" to a translation.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(I18nHelpers)

