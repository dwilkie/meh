class SupplierOrderNotificationConversation < AbstractConversation

  def move_along!(order)
    say notification_for_new(order)
  end
  
  private
    def notification_for_new(order)
      product = order.product
      seller = product.seller
      seller = nil if seller == user
      if seller
        seller_name = seller.name
        seller_mobile_number = seller.mobile_number
        seller_contact_details = seller_mobile_number.nil? ?
          seller.email : seller_mobile_number.humanize
      end
      I18n.t(
        "messages.supplier_order_notification",
        :supplier => user.name,
        :quantity => order.quantity,
        :product_code => product.external_id,
        :order_number => order.id,
        :seller => seller_name,
        :seller_contact_details => seller_contact_details
      )
    end
end
