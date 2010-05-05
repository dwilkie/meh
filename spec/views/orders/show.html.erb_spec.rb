require 'spec_helper'

describe "orders/show.html.erb" do
  before(:each) do
    assign(:order, @order = stub_model(Order,
      :state => "MyString",
      :details => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    response.should contain("MyString")
    response.should contain("MyText")
  end
end
