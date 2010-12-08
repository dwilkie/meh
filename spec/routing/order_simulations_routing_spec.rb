require "spec_helper"

describe OrderSimulationsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/order_simulations" }.should route_to(:controller => "order_simulations", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/order_simulations/new" }.should route_to(:controller => "order_simulations", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/order_simulations/1" }.should route_to(:controller => "order_simulations", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/order_simulations/1/edit" }.should route_to(:controller => "order_simulations", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/order_simulations" }.should route_to(:controller => "order_simulations", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/order_simulations/1" }.should route_to(:controller => "order_simulations", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/order_simulations/1" }.should route_to(:controller => "order_simulations", :action => "destroy", :id => "1")
    end

  end
end
