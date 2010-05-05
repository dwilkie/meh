require 'spec_helper'

describe "orders/new.html.erb" do
  before(:each) do
    assign(:order, stub_model(Order,
      :new_record? => true,
      :state => "MyString",
      :details => "MyText"
    ))
  end

  it "renders new order form" do
    render

    response.should have_selector("form", :action => orders_path, :method => "post") do |form|
      form.should have_selector("input#order_state", :name => "order[state]")
      form.should have_selector("textarea#order_details", :name => "order[details]")
    end
  end
end
