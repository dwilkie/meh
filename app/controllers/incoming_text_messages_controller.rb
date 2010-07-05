class IncomingTextMessagesController < ApplicationController
  def create
    incoming_text_message = params[:incoming_text_message]
    IncomingTextMessage.create!(:params => incoming_text_message, :from => incoming_text_message[:from])
    render :nothing => true
  end
end

