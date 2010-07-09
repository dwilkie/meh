Factory.define :user, :default_strategy => :build do |f|
  f.sequence(:email) {|n| "user#{n}@example.com" }
  f.password "foobar"
  f.password_confirmation { |u| u.password }
  f.name "Maggot"
end

Factory.define :seller, :class => User, :default_strategy => :build do |f|
  f.sequence(:email) {|n| "seller#{n}@example.com" }
  f.roles ["seller"]
  f.password "foobar"
  f.password_confirmation { |u| u.password }
  f.name "Chris"
end

Factory.define :supplier, :class => User, :default_strategy => :build do |f|
  f.sequence(:email) {|n| "supplier#{n}@example.com" }
  f.roles ["supplier"]
  f.password "foobar"
  f.password_confirmation { |u| u.password }
  f.name "Bob"
end

Factory.define :mobile_number, :default_strategy => :build do |f|
  f.sequence(:number) {|n| "+618148229#{n}" }
  f.association :phoneable, :factory => :user
  f.password "1234"
  f.password_confirmation { |m| m.password }
end

Factory.define :product do |f|
  f.association :supplier
  f.association :seller
  f.external_id 12345
  f.sequence(:verification_code) {|n| "meh#{n}" }
end

Factory.define :seller_order, :class => Order do |f|
  f.association :seller
end

Factory.define :supplier_order, :class => Order do |f|
  f.association :supplier
  f.association :seller_order
  f.association :product
  f.quantity 5
end

Factory.define :outgoing_text_message do |f|
  f.association :smsable, :factory => :mobile_number
end

Factory.define :incoming_text_message do |f|
  f.params({"to"=>"61447100308", "from"=> "61447100310", "msg"=> "Endia kasdf ofeao", "userfield"=>"123456", "date"=>"2010-05-13 23:59:58"})
end

Factory.define :text_message_delivery_receipt do |f|
  f.params({'msgid'=>'6942744494999745', 'dlrstatus'=>'DELIVRD', 'dlr_err'=>'000', 'donedate'=>'1005132312'})
  f.association :outgoing_text_message
end

Factory.define :paypal_ipn do |f|
  f.transaction_id "45D21472YD1820048"
  f.association :seller
  f.params { |paypal_ipn|
    {
      "receiver_email" => paypal_ipn.seller.email,
      "txn_id" => paypal_ipn.transaction_id
    }
  }
end

Factory.define :payment do |f|
  f.association :supplier_order
  f.association :supplier
  f.association :seller
  f.cents 100000
  f.currency "THB"
end

Factory.define :payment_agreement do |f|
end

Factory.define :payment_request do |f|
  f.application_uri "http://example.appspot.com"
  f.association :payment
end

Factory.define :payment_application do |f|
  f.uri "http://example.appspot.com"
  f.association :seller
end

