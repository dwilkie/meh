When /^a manual creation of supplier orders is triggered for #{capture_model}$/ do |name|
  model!(name).create_supplier_orders
end

