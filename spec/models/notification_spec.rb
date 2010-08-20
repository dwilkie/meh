require 'spec_helper'

describe Notification do
  describe ".for_event" do
    context "Given there are 8 existing notifications for the event: 'first_meeting' and 1 notification is disabled and another should not be sent" do
      let(:seller)   { Factory.create(:seller)   }
      let(:supplier) { Factory.create(:supplier) }
      let(:product)  {
        Factory.create(:product, :seller => seller, :supplier => supplier)
      }
      let(:existing_notifications) {[]}
      let!(:notifications) {[]}
      before {
        existing_notifications = {
          # General notification for greeting a new friend on a first meeting
          :general_greeting_new_friend => Factory.create(
            :notification,
            :for => "new friend",
            :event => "first_meeting",
            :purpose => "greeting",
            :seller => seller
          ),
          # General notification for greeting another new friend on a first meeting
          :general_greeting_another_new_friend => Factory.create(
            :notification,
            :for => "another new friend",
            :event => "first_meeting",
            :purpose => "greeting",
            :seller => seller
          ),
          # General notification for introducing a new friend on a first meeting
          :general_introduction_new_friend => Factory.create(
            :notification,
            :for => "new friend",
            :event => "first_meeting",
            :purpose => "introduction",
            :seller => seller
          ),
          # General notification for introducing another new friend on a first meeting
          :general_introduction_another_new_friend => Factory.create(
            :notification,
            :for => "another new friend",
            :event => "first_meeting",
            :purpose => "introduction",
            :seller => seller
          ),
          # Special notification for a particular product
          # for greeting a new friend on a first meeting
          :special_product_greeting_new_friend => Factory.create(
            :notification,
            :for => "new friend",
            :event => "first_meeting",
            :purpose => "greeting",
            :seller => seller,
            :product => product
          ),
          # Special notification for particular product
          # for greeting another new friend on a first meeting
          # But the notification is turned off.
          :special_product_greeting_another_new_friend => Factory.create(
            :notification,
            :for => "another new friend",
            :event => "first_meeting",
            :purpose => "greeting",
            :seller => seller,
            :product => product,
            :enabled => false
          ),
          # Special notification for a particular product
          # for introducing a new friend on a first meeting
          :special_product_introduction_new_friend => Factory.create(
            :notification,
            :for => "new friend",
            :event => "first_meeting",
            :purpose => "introduction",
            :seller => seller,
            :product => product
          ),
          # Special notification for a particular product
          # for introducing another new friend on a first meeting
          :special_product_introduction_another_new_friend => Factory.create(
            :notification,
            :for => "another new friend",
            :event => "first_meeting",
            :purpose => "introduction",
            :seller => seller,
            :product => product
          ),
          # Special notification for a particular supplier
          # for greeting a new friend on a first meeting
          :special_supplier_greeting_new_friend => Factory.create(
            :notification,
            :for => "new friend",
            :event => "first_meeting",
            :purpose => "greeting",
            :seller => seller,
            :supplier => supplier
          ),
          # Special notification for a particular supplier
          # for greeting another new friend on a first meeting
          :special_supplier_greeting_another_new_friend => Factory.create(
            :notification,
            :for => "another new friend",
            :event => "first_meeting",
            :purpose => "greeting",
            :seller => seller,
            :supplier => supplier
          ),
          # Special notification for a particular supplier
          # for introducing a new friend on a first meeting.
          # This notification should not be sent
          :special_supplier_introduction_new_friend => Factory.create(
            :notification,
            :for => "new friend",
            :event => "first_meeting",
            :purpose => "introduction",
            :seller => seller,
            :supplier => supplier,
            :should_send => false
          ),
          # Special notification for a particular supplier
          # for introducing another new friend on a first meeting.
          # This notification should not be sent
          :special_supplier_introduction_another_new_friend => Factory.create(
            :notification,
            :for => "another new friend",
            :event => "first_meeting",
            :purpose => "introduction",
            :seller => seller,
            :supplier => supplier
          )
        }
      }
      context "supplying no options" do
        before {
          notifications = Notification.for_event("first_meeting")
        }
        it "should return 4 notifications" do
          notifications.size.should == 4
        end
        it "should return the correct notifications" do
          notifications.should_include
            existing_notifications[:general_greeting_new_friend]
          notifications.should_include
            existing_notifications[:general_greeting_another_new_friend]
          notifications.should_include
            existing_notifications[:general_introduction_new_friend]
          notifications.should_include
            existing_notifications[:general_introduction_another_new_friend]
        end
      end
      context "supplying the 'product' option" do
        context "with a product that has notifications assigned to it" do
          before {
            notifications = Notification.for_event(
              "first_meeting",
              :product => product
            )
          }
          it "should return a total of 4 notifications" do
            notifications.size.should == 4
          end
          it "should return the correct notifications" do
            notifications.should_include
              existing_notifications[:special_product_greeting_new_friend]
            notifications.should_include
              existing_notifications[:general_greeting_another_new_friend]
            notifications.should_include
              existing_notifications[:special_product_introduction_new_friend]
            notifications.should_include
              existing_notifications[:special_product_introduction_another_new_friend]
          end
        end
        context "with a product that does not have notifications assigned to it" do
          before {
            notifications = Notification.for_event(
              "first_meeting",
              :product => Factory.create(:product)
            )
          }
          it "should return a total of 4 notifications" do
            notifications.size.should == 4
          end
          it "should return the correct notifications" do
            notifications.should_include
              existing_notifications[:general_greeting_new_friend]
            notifications.should_include
              existing_notifications[:general_greeting_another_new_friend]
            notifications.should_include
              existing_notifications[:general_introduction_new_friend]
            notifications.should_include
              existing_notifications[:general_introduction_another_new_friend]
          end
        end
      end
      context "supplying the 'supplier' option" do
        context "with a supplier that has notifications assigned to it" do
          before {
            notifications = Notification.for_event(
              "first_meeting",
              :supplier => supplier
            )
          }
          it "should return a total of 3 notifications" do
            notifications.size.should == 3
          end
          it "should return the correct notifications" do
            notifications.should_include
              existing_notifications[:special_supplier_greeting_new_friend]
            notifications.should_include
              existing_notifications[:special_supplier_greeting_another_new_friend]
            notifications.should_include
              existing_notifications[:special_supplier_introduction_another_new_friend]
          end
        end
        context "with a supplier that does not have notifications assigned to it" do
          before {
            notifications = Notification.for_event(
              "first_meeting",
              :supplier => Factory.create(:supplier)
            )
          }
          it "should return a total of 4 notifications" do
            notifications.size.should == 4
          end
          it "should return the correct notifications" do
            notifications.should_include
              existing_notifications[:general_greeting_new_friend]
            notifications.should_include
              existing_notifications[:general_greeting_another_new_friend]
            notifications.should_include
              existing_notifications[:general_introduction_new_friend]
            notifications.should_include
              existing_notifications[:general_introduction_another_new_friend]
          end
        end
      end
      context "supplying both the 'product' and 'supplier' options" do
        context "with a product that and a supplier that have notifications assigned to them" do
          before {
            notifications = Notification.for_event(
              "first_meeting",
              :product => product,
              :supplier => supplier
            )
          }
          it "should return a total of 4 notifications" do
            notifications.size.should == 4
          end
          it "should return the correct notifications" do
            notifications.should_include
              existing_notifications[:special_product_greeting_new_friend]
            notifications.should_include
              existing_notifications[:special_supplier_greeting_another_new_friend]
            notifications.should_include
              existing_notifications[:special_product_introduction_new_friend]
            notifications.should_include
              existing_notifications[:special_product_introduction_another_new_friend]
          end
        end
      end
    end
  end
end

