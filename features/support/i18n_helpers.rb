module I18nHelpers
  # Maps a name to a key so they are more readable
  # in the cucumber steps
  def translation_key(translation_name, options = {})
    case translation_name

    when /^supplier order notification for sellers product$/
      "messages.supplier_order_notification_for_sellers_product"
      
    when /^supplier order notification for own product$/
      "messages.supplier_order_notification_for_own_product"

    else
      raise "Can't find mapping from \"#{translation_name}\" to a translation.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(I18nHelpers)

