require 'spec_helper'

describe CompleteorderConversation do
  # Todo:
  # Make the tracking number optional and part of custom supplier input
  # A seller should be able to specify custom message elements
  # e.g. The seller can add a message element:

  # name => tracking number
  # allow_blank => true
  # format => regex
  # unique => true

  # A valid complete order text message should be formatted as follows:
  # completeorder <pin_code> <order_number> <tracking_number>

  # Supplying a # in front of the order number is also accepted
  # completeorder <pin_code> #<order_number> <tracking_number>

  # Examples of valid messages:
  # "completeorder 1234 6788965 cp132446543th"  # Marks the order #6788965 as completed
  # "completeorder 1234 #6788965 cp132446543th" # Marks the order #6788965 as completed

  # Examples of invalid messages:
  # "completeorder 2345677"                # Pin code incorrect
  # "completeorder 1234 x2345              # Order not found
  # "completeorder 1234 6788965"           # Tracking number ommitted
  # "completeorder 1234 6788965 re21234tp" # Tracking number format incorrect

  def create_order(options)
    options[:for_this_supplier] = true if options[:for_this_supplier].nil?
    options[:status] ||= :unconfirmed
    supplier = options[:for_this_supplier] ?
      conversation.user :
      Factory.create(:user)

    Factory.create(
      :supplier_order,
      :status => options[:status].to_s,
      :supplier => supplier,
      :id => "2312"
    )
  end

  let(:valid_attributes) {
    {
      :topic => "completeorder",
      :with => Factory.create(
        :user,
        :mobile_number => Factory.create(
          :mobile_number,
          :password => "1234"
        )
      )
    }
  }
  describe "#move_along" do
    let(:conversation) { CompleteorderConversation.new(valid_attributes) }
    let(:message_text) {"completeorder 1234 2312 cp132446543th"}
    context "user is not a supplier" do
      it "should send a not authorized message" do
        conversation.should_receive(:unauthorized)
        conversation.move_along(nil)
      end
    end
    context "user is a supplier" do
      before {
        conversation.user.new_role = :supplier
      }
      context "and an accepted order exists belonging to the user" do
        before {
          create_order(:for_this_supplier => true, :status => :accepted)
        }
        context "and the user supplied the correct order details" do
          it "should mark the order as completed" do
            conversation.move_along(message_text)
            SupplierOrder.first.completed?.should == true
          end
          it "should say successfully processed order" do
            conversation.should_receive(:successfully)
            conversation.move_along(message_text)
          end
          context "supplying a # in front of the order number" do
            let!(:message_text) {"completeorder 1234 #2312 cp132446543th"}

            it "should mark the order as completed" do
              conversation.move_along(message_text)
              SupplierOrder.first.completed?.should == true
            end

            it "should say successfully processed" do
              conversation.should_receive(:successfully)
              conversation.move_along(message_text)
            end
          end
        end
        context "but the user supplied the wrong password" do
          let!(:message_text) {"completeorder 1233 2312 cp132446543th"}
          it "should not mark the order as completed" do
            conversation.move_along(message_text)
            SupplierOrder.first.completed?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
        context "but the user forgot to supply a password" do
          let!(:message_text) {"completeorder 2312 cp132446543th"}
          it "should not mark the order as completed" do
            conversation.move_along(message_text)
            SupplierOrder.first.completed?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
        context "but the user supplied the incorrect order number" do
          let!(:message_text) {"completeorder 1234 2313 cp132446543th"}
          it "should not mark the order as completed" do
            conversation.move_along(message_text)
            SupplierOrder.first.completed?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
        context "but the user forgot to supply the order number" do
          let!(:message_text) {"completeorder 1234 cp132446543th"}
          it "should not mark the order as completed" do
            conversation.move_along(message_text)
            SupplierOrder.first.completed?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
      end
      context "and an already completed order exists belonging to the user" do
        before {
          create_order(:for_this_supplier => true, :status => :completed)
        }
        context "and the user supplied the correct order details" do
          it "should say cannot process order" do
            conversation.should_receive(:cannot_process)
            conversation.move_along(message_text)
          end
        end
      end
      context "and an already rejected order exists belonging to the user" do
        before {
          create_order(:for_this_supplier => true, :status => :rejected)
        }
        context "and the user supplied the correct order details" do
          it "should not mark the order as completed" do
            conversation.move_along(message_text)
            SupplierOrder.first.completed?.should == false
          end
          it "should say cannot process order" do
            conversation.should_receive(:cannot_process)
            conversation.move_along(message_text)
          end
        end
      end
      context "and an unconfirmed order exists belonging to the user" do
        before {
          create_order(:for_this_supplier => true)
        }
        context "and the user supplied the correct order details" do
          it "should not mark the order as completed" do
            conversation.move_along(message_text)
            SupplierOrder.first.completed?.should == false
          end
          it "should say cannot process order" do
            conversation.should_receive(:cannot_process)
            conversation.move_along(message_text)
          end
        end
      end
      context "and an order exists but does not belong to this user" do
        before {
          create_order(:for_this_supplier => false, :status => :accepted)
        }
        context "and the user gave the order details for someone elses order" do
          it "should not mark the order as completed" do
            conversation.move_along(message_text)
            SupplierOrder.first.completed?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
      end
    end
  end
end

