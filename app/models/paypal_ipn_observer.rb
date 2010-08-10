class PaypalIpnObserver < ActiveRecord::Observer
  def after_update(paypal_ipn)
    create_supplier_orders(paypal_ipn) if paypal_ipn.verified_at_changed? && paypal_ipn.payment_completed?
  end

  private
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

