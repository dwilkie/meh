require 'spec_helper'

describe "orders/index.html.erb" do
  before(:each) do
    assign(:orders, [
      stub_model(Order,
        :state => "MyString",
        :details => "MyText"
      ),
      stub_model(Order,
        :state => "MyString",
        :details => "MyText"
      )
    ])
  end

  it "renders a list of orders" do
    render
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyText".to_s, :count => 2)
  end
end
