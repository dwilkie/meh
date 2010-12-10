class SuppliersController < ApplicationController
  before_filter :authenticate_user!
  def index
    if number = params[:search]
      @search_params = number
      @suppliers = User.with_mobile(number)
    else
      @suppliers = current_user.suppliers
    end
  end

  def new
    @supplier = User.new
    @supplier.mobile_numbers.build(:number => params[:mobile_number])
  end

  def create
    @supplier = User.new(params[:user])
    @supplier.new_role = "supplier"
    @supplier.stub_password
    @supplier.seller_partnerships.build(:seller_id => current_user)
    debugger
    if @supplier.save
      flash[:notice] = "Successfully created Supplier"
      redirect_to suppliers_path
    else
      render :new
    end
  end
end

