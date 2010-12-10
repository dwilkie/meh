require 'spec_helper'

describe PartnershipsController do

  def mock_partnership(stubs={})
    (@mock_partnership ||= mock_model(Partnership).as_null_object).tap do |partnership|
      partnership.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all partnerships as @partnerships" do
      Partnership.stub(:all) { [mock_partnership] }
      get :index
      assigns(:partnerships).should eq([mock_partnership])
    end
  end

  describe "GET show" do
    it "assigns the requested partnership as @partnership" do
      Partnership.stub(:find).with("37") { mock_partnership }
      get :show, :id => "37"
      assigns(:partnership).should be(mock_partnership)
    end
  end

  describe "GET new" do
    it "assigns a new partnership as @partnership" do
      Partnership.stub(:new) { mock_partnership }
      get :new
      assigns(:partnership).should be(mock_partnership)
    end
  end

  describe "GET edit" do
    it "assigns the requested partnership as @partnership" do
      Partnership.stub(:find).with("37") { mock_partnership }
      get :edit, :id => "37"
      assigns(:partnership).should be(mock_partnership)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created partnership as @partnership" do
        Partnership.stub(:new).with({'these' => 'params'}) { mock_partnership(:save => true) }
        post :create, :partnership => {'these' => 'params'}
        assigns(:partnership).should be(mock_partnership)
      end

      it "redirects to the created partnership" do
        Partnership.stub(:new) { mock_partnership(:save => true) }
        post :create, :partnership => {}
        response.should redirect_to(partnership_url(mock_partnership))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved partnership as @partnership" do
        Partnership.stub(:new).with({'these' => 'params'}) { mock_partnership(:save => false) }
        post :create, :partnership => {'these' => 'params'}
        assigns(:partnership).should be(mock_partnership)
      end

      it "re-renders the 'new' template" do
        Partnership.stub(:new) { mock_partnership(:save => false) }
        post :create, :partnership => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested partnership" do
        Partnership.should_receive(:find).with("37") { mock_partnership }
        mock_partnership.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :partnership => {'these' => 'params'}
      end

      it "assigns the requested partnership as @partnership" do
        Partnership.stub(:find) { mock_partnership(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:partnership).should be(mock_partnership)
      end

      it "redirects to the partnership" do
        Partnership.stub(:find) { mock_partnership(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(partnership_url(mock_partnership))
      end
    end

    describe "with invalid params" do
      it "assigns the partnership as @partnership" do
        Partnership.stub(:find) { mock_partnership(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:partnership).should be(mock_partnership)
      end

      it "re-renders the 'edit' template" do
        Partnership.stub(:find) { mock_partnership(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested partnership" do
      Partnership.should_receive(:find).with("37") { mock_partnership }
      mock_partnership.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the partnerships list" do
      Partnership.stub(:find) { mock_partnership }
      delete :destroy, :id => "1"
      response.should redirect_to(partnerships_url)
    end
  end

end
