class PaypalAuthenticationsController < Devise::PaypalAuthenticationsController
  def new
    @seller = User.new
    @seller.mobile_numbers.build
  end

  def create
    @seller = User.new(params[:user])
    @seller.valid?
    mobile_number = @seller.mobile_numbers.first
    mobile_number.errors[:number].empty? ?
    create_and_redirect_to_resource(params)
    : render(:new)
  end
end

