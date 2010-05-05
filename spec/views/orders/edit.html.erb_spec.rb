require 'spec_helper'

describe "orders/edit.html.erb" do
  before(:each) do
    assign(:order, @order = stub_model(Order,
      :new_record? => false,
      :state => "MyString",
      :details => "MyText"
    ))
  end

  it "renders the edit order form" do
    render

    response.should have_selector("form", :action => order_path(@order), :method => "post") do |form|
      form.should have_selector("input#order_state", :name => "order[state]")
      form.should have_selector("textarea#order_details", :name => "order[details]")
    end
  end
end
