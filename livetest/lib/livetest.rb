# Sets up the development environment ready for a live paypal ipn simulation
# store mobile numbers in ~/.bashrc
require 'factory_girl'
require File.expand_path(File.dirname(__FILE__) + '/../../spec/factories')
require 'ruby-debug'
class Test
  PARAMS = {
    :test_users => {
      :paypal_sandbox_seller_email => "mehsel_1273155831_biz@gmail.com",
      :paypal_sandbox_supplier_email => "mehsau_1273220241_biz@gmail.com"
    },
    :payment_application_uri => "http://meh-payment-processor.appspot.com",
    :paypal_item_number => "AK-1234",
    :seller_mobile_number => ENV['LIVE_TESTING_SELLER_MOBILE_NUMBER'].clone
  }

  def self.setup
    seller = find_or_create_user!(:seller)
    supplier = find_or_create_user!(:supplier)
    find_or_create_payment_agreement!(seller, supplier)
    find_or_create_product!(seller, supplier)
    find_or_create_payment_application!(seller)
    delete_old_records
    clear_jobs
  end

 def self.paypal_ipn_query_string
    {
      "paypal_ipn" => {
        "test_ipn" => "1",
        "payment_type" => "echeck",
        "payment_date" => "00:22:48 Sep 14, 2010 PDT",
        "payment_status" => "Completed",
        "address_status" => "confirmed",
        "payer_status" => "verified",
        "first_name" => "John",
        "last_name" => "Smith",
        "payer_email" => "buyer@paypalsandbox.com",
        "payer_id" => "TESTBUYERID01",
        "address_name" => "John Smith",
        "address_country" => "United States",
        "address_country_code" => "US",
        "address_zip" => "95131",
        "address_state" => "CA",
        "address_city" => "San Jose",
        "address_street" => "123, any street",
        "business" => PARAMS[:test_users][:paypal_sandbox_seller_email],
        "receiver_email" => PARAMS[:test_users][:paypal_sandbox_seller_email],
        "receiver_id" => "TESTSELLERID1",
        "residence_country" => "US",
        "item_name" => "something",
        "item_number" => PARAMS[:paypal_item_number],
        "quantity" => "1",
        "shipping" => "3.04",
        "tax" => "2.02",
        "mc_currency" => "USD",
        "mc_fee" => "0.44",
        "mc_gross" => "12.34",
        "txn_type" => "web_accept",
        "txn_id" => "48914722",
        "notify_version" => "2.1",
        "custom" => "xyz123",
        "invoice" => "abc1234",
        "charset" => "windows-1252",
        "verify_sign" => "Al7mV6GyvDK8l7eTXLC6nVSXyKxXAZ6i5PT53tze8XPlm.B8n-2X-DV2"
      }
    }.to_query
 end

  def self.create_mobile_number(role, number)
    user = find_or_create_user!(role)
    mobile_number = user.mobile_numbers.find_by_number(number)
    MobileNumber.create(
      :number => number, :user => user
    ) unless mobile_number
  end

  private
    def self.find_or_create_user!(role)
      user = User.with_role(role).first || Factory.build(role)
      user.email = PARAMS[:test_users]["paypal_sandbox_#{role.to_s}_email".to_sym]
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
     product.cents = 2000
     product.currency = "AUD"
     product.number = PARAMS[:paypal_item_number]
     product.save!
     product
   end

   def self.find_or_create_payment_application!(seller)
     payment_application = seller.payment_application ||
       Factory.build(
         :payment_application,
         :seller => seller
       )
     payment_application.uri = PARAMS[:payment_application_uri]
     payment_application.save!
   end

   def self.delete_old_records
     PaymentRequest.delete_all
     Payment.delete_all
     SupplierOrder.delete_all
     SellerOrder.delete_all
     PaypalIpn.delete_all
     IncomingTextMessage.delete_all
   end

   def self.clear_jobs
     Delayed::Job.delete_all
   end

end

