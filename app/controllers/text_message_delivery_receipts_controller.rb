class TextMessageDeliveryReceiptsController < ApplicationController
  def create
    TextMessageDeliveryReceipt.create(
      :params => params[:text_message_delivery_receipt]
    )
    render :nothing => true
  end
end

