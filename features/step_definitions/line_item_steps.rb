Given(/^a line item exists? for #{capture_model}(?: with #{capture_fields})?$/) do |product_name, fields|
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
  line_item = find_model!("a line item", "product_id: #{product_name}")
  line_item.update_attributes!(fields_hash)
  find_model!("a seller order paypal ipn", "id: #{paypal_ipn.id}")
end

When(/^a line item is created for #{capture_model}(?: with #{capture_fields})?$/) do |product_name, fields|
  step = "a line item exists for #{product_name}"
  fields ? Given(step) : Given("#{step} with #{fields}")
end

