class OrderSimulationsController < ApplicationController
  before_filter :authenticate_user!
  # GET /order_simulations/new
  def new
    @user = current_user
    @order_simulation = @user.order_simulations.build
    @mobile_number = @user.mobile_numbers.build
  end

  # POST /order_simulations
  def create
    @order_simulation = OrderSimulation.new(params[:order_simulation])
    if @order_simulation.save
      redirect_to overview_path
    else
      render :action => :new
    end
  end
end

