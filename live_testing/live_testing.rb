# usage
# rails c
# require .'/live_testing/live_testing'
# LiveTesting::PaymentRequestTest.execute
module LiveTesting
  require 'factory_girl'
  require File.expand_path(File.dirname(__FILE__) + '/../spec/factories')
  class PaymentRequestTest
    TEST_USERS = {
      :paypal_sandbox_seller_email => "someone@example.com",
      :paypal_sandbox_supplier_email => "someone_else@example.com"
    }
    def self.execute
      seller = find_or_create_user!(:seller)
      supplier = find_or_create_user!(:supplier)
      find_or_create_payment_agreement!(seller, supplier)
      product = find_or_create_product!(seller, supplier)
      delete_old_records
      simulate_paypal_ipn!(seller, product)
    end

    private

     def self.find_or_create_user!(role)
       user = User.with_role(role).first || Factory.build(role)
       user.email = TEST_USERS["paypal_sandbox_#{role}_email".to_sym]
       user.save!
       user
     end

     def self.find_or_create_payment_agreement!(seller, supplier)
       payment_agreement = PaymentAgreement.where(
         :seller_id => seller.id,
         :supplier_id => supplier.id
       ).first || Factory.build(
         :payment_agreement,
         :seller => seller,
         :supplier => supplier
       )
       payment_agreement.event = "product_order_created"
       payment_agreement.save!
       payment_agreement
     end

     def self.find_or_create_product!(seller, supplier)
       product = Product.where(
         :seller_id => seller.id,
         :supplier_id => supplier.id
       ).first || Factory.build(
         :product,
         :seller => seller,
         :supplier => supplier
       )
       product.cents = 50000
       product.currency = "AUD"
       product.save!
       product
     end

     def self.simulate_paypal_ipn!(seller, product)
       paypal_ipn = Factory.build(
         :paypal_ipn,
         :seller => seller,
         :payment_status => "Completed"
       )
       request_params = paypal_ipn.params.merge(
        "item_number1" => product.number.to_s,
       )
       request_params = {
         "paypal_ipn" => request_params
       }
       exec("curl", "-d \"#{request_params.to_query}\"", "http://localhost:3000/paypal_ipns")
     end

     def self.delete_old_records
       PaymentRequest.delete_all
       Payment.delete_all
       SupplierOrder.delete_all
       SellerOrder.delete_all
       PaypalIpn.delete_all
     end
  end
end

