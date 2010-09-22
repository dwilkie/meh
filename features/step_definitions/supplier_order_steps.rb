# override pickle step for this special case
Given(/^a supplier order exists? for #{capture_model}(?: with #{capture_fields})?$/) do |product_name, fields|
  product = model!(product_name)
  seller = product.seller
  paypal_ipn = Factory.build(
    :seller_order_paypal_ipn,
    :seller => seller
  )
  fields_hash = parse_fields(fields)
  item_quantity = 1
  item_quantity = fields_hash["quantity"] if fields_hash["quantity"]
  paypal_ipn.params = paypal_ipn.params.merge(
    {
      "item_name" => product.name,
      "item_number" => product.number.to_s,
      "quantity" => item_quantity.to_s
    }
  )
  paypal_ipn.save!
  supplier_order = find_model!("a supplier order", "product_id: #{product_name}")
  supplier_order.update_attributes!(fields_hash)
  find_model!("a seller order paypal ipn", "id: #{paypal_ipn.id}")
end

When(/^a supplier order is created for #{capture_model}(?: with #{capture_fields})?$/) do |product_name, fields|
  step = "a supplier order exists for #{product_name}"
  fields ? Given(step) : Given("#{step} with #{fields}")
end

