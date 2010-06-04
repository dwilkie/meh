class PaymentRequestsController < ApplicationController
  def show
    payment_request = PaymentRequest.find_by_id(params[:id])
    if payment_request && payment_request.requested?
      merged_params = params.merge(payment_request.params)
      merged_params == params ? head(:ok) : head(:not_found)
    else
      head(:not_found)
    end
  end
end
