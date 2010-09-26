class IncomingTextMessagesController < ApplicationController
  protect_from_forgery :except => :create
  def create
    IncomingTextMessage.create_later(
      :params => params[:incoming_text_message]
    )
    render :nothing => true
  end
end

