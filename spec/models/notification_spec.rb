require 'spec_helper'

def default_event
  Notification::EVENTS.keys.last.to_s
end

def create_seller
  seller = Factory.create(:seller)
  Notification.delete_all
  seller.notifications.clear
  seller
end

describe Notification do
  describe "validations" do
    describe "#uniqueness" do
      let(:seller) { create_seller }
      context "A notification exists" do
        let (:notification) {
          Factory.create(
            :notification,
            :seller => seller,
            :event => default_event
          )
        }
        context "and second notification is built for the same seller" do
          let (:second_notification) {
            seller.notifications.build(
              :message => "whatever"
            )
          }
          context "and the two notifications are for the same event and person and have the same purpose" do
            before {
              second_notification.event = notification.event
              second_notification.for = notification.for
              second_notification.purpose = notification.purpose
            }
            it "the second notification should not be valid" do
              second_notification.should_not be_valid
              second_notification.errors_on(
                :seller_id
              ).should include I18n.t("activerecord.errors.messages.taken")
            end
            context "and for the same product" do
              before {
                notification.update_attributes!(
                  :product => Factory.create(
                    :product,
                    :seller => seller
                  )
                )
                second_notification.product = notification.product
              }
              it "the second notification should not be valid" do
                second_notification.should_not be_valid
                second_notification.errors_on(
                  :seller_id
                ).should include I18n.t("activerecord.errors.messages.taken")
              end
              context "but for a different supplier" do
                before {
                  second_notification.supplier = Factory.create(:supplier)
                }
                it "the second notification should not be valid" do
                  second_notification.should_not be_valid
                  second_notification.errors_on(
                    :seller_id
                  ).should include I18n.t("activerecord.errors.messages.taken")
                end
              end
            end
            context "but for a different product" do
              before {
                second_notification.product = Factory.create(
                  :product,
                  :seller => seller
                )
              }
              it "the second notification should be valid" do
                second_notification.should be_valid
              end
            end
            context "and for the same supplier" do
              before {
                notification.update_attributes!(
                  :supplier => Factory.create(:supplier)
                )
                second_notification.supplier = notification.supplier
              }
              it "the second notification should not be valid" do
                second_notification.should_not be_valid
                second_notification.errors_on(
                  :seller_id
                ).should include I18n.t("activerecord.errors.messages.taken")
              end
              context "but for a different product" do
                before {
                  second_notification.product = Factory.create(
                    :product,
                    :seller => seller
                  )
                }
                it "the second notification should be valid" do
                  second_notification.should be_valid
                end
              end
            end
            context "but for a different supplier" do
              before {
                second_notification.supplier = Factory.create(:supplier)
              }
              it "the second notification should be valid" do
                second_notification.should be_valid
              end
            end
          end
        end
      end
    end
  end
  describe ".for_event" do
    context "given there are 12 existing notifications for the event: '#{default_event}'" do
      let(:seller)   { create_seller }
      let(:supplier) { Factory.create(:supplier) }
      let(:product)  {
        Factory.create(:product, :seller => seller, :supplier => supplier)
      }
      before {
        Notification.delete_all
      }
      let!(:existing_notifications) {
        {
          # General notification for greeting a seller
          :general_greeting_for_seller => Factory.create(
            :notification,
            :for => "seller",
            :event => default_event,
            :purpose => "greeting",
            :seller => seller
          ),
          # General notification for greeting a supplier
          :general_greeting_for_supplier => Factory.create(
            :notification,
            :for => "supplier",
            :event => default_event,
            :purpose => "greeting",
            :seller => seller
          ),
          # General notification for introducing a seller
          :general_introduction_for_seller => Factory.create(
            :notification,
            :for => "seller",
            :event => default_event,
            :purpose => "introduction",
            :seller => seller
          ),
          # General notification for introducing a supplier
          :general_introduction_for_supplier=> Factory.create(
            :notification,
            :for => "supplier",
            :event => default_event,
            :purpose => "introduction",
            :seller => seller
          ),
          # Special notification for a particular product
          # for greeting a seller
          :special_product_greeting_for_seller => Factory.create(
            :notification,
            :for => "seller",
            :event => default_event,
            :purpose => "greeting",
            :seller => seller,
            :product => product
          ),
          # Special notification for particular product
          # for greeting a supplier
          # But the notification is turned off.
          :special_product_greeting_for_supplier => Factory.create(
            :notification,
            :for => "supplier",
            :event => default_event,
            :purpose => "greeting",
            :seller => seller,
            :product => product,
            :enabled => false
          ),
          # Special notification for a particular product
          # for introducing a seller
          :special_product_introduction_for_seller => Factory.create(
            :notification,
            :for => "seller",
            :event => default_event,
            :purpose => "introduction",
            :seller => seller,
            :product => product
          ),
          # Special notification for a particular product
          # for introducing a supplier
          :special_product_introduction_for_supplier => Factory.create(
            :notification,
            :for => "supplier",
            :event => default_event,
            :purpose => "introduction",
            :seller => seller,
            :product => product
          ),
          # Special notification for a particular supplier
          # for greeting a seller
          :special_supplier_greeting_for_seller => Factory.create(
            :notification,
            :for => "seller",
            :event => default_event,
            :purpose => "greeting",
            :seller => seller,
            :supplier => supplier
          ),
          # Special notification for a particular supplier
          # for greeting a supplier
          :special_supplier_greeting_for_supplier => Factory.create(
            :notification,
            :for => "supplier",
            :event => default_event,
            :purpose => "greeting",
            :seller => seller,
            :supplier => supplier
          ),
          # Special notification for a particular supplier
          # for introducing a seller.
          # This notification should not be sent
          :special_supplier_introduction_for_seller => Factory.create(
            :notification,
            :for => "seller",
            :event => default_event,
            :purpose => "introduction",
            :seller => seller,
            :supplier => supplier,
            :should_send => false
          ),
          # Special notification for a particular supplier
          # for introducing a supplier.
          # This notification should not be sent
          :special_supplier_introduction_for_supplier => Factory.create(
            :notification,
            :for => "supplier",
            :event => default_event,
            :purpose => "introduction",
            :seller => seller,
            :supplier => supplier
          )
        }
      }
      context "supplying no options" do
        it "should return the correct notifications" do
          notifications = Notification.for_event(default_event)
          notifications.size.should == 4
          notifications.should include(
            existing_notifications[:general_greeting_for_seller]
          )
          notifications.should include(
            existing_notifications[:general_greeting_for_supplier]
          )
          notifications.should include(
            existing_notifications[:general_introduction_for_seller]
          )
          notifications.should include(
            existing_notifications[:general_introduction_for_supplier]
          )
        end
      end
      context "supplying the 'product' option" do
        context "with a product that has notifications assigned to it" do
          it "should return the correct notifications" do
            notifications = Notification.for_event(
              default_event,
              :product => product
            )
            notifications.size.should == 4
            notifications.should include(
              existing_notifications[:special_product_greeting_for_seller]
            )
            notifications.should include(
              existing_notifications[:general_greeting_for_supplier]
            )
            notifications.should include(
              existing_notifications[:special_product_introduction_for_seller]
            )
            notifications.should include(
              existing_notifications[:special_product_introduction_for_supplier]
            )
          end
        end
        context "with a product that does not have notifications assigned to it" do
          it "should return the correct notifications" do
            notifications = Notification.for_event(
              default_event,
              :product => Factory.create(
                :product,
                :seller => seller,
                :supplier => supplier
              )
            )
            notifications.size.should == 4
            notifications.should include(
              existing_notifications[:general_greeting_for_seller]
            )
            notifications.should include(
              existing_notifications[:general_greeting_for_supplier]
            )
            notifications.should include(
              existing_notifications[:general_introduction_for_seller]
            )
            notifications.should include(
              existing_notifications[:general_introduction_for_supplier]
            )
          end
        end
      end
      context "supplying the 'supplier' option" do
        context "with a supplier that has notifications assigned to it" do
          it "should return the correct notifications" do
            notifications = Notification.for_event(
              default_event,
              :supplier => supplier
            )
            notifications.size.should == 3
            notifications.should include(
              existing_notifications[:special_supplier_greeting_for_seller]
            )
            notifications.should include(
              existing_notifications[:special_supplier_greeting_for_supplier]
            )
            notifications.should include(
              existing_notifications[:special_supplier_introduction_for_supplier]
            )
          end
        end
        context "with a supplier that does not have notifications assigned to it" do
          it "should return the correct notifications" do
            notifications = Notification.for_event(
              default_event,
              :supplier => Factory.create(:supplier)
            )
            notifications.size.should == 4
            notifications.should include(
              existing_notifications[:general_greeting_for_seller]
            )
            notifications.should include(
              existing_notifications[:general_greeting_for_supplier]
            )
            notifications.should include(
              existing_notifications[:general_introduction_for_seller]
            )
            notifications.should include(
              existing_notifications[:general_introduction_for_supplier]
            )
          end
        end
      end
      context "supplying both the 'product' and 'supplier' options" do
        context "with a product that and a supplier that have notifications assigned to them" do
          it "should return the correct notifications" do
            notifications = Notification.for_event(
              default_event,
              :product => product,
              :supplier => supplier
            )
            notifications.size.should == 4
            notifications.should include(
              existing_notifications[:special_product_greeting_for_seller]
            )
            notifications.should include(
              existing_notifications[:special_supplier_greeting_for_supplier]
            )
            notifications.should include(
              existing_notifications[:special_product_introduction_for_seller]
            )
            notifications.should include(
              existing_notifications[:special_product_introduction_for_supplier]
            )
          end
        end
      end
    end
  end
end

