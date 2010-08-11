class SellerOrderNotification < Conversation
  def products_not_found(seller_order, number_of_missing_products, number_of_items)
    say I18n.t(
      "messages.products_not_found_notification",
      :seller => seller_order.seller.name,
      :seller_order_number => seller_order.id.to_s,
      :number_of_missing_products => number_of_missing_products,
      :number_of_items => number_of_items
    )
  end
end

