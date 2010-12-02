# Sets up the development environment ready for a live paypal ipn simulation
# store mobile numbers in ~/.bashrc
class Test
  PARAMS = {
    :test_users => {
      :paypal_sandbox_seller_email => "mehsau_1273220241_biz@gmail.com",
      :paypal_sandbox_supplier_email => "mehbuy_1272942317_per@gmail.com"
    },
    :paypal_item_number => "AK-1234",
    :seller_mobile_number => ENV['LIVE_TESTING_SELLER_MOBILE_NUMBER'].clone,
    :supplier_mobile_number => ENV['LIVE_TESTING_SUPPLIER_MOBILE_NUMBER'].clone,
    :seller_name => "Dave",
    :supplier_name => "Mara"
  }

  def self.setup(options = {})
    delete_old_records(:clear_all => options[:clear_all])
    clear_jobs
    seller = find_or_create_user!(:seller, :name => options[:seller_name])
    supplier = find_or_create_user!(:supplier, :name => options[:supplier_name])
    find_or_create_payment_agreement!(seller, supplier)
    find_or_create_product!(seller, supplier)
  end

  def self.incoming_text_message_query_string(options = {})
    params = {
      "to" => "61447100308",
      "from" => "9999999999",
      "msg" => "Change me",
      "userfield" => ENV["SMS_AUTHENTICATION_KEY"],
      "date" => Time.now
    }
    params = {"incoming_text_message" => params} if options[:normalized]
    params.to_query
  end

  def self.paypal_ipn_query_string(options = {})
    params = {
      "test_ipn" => "1",
      "payment_type" => "instant",
      "payment_date" => "04:18:32 Sep 26, 2010 PDT",
      "payment_status" => "Completed",
      "address_status" => "confirmed",
      "payer_status" => "verified",
      "first_name" => "Johnny",
      "last_name" => "Cash",
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
      "mc_gross_1" => "9.34",
      "txn_type" => "web_accept",
      "txn_id" => "329261118",
      "notify_version" => "2.1",
      "custom" => "xyz123",
      "charset" => "windows-1252",
      "verify_sign" => "AsB.P43alevcO3d40zFHcFtj820jAQtFf-UFrzn4uOboKhpgz6ovAGqS"
    }
    params = {"paypal_ipn" => params} if options[:normalized]
    params.to_query
  end

  def self.masspay_ipn_query_string(options = {})
    params = {
      "txn_type" => "masspay",
      "payment_gross_1" => "",
      "payment_date" => "04:53:59 Sep 26, 2010 PDT",
      "last_name" => "Wilkie",
      "mc_fee_1" => "0.40",
      "masspay_txn_id_1" => "5WA05208GC054924K",
      "receiver_email_1" => PARAMS[:test_users][:paypal_sandbox_supplier_email],
      "residence_country" => "AU",
      "verify_sign" => "An5ns1Kso7MWUdW4ErQKJJJ4qi4-AW3EFP4h.HWz6XXTRyfP27RKAfwb",
      "payer_status" => "verified",
      "test_ipn" => "1",
      "payer_email" => "mehsau_1273220241_biz@gmail.com",
      "first_name" => "David",
      "payment_fee_1" => "",
      "payer_id" => "6TFGKMB94YKU2",
      "payer_business_name" => "David Wilkie's Test Store",
      "payment_status" => "Completed",
      "status_1" => "Completed",
      "mc_gross_1" => "20.00",
      "charset" => "windows-1252",
      "notify_version" => "3.0",
      "mc_currency_1" => "AUD",
      "unique_id_1" => "2"
    }
    params = {"paypal_ipn" => params} if options[:normalized]
    params.to_query
  end

  def self.create_mobile_number(role, number)
    user = find_or_create_user!(role)
    mobile_number = user.mobile_numbers.find_by_number(number)
    MobileNumber.create(
      :number => number, :user => user
    ) unless mobile_number
  end

  private
    def self.find_or_create_user!(role, options = {})
      user = User.with_role(role).first || User.new
      if user.new_record?
        options[:name] ||= PARAMS["#{role}_name".to_sym]
        user.password = "foobar"
        user.password_confirmation = user.password
        user.new_role = role
        user.message_credits = 50
        user.name = options[:name]
        user.email = PARAMS[
          :test_users
        ]["paypal_sandbox_#{role.to_s}_email".to_sym]
        user.save!
      end
      user
    end

    def self.find_or_create_payment_agreement!(seller, supplier)
      payment_agreement = PaymentAgreement.where(
       :seller_id => seller.id, :supplier_id => supplier.id
     ).first
     unless payment_agreement
       payment_agreement = PaymentAgreement.new
       payment_agreement.seller = seller
       payment_agreement.supplier = supplier
     end
     payment_agreement.event = "supplier_order_confirmed"
     payment_agreement.save!
     payment_agreement
   end

   def self.find_or_create_product!(seller, supplier)
     product = Product.where(
       :seller_id => seller.id, :supplier_id => supplier.id
     ).first
     unless product
       product = Product.new
       product.seller = seller
       product.supplier = supplier
       product.name = "Some product"
     end
     product.supplier_payment_amount = "20"
     product.number = PARAMS[:paypal_item_number]
     product.save!
     product
   end

   def self.delete_old_records(options = {})
     SupplierPayment.delete_all
     LineItem.delete_all
     SupplierOrder.delete_all
     SellerOrder.delete_all
     PaypalIpn.delete_all
     IncomingTextMessage.delete_all
     OutgoingTextMessage.delete_all
     if options[:clear_all]
       MobileNumber.delete_all
       Notification.delete_all
       PaymentAgreement.delete_all
       Product.delete_all
       User.delete_all
     end
   end

   def self.clear_jobs
     Delayed::Job.delete_all
   end

end

