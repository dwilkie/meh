class PaypalIpnObserver < ActiveRecord::Observer
  def after_verify(paypal_ipn, transition)
    create_customer_order(paypal_ipn)
    create_supplier_orders(paypal_ipn)
  end

  private
    def create_customer_order(paypal_ipn)

    end

    def create_supplier_orders(paypal_ipn, customer_order)
      paypal_ipn.params["num_cart_items"].to_i.times do |index|
        product = paypal_ipn.seller.selling_products.where(
          "external_id = ?",
          paypal_ipn.params["item_number#{index + 1}"]
        ).first
        customer_order.supplier_orders.create(
          :product => product,
          :supplier => product.supplier,
          :quantity => paypal_ipn.params["quantity#{index + 1}"].to_i
        )
      end
    end
end

