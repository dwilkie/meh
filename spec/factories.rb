Factory.define :user do |f|
  f.sequence(:email) {|n| "user#{n}@example.com" }
  f.password "foobar"
  f.password_confirmation { |u| u.password }
  f.name "Maggot"
end

Factory.define :seller, :class => User do |f|
  f.sequence(:email) {|n| "seller#{n}@example.com" }
  f.roles ["seller"]
  f.password "foobar"
  f.password_confirmation { |u| u.password }
  f.name "Chris"
end

Factory.define :supplier, :class => User do |f|
  f.sequence(:email) {|n| "supplier#{n}@example.com" }
  f.roles ["supplier"]
  f.password "foobar"
  f.password_confirmation { |u| u.password }
  f.name "Bob"
end

Factory.define :mobile_number do |f|
  f.sequence(:number) {|n| "+618148229#{n}" }
  f.association :user
end

Factory.define :verified_mobile_number, :class => MobileNumber do |f|
  f.sequence(:number) {|n| "+618148229#{n}" }
  f.verified_at Time.now
  f.association :user
end

Factory.define :product do |f|
  f.association :supplier
  f.association :seller
  f.sequence(:number) {|n| "1234#{n}"}
  f.sequence(:name) {|n| "Some Manky Product #{n}"}
  f.verification_code "meh"
end

Factory.define :seller_order do |f|
  f.association :seller
  f.order_notification {|seller_order|
    seller_order.association(:paypal_ipn, :seller => seller_order.seller)
  }
end

Factory.define :supplier_order do |f|
  f.association :seller_order
  f.association :product
  f.quantity 5
end

Factory.define :outgoing_text_message do |f|
  f.association :mobile_number
end

Factory.define :notification do |f|
  f.association :seller
  f.purpose "something"
  f.should_send true
  f.enabled true
  f.message "some message"
  f.event {
    Notification::EVENTS.keys.first.to_s
  }
  f.for {
    User::ROLES.first
  }
end

Factory.define :tracking_number_format do |f|
  f.association :seller
end

Factory.define :sent_outgoing_text_message, :class => OutgoingTextMessage do |f|
  f.association :mobile_number
  f.sequence(:gateway_message_id) { |n|
    "SMSGlobalMsgID:694274449499974#{n}"
  }
end

Factory.define :incoming_text_message do |f|
  f.association :mobile_number
  f.params { |itm|
    userfield = ENV["SMS_AUTHENTICATION_KEY"]
    mobile_number = itm.mobile_number.number
    {
      "to" => "61447100308",
      "from" => mobile_number,
      "msg"=> "Endia kasdf ofeao",
      "userfield" => userfield,
      "date" => "2010-05-13 23:59:11"
    }
  }
end

Factory.define :text_message_delivery_receipt do |f|
  f.association :outgoing_text_message, :factory => :sent_outgoing_text_message
  f.params { |text_message_delivery_receipt|
    msgid = text_message_delivery_receipt.outgoing_text_message.gateway_message_id.gsub(
      "SMSGlobalMsgID:", ""
    )
    {
      "msgid" => msgid
    }
  }
end

Factory.define :paypal_ipn do |f|
  f.sequence(:transaction_id) {|n| "45D21472YD182004#{n}" }
  f.params { |paypal_ipn|
    seller = paypal_ipn.seller || Factory.create(:seller)
    {
      "payment_status" => paypal_ipn.payment_status,
      "receiver_email" => seller.email,
      "txn_id" => paypal_ipn.transaction_id,
      "item_number" => "12345790062",
      "item_name" => "Model Ship - The Rubber Dingy",
      "quantity" => "1"
    }
  }
end

Factory.define :payment do |f|
  f.association :supplier_order
  f.association :supplier
  f.seller { |payment|
    payment_application = Factory(:verified_payment_application)
    payment_application.seller
  }
  f.cents 100000
  f.currency "THB"
end

Factory.define :payment_agreement do |f|
  f.event {
    PaymentAgreement::EVENTS.first
  }
  f.association :seller
  f.association :supplier
end

Factory.define :payment_request do |f|
end

Factory.define :payment_application do |f|
  f.uri "http://example.com"
  f.association :seller
end

Factory.define :verified_payment_application, :class => PaymentApplication do |f|
  f.uri "http://example.com"
  f.association :seller
  f.verified_at Time.now
end

Factory.define :job, :class => Delayed::Job do |f|
end

