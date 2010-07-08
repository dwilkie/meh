class IncomingTextMessagesController < ApplicationController
  def create
    IncomingTextMessage.create!(:params => params[:incoming_text_message])
    render :nothing => true
  end
end

