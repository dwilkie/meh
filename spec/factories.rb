Factory.define :supplier, :default_strategy => :build do |f|
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
  f.name "Some Manky Product"
end

