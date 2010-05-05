require 'spec_helper'

describe Product do

  before(:each) do
    @valid_product = Product.new(:supplier => mock_model(User), :seller => mock_model(User), :cents => 1, :external_id => 12345
  end


  describe "validations" do
    it "should be valid with valid attributes" do
      @valid_product.should be_valid
    end


    
  end
end
