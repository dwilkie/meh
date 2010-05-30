class OrderNotification < AbstractConversation
  def details(order)
    say I18n.t(
      "messages.order_details_notification",
      :supplier => user.name,
      :order_number => order.id,
      :product_code => order.product.external_id,
      :details => order.details
    )
  end

  def notification_for_new(order)
    product = order.product
    seller = product.seller
    seller = nil if seller == user
    if seller
      seller_name = seller.name
      seller_mobile_number = seller.mobile_number
      seller_contact_details = contact_details(seller)
    end
    say I18n.t(
      "messages.supplier_order_notification",
      :supplier => user.name,
      :quantity => order.quantity,
      :product_code => product.external_id,
      :order_number => order.id,
      :seller => seller_name,
      :seller_contact_details => seller_contact_details
    )
  end
  
  def notify_seller(order)
    supplier = order.supplier
    supplier_contact_details = contact_details(supplier)
    say I18n.t(
      "messages.supplier_processed_sellers_order_notification",
      :seller => user.name,
      :supplier => supplier.name,
      :supplier_contact_details => supplier_contact_details,
      :supplier_order_number => order.id,
      :customer_order_number => order.seller_order.id,
      :quantity => order.quantity,
      :product_code => order.product.external_id,
      :processed => order.status
    )
  end
  
  private
    def contact_details(user)
      user.mobile_number.nil? ? user.email : user.mobile_number.humanize
    end

end
