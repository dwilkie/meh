class PaypalIpnObserver < ActiveRecord::Observer
  def after_verify(paypal_ipn, transition)
    link_seller(paypal_ipn)
    create_supplier_orders(paypal_ipn)
  end

  private
    # This automatically creates the seller order
    def link_seller(paypal_ipn)
      paypal_ipn.update_attributes!(
        :seller => User.with_role("seller").where(
          ["email = ?", paypal_ipn.params["receiver_email"]]
        ).first
      )
    end

    def create_supplier_orders(paypal_ipn)
      seller_order = paypal_ipn.seller_order
      paypal_ipn.params["num_cart_items"].to_i.times do |index|
        product = seller_order.seller.selling_products.where(
          "external_id = ?",
          paypal_ipn.params["item_number#{index + 1}"]
        ).first
        seller_order.supplier_orders.create!(
          :product => product,
          :supplier => product.supplier,
          :quantity => paypal_ipn.params["quantity#{index + 1}"].to_i
        )
      end
    end
end

