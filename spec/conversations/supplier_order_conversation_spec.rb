require 'spec_helper'

describe LineItemConversationSpec do
  describe "#accept" do
    let(:line_item) { Factory.create(:line_item) }
    let(:line_item_conversation) {
      LineItemConversation.new(
        :user => line_item.seller_order.seller
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

