Factory.define :seller, :class => User, :default_strategy => :build do |f|
  f.sequence(:email) {|n| "seller#{n}@example.com" }
  f.roles ["seller"]
  f.password "foobar"
  f.password_confirmation { |u| u.password }
end

Factory.define :supplier, :class => User, :default_strategy => :build do |f|
  f.sequence(:email) {|n| "supplier#{n}@example.com" }
  f.roles ["supplier"]
  f.password "foobar"
  f.password_confirmation { |u| u.password }
end

Factory.define :mobile_number, :default_strategy => :build do |f|
  f.sequence(:number) {|n| "+618148229#{n}" }
end

Factory.define :product do |f|
  f.cents "0.01"
end

