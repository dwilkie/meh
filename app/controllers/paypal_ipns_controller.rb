class PaypalIpnsController < ApplicationController
  def create
    PaypalIpn.create!(
      :params => params,
      :payment_status => params[:payment_status]
    )
    render :nothing => true
  end
end

