require 'spec_helper'

describe OrderSimulationsController do

  def mock_order_simulation(stubs={})
    (@mock_order_simulation ||= mock_model(OrderSimulation).as_null_object).tap do |order_simulation|
      order_simulation.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all order_simulations as @order_simulations" do
      OrderSimulation.stub(:all) { [mock_order_simulation] }
      get :index
      assigns(:order_simulations).should eq([mock_order_simulation])
    end
  end

  describe "GET show" do
    it "assigns the requested order_simulation as @order_simulation" do
      OrderSimulation.stub(:find).with("37") { mock_order_simulation }
      get :show, :id => "37"
      assigns(:order_simulation).should be(mock_order_simulation)
    end
  end

  describe "GET new" do
    it "assigns a new order_simulation as @order_simulation" do
      OrderSimulation.stub(:new) { mock_order_simulation }
      get :new
      assigns(:order_simulation).should be(mock_order_simulation)
    end
  end

  describe "GET edit" do
    it "assigns the requested order_simulation as @order_simulation" do
      OrderSimulation.stub(:find).with("37") { mock_order_simulation }
      get :edit, :id => "37"
      assigns(:order_simulation).should be(mock_order_simulation)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created order_simulation as @order_simulation" do
        OrderSimulation.stub(:new).with({'these' => 'params'}) { mock_order_simulation(:save => true) }
        post :create, :order_simulation => {'these' => 'params'}
        assigns(:order_simulation).should be(mock_order_simulation)
      end

      it "redirects to the created order_simulation" do
        OrderSimulation.stub(:new) { mock_order_simulation(:save => true) }
        post :create, :order_simulation => {}
        response.should redirect_to(order_simulation_url(mock_order_simulation))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved order_simulation as @order_simulation" do
        OrderSimulation.stub(:new).with({'these' => 'params'}) { mock_order_simulation(:save => false) }
        post :create, :order_simulation => {'these' => 'params'}
        assigns(:order_simulation).should be(mock_order_simulation)
      end

      it "re-renders the 'new' template" do
        OrderSimulation.stub(:new) { mock_order_simulation(:save => false) }
        post :create, :order_simulation => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested order_simulation" do
        OrderSimulation.should_receive(:find).with("37") { mock_order_simulation }
        mock_order_simulation.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :order_simulation => {'these' => 'params'}
      end

      it "assigns the requested order_simulation as @order_simulation" do
        OrderSimulation.stub(:find) { mock_order_simulation(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:order_simulation).should be(mock_order_simulation)
      end

      it "redirects to the order_simulation" do
        OrderSimulation.stub(:find) { mock_order_simulation(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(order_simulation_url(mock_order_simulation))
      end
    end

    describe "with invalid params" do
      it "assigns the order_simulation as @order_simulation" do
        OrderSimulation.stub(:find) { mock_order_simulation(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:order_simulation).should be(mock_order_simulation)
      end

      it "re-renders the 'edit' template" do
        OrderSimulation.stub(:find) { mock_order_simulation(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested order_simulation" do
      OrderSimulation.should_receive(:find).with("37") { mock_order_simulation }
      mock_order_simulation.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the order_simulations list" do
      OrderSimulation.stub(:find) { mock_order_simulation }
      delete :destroy, :id => "1"
      response.should redirect_to(order_simulations_url)
    end
  end

end
