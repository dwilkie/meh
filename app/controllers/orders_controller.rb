class OrdersController < ApplicationController
  # POST /orders
  def create
    @order = Order.create!(request.body.read)
    render :nothing
  end
end
