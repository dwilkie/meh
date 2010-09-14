class PaypalIpnsController < ApplicationController
  def create
    PaypalIpn.create_later(:params => params[:paypal_ipn])
    render :nothing => true
  end
end

