require 'spec_helper'

describe ProductOrderConversationSpec do
  describe "#accept" do
    let(:product_order) { Factory.create(:product_order) }
    let(:product_order_conversation) {
      ProductOrderConversation.new(
        :user => product_order.seller_order.seller
      )
    }
    context "the user texts in a valid message" do
      let(:message) { "" }
      context "they also the seller" do
        it "" do
        end
    end
  end
end

