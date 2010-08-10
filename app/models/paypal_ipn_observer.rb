class PaypalIpnObserver < ActiveRecord::Observer
  def after_update(paypal_ipn)
    create_supplier_orders(paypal_ipn) if paypal_ipn.verified_at_changed? && paypal_ipn.payment_completed?
  end

  private
    def create_supplier_orders(paypal_ipn)
      seller = paypal_ipn.seller
      seller_order = paypal_ipn.seller_order
      number_of_missing_products = 0
      paypal_ipn.number_of_cart_items.times do |index|
        item_number = paypal_ipn.item_number(index)
        item_quantity = paypal_ipn.item_quantity(index)
        product = seller.selling_products.where(
          "external_id = ?", item_number
        ).first
        if product
          seller_order.supplier_orders.create!(
            :product => product,
            :supplier => product.supplier,
            :quantity => item_quantity
          )
        else
          number_of_missing_products += 1
        end
      end
      SellerOrderNotification.new(
        :with => seller
      ).products_not_found(
        seller_order,
        number_of_missing_products,
        paypal_ipn.number_of_cart_items
      ) if number_of_missing_products > 0
    end
end

