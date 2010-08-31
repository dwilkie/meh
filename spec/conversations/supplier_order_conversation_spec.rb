require 'spec_helper'

describe SupplierOrderConversationSpec do
  describe "#accept" do
    let(:supplier_order) { Factory.create(:supplier_order) }
    let(:supplier_order_conversation) {
      SupplierOrderConversation.new(
        :user => supplier_order.seller_order.seller
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

