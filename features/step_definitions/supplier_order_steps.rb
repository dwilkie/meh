# override pickle step for this special case
Given(/^a supplier order exists? for product: #{capture_model}(?: with #{capture_fields})?$/) do |name, fields|
  product = model!(name)
  seller = product.seller
  paypal_ipn = Factory.build(
    :paypal_ipn,
    :seller => seller
  )
  fields_hash = parse_fields(fields)
  item_quantity = 1
  item_quantity = fields_hash["quantity"] if fields_hash["quantity"]
  paypal_ipn.params = paypal_ipn.params.merge(
    {
      "item_name1" => product.name,
      "item_number1" => product.number.to_s,
      "quantity1" => item_quantity.to_s
    }
  )
  paypal_ipn.save!
  find_model!("a supplier order", fields)
  find_model!("a paypal ipn")
end

