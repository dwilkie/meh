class OrderSimulationsController < ApplicationController
  before_filter :authenticate_user!, :activate_mobile_number
  # GET /order_simulations/new
  def new
    @order_simulation = current_user.order_simulations.build
    3.times do
      supplier = @order_simulation.suppliers.build
      supplier.mobile_numbers.build
    end
  end

  # POST /order_simulations
  def create
    @order_simulation = current_user.order_simulations.build(
      params[:order_simulation]
    )
    debugger
    if @order_simulation.save
      redirect_to user_root_path
    else
      render :action => :new
    end
  end

  private
    def activate_mobile_number
      current_user.mobile_numbers.empty? ?
      redirect_to(new_mobile_number_path) :
      redirect_to(mobile_numbers_path) unless
      current_user.active_mobile_number
    end
end

