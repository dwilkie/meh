require "spec_helper"

describe PartnershipsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/partnerships" }.should route_to(:controller => "partnerships", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/partnerships/new" }.should route_to(:controller => "partnerships", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/partnerships/1" }.should route_to(:controller => "partnerships", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/partnerships/1/edit" }.should route_to(:controller => "partnerships", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/partnerships" }.should route_to(:controller => "partnerships", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/partnerships/1" }.should route_to(:controller => "partnerships", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/partnerships/1" }.should route_to(:controller => "partnerships", :action => "destroy", :id => "1")
    end

  end
end
