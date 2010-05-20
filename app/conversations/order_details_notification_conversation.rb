class OrderDetailsNotificationConversation < AbstractConversation
  def move_along!(order)
    say order_details(order)
  end
  
  private
    def order_details(order)
      I18n.t(
        "messages.order_details",
        :supplier => user.name,
        :order_number => order.id,
        :product_code => order.product.external_id,
        :details => order.details
      )
    end
end
