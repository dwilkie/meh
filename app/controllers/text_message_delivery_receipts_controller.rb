class TextMessageDeliveryReceiptsController < ApplicationController
  def create
    text_message_delivery_receipt = params[:text_message_delivery_receipt]
    TextMessageDeliveryReceipt.create!(
      :params => text_message_delivery_receipt
    )
    render :nothing => true
  end
end

