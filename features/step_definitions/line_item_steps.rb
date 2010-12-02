Given(/^a line item exists? for #{capture_model}(?: and #{capture_model})?(?: with #{capture_fields})?$/) do |product_name, supplier_order_name, fields|
  product = model!(product_name)
  supplier_order = model!(supplier_order_name) if supplier_order_name
  seller = product.seller
  fields_hash = parse_fields(fields)
  item_quantity = 1
  item_quantity = fields_hash["quantity"] if fields_hash["quantity"]
  unless supplier_order
    paypal_ipn = Factory.build(
      :seller_order_paypal_ipn,
      :seller => seller
    )
    paypal_ipn.params = paypal_ipn.params.merge(
      {
        "item_name" => product.name,
        "item_number" => product.number.to_s,
        "quantity" => item_quantity.to_s
      }
    )
    paypal_ipn.save!
    find_model!("a seller order paypal ipn", "id: #{paypal_ipn.id}")
  else
    product.price = supplier_order.seller_order.order_notification.item_amount
    product.save!
    total_number_of_line_items = 0
    seller_order = supplier_order.seller_order
    seller_order.supplier_orders.each do |supplier_order|
      total_number_of_line_items += supplier_order.line_items.count
    end
    line_item = Factory.create(
      :line_item,
      :supplier_order => supplier_order,
      :product => product,
      :seller_order => supplier_order.seller_order,
      :supplier_order_index => supplier_order.line_items.count + 1,
      :seller_order_index => total_number_of_line_items + 1
    )
  end
  line_item = find_model!("a line item", "product_id: #{product_name}")
  line_item.update_attributes!(fields_hash)
end

When(/^a line item is created for #{capture_model}(?: with #{capture_fields})?$/) do |product_name, fields|
  step = "a line item exists for #{product_name}"
  fields ? Given(step) : Given("#{step} with #{fields}")
end

