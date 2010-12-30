class SellersController < ApplicationController
  def new
    @seller = User.new
    @seller.mobile_numbers.build
  end

  def create
    @seller = User.new(params[:user])
    @seller.valid?
    mobile_number = @seller.mobile_numbers.first
    mobile_number.errors[:number].empty? ?
      redirect_to(
        user_paypal_authable_path(:user => params[:user]), :method => :post
      ) :
      render(:new)
  end
end

