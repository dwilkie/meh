class PaypalIpnsController < ApplicationController
  def create
    PaypalIpn.create!(:params => params[:paypal_ipn])
    render :nothing => true
  end
end

