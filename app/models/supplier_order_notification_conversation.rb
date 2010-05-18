class SupplierOrderNotificationConversation < AbstractConversation
  def move_along!(order)
    supplier = order.supplier
    seller = order.product.seller
    
    message = (seller == supplier) ?
              message_for_own_product(order, supplier) :
              message_for_sellers_product(order, supplier, seller)

    say message
  end
  
  private
    def message_for_own_product(order, supplier)
      I18n.t(
        "messages.supplier_order_notification_for_own_product",
        message_params(order, supplier)
      )
    end
    
    def message_for_sellers_product(order, supplier, seller)
      I18n.t(
        "messages.supplier_order_notification_for_sellers_product",
        message_params(order, supplier).merge!(
          message_params_for_sellers_product(seller)
        )
      )
    end
    
    def message_params(order, supplier)
      {
        :supplier => supplier.name,
        :quantity => order.quantity,
        :product_code => order.product.external_id,
        :order_number => order.id
       }
    end
    
    def message_params_for_sellers_product(seller)
      seller_contact_details = seller.mobile_number.nil? ?
        seller.email : seller.mobile_number.number.humanize
      {
        :seller => seller.name,
        :seller_contact_details => seller_contact_details
      }
    end
end
