Factory.define :supplier, :default_strategy => :build do |f|
  f.sequence(:email) {|n| "supplier#{n}@example.com" }
  f.password "foobar"
  f.password_confirmation { |u| u.password }
  f.after_build { |l|
    l.mobile_number = Factory(:mobile_number)
  }
end

Factory.define :mobile_number, :default_strategy => :build do |f|
  f.sequence(:number) {|n| "+618148229#{n}" }
end

Factory.define :product do |f|
  f.code "P12345"
  f.name "Some Manky Product"
  f.description "This is a Manky Product"
  f.price "999.45"
  f.quantity "999"
  f.height "225"
  f.depth "123"
  f.width "22"
  f.weight "234"
  f.date_available Date.today
end

