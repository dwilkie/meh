class PaypalIpnsController < ApplicationController
  protect_from_forgery :except => [:create]
  def create
    PaypalIpn.create_later(:params => params[:paypal_ipn])
    render :nothing => true
  end
end

