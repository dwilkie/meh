require 'spec_helper'

describe RejectorderConversation do
  # A valid reject order text message should be formatted as follows:
  # rejectorder <pin_code> <order_number>

  # To actually reject the order, however the supplier
  # must format the message as follows:
  # rejectorder <pin_code> <order_number> CONFIRM!

  # Supplying a # in front of the order number is also accepted
  # rejectorder <pin_code> #<order_number

  # Examples of valid messages:
  # "rejectorder 1234 6788965"          # Prompts the user to confirm
  # "rejectorder 1234 #6788965"         # Prompts the user to confirm
  # "rejectorder 1234 6788965 CONFIRM!" # Rejects the order
  # "rejectorder 1234 6788965 confirm!" # Rejects the order

  # Examples of invalid messages:
  # "rejectorder 2345677"               # Pin code incorrect
  # "rejectorder 1234 x2345             # Order not found
  # "rejectorder 1234 6788965 CONFIRM"  # '!' missing from CONFIRM

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
      :id => "2312",
      :product => Factory.create(
        :product,
        :supplier => supplier
      )
    )
  end

  let(:valid_attributes) {
    {
      :topic => "rejectorder",
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
    let(:conversation) { RejectorderConversation.new(valid_attributes) }
    let(:message_text) {"rejectorder 1234 2312"}
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
      context "and an unconfirmed order exists belonging to the user" do
        before {
          create_order(:for_this_supplier => true)
        }
        context "and the user supplied the correct order details" do
          context "but didn't add 'confirm!' at the end" do
            it "should say confirm reject" do
              conversation.should_receive(:confirm_reject)
              conversation.move_along(message_text)
            end
            context "supplying a # in front of the order number" do
              it "should say confirm reject" do
                conversation.should_receive(:confirm_reject)
                conversation.move_along("rejectorder 1234 #2312")
              end
            end
          end
          context "and added 'confirm!' at the end" do
            let!(:message_text) {"rejectorder 1234 2312 confirm!"}
            it "should mark the order as rejected" do
              conversation.move_along(message_text)
              SupplierOrder.first.rejected?.should == true
            end
            it "should say successfully rejected order" do
              conversation.should_receive(:successfully)
              conversation.move_along(message_text)
            end
          end
          context "but added 'confirm' at the end instead of 'confirm!'" do
            let!(:message_text) {"rejectorder 1234 2312 confirm"}
            it "should not mark the order as rejected" do
              conversation.move_along(message_text)
              SupplierOrder.first.rejected?.should == false
            end
            it "should say invalid" do
              conversation.should_receive(:invalid)
              conversation.move_along(message_text)
            end
          end
        end
        context "but the user supplied the wrong password" do
          let!(:message_text) {"rejectorder 1233 2312"}
          it "should not mark the order as rejected" do
            conversation.move_along(message_text)
            SupplierOrder.first.rejected?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
        context "but the user forgot to supply a password" do
          let!(:message_text) {"rejectorder 2312"}
          it "should not mark the order as rejected" do
            conversation.move_along(message_text)
            SupplierOrder.first.rejected?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
        context "but the user supplied the incorrect order number" do
          let!(:message_text) {"rejectorder 1234 2313"}
          it "should not mark the order as rejected" do
            conversation.move_along(message_text)
            SupplierOrder.first.rejected?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
        context "but the user forgot to supply the order number" do
          let!(:message_text) {"rejectorder 1234"}
          it "should not mark the order as rejected" do
            conversation.move_along(message_text)
            SupplierOrder.first.rejected?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
      end
      context "and an already rejected order exists belonging to the user" do
        before {
          create_order(:for_this_supplier => true, :status => :rejected)
        }
        context "and the user supplied the correct order details" do
          it "should say cannot process order" do
            conversation.should_receive(:cannot_process)
            conversation.move_along(message_text)
          end
        end
      end
      context "and an already accepted order exists belonging to the user" do
        before {
          create_order(:for_this_supplier => true, :status => :accepted)
        }
        context "and the user supplied the correct order details" do
          it "should not mark the order as rejected" do
            conversation.move_along(message_text)
            SupplierOrder.first.rejected?.should == false
          end
          it "should say cannot process order" do
            conversation.should_receive(:cannot_process)
            conversation.move_along(message_text)
          end
        end
      end
      context "and an already completed order exists belonging to the user" do
        before {
          create_order(:for_this_supplier => true, :status => :completed)
        }
        context "and the user supplied the correct order details" do
          it "should not mark the order as rejected" do
            conversation.move_along(message_text)
            SupplierOrder.first.rejected?.should == false
          end
          it "should say cannot process order" do
            conversation.should_receive(:cannot_process)
            conversation.move_along(message_text)
          end
        end
      end
      context "and an order exists but does not belong to this user" do
        before {
          create_order(:for_this_supplier => false)
        }
        context "and the user gave the order details for someone elses order" do
          it "should not mark the order as rejected" do
            conversation.move_along(message_text)
            SupplierOrder.first.rejected?.should == false
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

