class IncomingTextMessagesController < ApplicationController
  def create
    IncomingTextMessage.create!(:params => params, :originator => params[:from] )
    render :nothing => true
  end
end
