class AbstractSellerNotificationConversation < AbstractConversation
  protected
    def notify_seller(order, message, options = {})
      supplier = order.supplier
      supplier_contact_details = supplier.mobile_number.nil? ?
        supplier.email : supplier.mobile_number.humanize
      I18n.t(
        message,
        :seller => user.name,
        :supplier => supplier.name,
        :supplier_contact_details => supplier_contact_details,
        :supplier_order_number => order.id,
        :customer_order_number => order.seller_order.id,
        :quantity => order.quantity,
        :amount => options[:amount],
        :product_code => order.product.external_id,
        :processed => order.status,
        :errors => options[:errors]
      )
    end
end
