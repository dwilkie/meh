Factory.sequence :message_id do |n|
  message_id = ActionSms::Base.sample_message_id
  message_id << n.to_s
end

Factory.sequence :transaction_id do |n|
  "45D21472YD182004#{n}"
end

Factory.define :incoming_text_message do |f|
  f.association :mobile_number
  f.params { |itm|
    ActionSms::Base.sample_incoming_sms(
      :from => itm.mobile_number.number,
      :authentic => true
    )
  }
end

Factory.define :job, :class => Delayed::Job do |f|
end

Factory.define :payment_agreement do |f|
  f.event {
    PaymentAgreement::EVENTS.first
  }
  f.association :seller
  f.association :supplier
end

Factory.define :partnership do |f|
  f.association :seller
  f.association :supplier
end

Factory.define :confirmed_partnership, :parent => :partnership do |f|
  f.confirmed_at Time.now
end

Factory.define :product do |f|
  f.association :seller
  f.association :partnership
  f.sequence(:number) {|n| "1234#{n}"}
  f.sequence(:name) {|n| "Some Manky Product #{n}"}
end

Factory.define :mobile_number do |f|
  f.sequence(:number) {|n| "+618148229#{n}" }
  f.association :user
end

Factory.define :verified_mobile_number, :parent => :mobile_number do |f|
  f.verified_at Time.now
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

Factory.define :outgoing_text_message do |f|
  f.association :mobile_number
end

Factory.define :sent_outgoing_text_message, :parent => :outgoing_text_message do |f|
  f.gateway_response ActionSms::Base.sample_delivery_response
  f.sent_at Time.now
end

Factory.define :user do |f|
  f.name "Mara"
  f.password "foobar"
  f.password_confirmation { |u| u.password }
end

Factory.define :seller, :parent => :user do |f|
  f.sequence(:email) {|n| "user#{n}@example.com" }
  f.roles ["seller"]
end

Factory.define :seller_order do |f|
  f.association :seller
  f.order_notification {|seller_order|
    seller_order.association(:seller_order_paypal_ipn, :seller => seller_order.seller)
  }
end

Factory.define :supplier_order do |f|
  f.association :supplier
  f.association :seller_order
  f.number_of_line_items 1
end

Factory.define :seller_order_paypal_ipn do |f|
  f.params { |paypal_ipn|
    seller = paypal_ipn.seller || Factory.create(:seller)
    {
      "txn_id" => Factory.next(:transaction_id),
      "receiver_email" => seller.email,
      "item_number" => "12345790062",
      "item_name" => "Model Ship - The Rubber Dingy",
      "quantity" => "1",
      "mc_currency" => "AUD",
      "mc_gross" => "100.00"
    }
  }
end

Factory.define :supplier, :parent => :user do |f|
  f.roles ["supplier"]
end

Factory.define :line_item do |f|
  f.association :supplier_order
  f.association :seller_order
  f.sequence(:seller_order_index) {|n| n}
  f.sequence(:supplier_order_index) {|n| n}
  f.association :product
  f.quantity 5
end

Factory.define :supplier_payment do |f|
  f.association :line_item
  f.association :supplier
  f.association :seller
  f.cents 100000
  f.currency "THB"
end

Factory.define :supplier_payment_paypal_ipn do |f|
  f.params { |paypal_ipn|
    {
      "txn_type" => "masspay",
      "masspay_txn_id_1" => Factory.next(:transaction_id),
      "unique_id_1" => "1"
    }
  }
end

Factory.define :text_message_delivery_receipt do |f|
  f.association :outgoing_text_message, :factory => :sent_outgoing_text_message
  f.params { |tmdr|
    ActionSms::Base.sample_delivery_receipt(
      :message_id => ActionSms::Base.message_id(
        tmdr.outgoing_text_message.gateway_message_id
      )
    )
  }
end

Factory.define :tracking_number_format do |f|
  f.association :seller
end

