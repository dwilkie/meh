class SupplierOrderNotification < Conversation
  def event_attributes(supplier_order)
    seller_order = supplier_order.seller_order
    seller = seller_order.seller
    supplier = supplier_order.supplier
    {
      :supplier_order_number => supplier_order.id.to_s,
      :seller_order_number => seller_order.id.to_s,
      :supplier_name => supplier.name,
      :seller_name => seller.name,
      :supplier_mobile_number => supplier.mobile_number.humanize,
      :seller_mobile_number => seller.mobile_number.humanize
    }
  end

  def details(supplier_order)
    say I18n.t(
      "messages.order_details_notification",
      :supplier => user.name,
      :order_number => supplier_order.id,
      :product_code => supplier_order.product.item_number,
      :details => supplier_order_details(supplier_order)
    )
  end

  def notification_for_new(supplier_order)
    product = supplier_order.product
    seller = product.seller
    seller = nil if seller == user
    if seller
      seller_name = seller.name
      seller_mobile_number = seller.mobile_number.humanize
    end
    say I18n.t(
      "messages.supplier_order_notification",
      :supplier => user.name,
      :quantity => supplier_order.quantity,
      :product_code => product.item_number,
      :order_number => supplier_order.id,
      :seller => seller_name,
      :seller_contact_details => seller_mobile_number
    )
  end

  def notify_seller(supplier_order)
    supplier = supplier_order.supplier
    supplier_mobile_number = supplier.mobile_number.humanize
    say I18n.t(
      "messages.supplier_processed_sellers_order_notification",
      :seller => user.name,
      :supplier => supplier.name,
      :supplier_contact_details => supplier_mobile_number,
      :supplier_order_number => supplier_order.id,
      :seller_order_number => supplier_order.seller_order.id,
      :quantity => supplier_order.quantity,
      :product_code => supplier_order.product.item_number,
      :processed => supplier_order.status
    )
  end

  private
    def supplier_order_details(supplier_order)
      # this code will get moved later
      # but do not move it into the paypal_ipn class
      # the seller should be able to customize the details as they see fit
      # so it belongs somewhere else...
      order_notification_params = supplier_order.seller_order.order_notification.params

      order_notification_params["address_name"] ||= ""
      order_notification_params["address_street"] ||= ""
      order_notification_params["address_city"] ||= ""
      order_notification_params["address_state"] ||= ""
      order_notification_params["address_zip"] ||= ""
      order_notification_params["address_country"] ||= ""

      supplier_order_details = "Please send the "
      supplier_order_details += supplier_order.quantity > 1 ? "product".pluralize : "product"
      supplier_order_details += " to the following address:" << "\n"
        order_notification_params["address_name"] << ",\n" <<
        order_notification_params["address_street"] << ",\n" <<
        order_notification_params["address_city"] << ",\n" <<
        order_notification_params["address_state"] << ",\n" <<
        order_notification_params["address_zip"] << ",\n" <<
        order_notification_params["address_country"]
    end


end

