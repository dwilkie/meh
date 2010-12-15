class SuppliersController < ApplicationController
  before_filter :authenticate_user!
  def index
    @suppliers = current_user.suppliers
  end

  def new
    @supplier = User.new
    @supplier.mobile_numbers.build
  end

  def create
    new_supplier = User.new(params[:user])
    number = new_supplier.mobile_numbers.first.number
    @supplier = User.with_mobile(number).first || new_supplier
    if @supplier.new_record?
      @supplier.new_role = :supplier
      @supplier.stub_password
      render :new unless @supplier.save
    end
    if @supplier.persisted?
      partnership = current_user.supplier_partnerships.build
      partnership.supplier = @supplier
      partnership.save
      redirect_to suppliers_path
    end
  end
end

