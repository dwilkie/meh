require 'spec_helper'

describe AcceptorderConversation do
  # A valid accept order text message should be formatted as follows:
  # acceptorder <pin_code> <order_number> <quantity> x <pv_code>

  # Omitting the 'x' in the quantity is also accepted
  # acceptorder <pin_code> <order_number> <quantity> <pv code>

  # And supplying a # in front of the order number is also accepted
  # acceptorder <pin_code> #<order_number> quantity x <pv_code>

  # Examples of valid messages:
  # "acceptorder 1234 6788965 4 x 243553"
  # "acceptorder 1234 135 4 haye532"
  # "acceptorder 1234 3456 1x 34223hdx"
  # "acceptorder 1234 #3456 1 x 34223hdx"

  # Examples of invalid messages:
  # "acceptorder x2345 4 x 2345677"      # Pin code omitted
  # "acceptorder 1234 x2345 4 x 2345677" # Order not found
  # "acceptorder 1234 23445 0 x 3456766" # Quantity isn't 0
  # "acceptorder 1234 21321 1 x"         # pv code isn't x
  # "acceptorder 1234"                   # All errors
  # "acceptorder 1234 21243"             # Quantity is blank, pv code can't be blank
  # "acceptorder 1234 23324 1"           # pv code can't be blank

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
      :quantity => 5,
      :product => Factory.create(
        :product,
        :supplier => supplier,
        :verification_code => "suo1243"
      )
    )
  end

  let(:valid_attributes) {
    {
      :topic => "acceptorder",
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
    let(:conversation) { AcceptorderConversation.new(valid_attributes) }
    let(:message_text) {"acceptorder 1234 2312 5 x suo1243"}
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
          it "should mark the order as accepted" do
            conversation.move_along(message_text)
            SupplierOrder.first.accepted?.should == true
          end
          context "omitting the 'x' symbol after the quantity" do
            it "should mark the order as accepted" do
              conversation.move_along("acceptorder 1234 2312 5 suo1243")
              SupplierOrder.first.accepted?.should == true
            end
          end
          context "supplying a # in front of the order number" do
            it "should mark the order as accepted" do
              conversation.move_along("acceptorder 1234 #2312 5 suo1243")
              SupplierOrder.first.accepted?.should == true
            end
          end
        end
        context "but the user supplied the wrong password" do
          let!(:message_text) {"acceptorder 1233 2312 5 x suo1243"}
          it "should not mark the order as accepted" do
            conversation.move_along(message_text)
            SupplierOrder.first.accepted?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
        context "but the user forgot to supply a password" do
          let!(:message_text) {"acceptorder 2312 5 x suo1243"}
          it "should not mark the order as accepted" do
            conversation.move_along(message_text)
            SupplierOrder.first.accepted?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
        context "but the user supplied the incorrect order number" do
          let!(:message_text) {"acceptorder 1234 2313 5 x suo1243"}
          it "should not mark the order as accepted" do
            conversation.move_along(message_text)
            SupplierOrder.first.accepted?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
        context "but the user forgot to supply the order number" do
          let!(:message_text) {"acceptorder 1234 5 x suo1243"}
          it "should not mark the order as accepted" do
            conversation.move_along(message_text)
            SupplierOrder.first.accepted?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
        context "but the user supplied the incorrect quantity" do
          let!(:message_text) {"acceptorder 1234 2312 4 x suo1243"}
          it "should not mark the order as accepted" do
            conversation.move_along(message_text)
            SupplierOrder.first.accepted?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
        context "but the user forgot to supply the quantity" do
          let!(:message_text) {"acceptorder 1234 2312 suo1243"}
          it "should not mark the order as accepted" do
            conversation.move_along(message_text)
            SupplierOrder.first.accepted?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
        context "but the user supplied the incorrect pv code" do
          let!(:message_text) {"acceptorder 1234 2312 4 x suo1242"}
          it "should not mark the order as accepted" do
            conversation.move_along(message_text)
            SupplierOrder.first.accepted?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
        context "but the user forgot to supply the pv code" do
          let!(:message_text) {"acceptorder 1234 2312 4 x suo1242"}
          it "should not mark the order as accepted" do
            conversation.move_along(message_text)
            SupplierOrder.first.accepted?.should == false
          end
          it "should say invalid" do
            conversation.should_receive(:invalid)
            conversation.move_along(message_text)
          end
        end
      end
      context "and an already accepted order exists belonging to the user" do
        before {
          create_order(:for_this_supplier => true, :status => :accepted)
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
          it "should not mark the order as accepted" do
            conversation.move_along(message_text)
            SupplierOrder.first.accepted?.should == false
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
          it "should not mark the order as accepted" do
            conversation.move_along(message_text)
            SupplierOrder.first.accepted?.should == false
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
          it "should not mark the order as accepted" do
            conversation.move_along(message_text)
            SupplierOrder.first.accepted?.should == false
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

