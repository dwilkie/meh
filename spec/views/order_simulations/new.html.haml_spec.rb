require 'spec_helper'

describe "order_simulations/new.html.haml" do
  before(:each) do
    # this is required so simple form doesn't throw an error
    view.controller.stub!(:action_name).and_return("new")
    assign(:order_simulation, stub_model(OrderSimulation).as_new_record)
  end

  it "renders new order_simulation form" do
    render
    assert_select "form", :action => order_simulations_path, :method => "post" do
      assert_select "input#order_simulation_submit[name='commit'][value='Start']"
    end
  end
end

