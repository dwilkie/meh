class PaymentRequestsController < ApplicationController
  def show
    payment_request = PaymentRequest.find_by_id(params[:id])
    payment_request && payment_request.authorized?(params) ? head(:ok) : head(:not_found)
  end

  def update
    PaymentRequest.notify_later(
      params[:id], params["payment_request"]
    )
    render :nothing => true
  end
end

