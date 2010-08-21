class Notification < ActiveRecord::Base

  belongs_to :seller,
             :class_name => "User"

  belongs_to :product

  belongs_to :supplier,
             :class_name => "User"

  EVENTS = {
    :customer_order_created => {
      :notification_attributes => SellerOrderNotification::ATTRIBUTES,
      :send_notification_to => User.roles(
        SellerOrderNotification::SEND_TO_MASK
      )
    },
    :product_order_created => {
      :notification_attributes => SupplierOrderNotification::ATTRIBUTES,
      :send_notification_to => User.roles(
        SupplierOrderNotification::SEND_TO_MASK
      )
    },
    :product_order_accepted => {
      :notification_attributes => SupplierOrderNotification::ATTRIBUTES,
      :send_notification_to => User.roles(
        SupplierOrderNotification::SEND_TO_MASK
      )
    },
    :product_order_rejected => {
      :notification_attributes => SupplierOrderNotification::ATTRIBUTES,
      :send_notification_to => User.roles(
        SupplierOrderNotification::SEND_TO_MASK
      )
    },
    :product_order_completed => {
      :notification_attributes => SupplierOrderNotification::ATTRIBUTES,
      :send_notification_to => User.roles(
        SupplierOrderNotification::SEND_TO_MASK
      )
    }
  }

  class AvailableReceiversValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if record.event
        if available_receivers = EVENTS[record.event.to_sym].try(
          :[],
          :send_notification_to
        )
          record.errors.add(attribute, :inclusion) unless
            available_receivers.include?(value)
        end
      end
    end
  end

  validates  :seller, :purpose,
             :presence => true

  validates  :message,
             :presence => true,
             :if => Proc.new { |n|
               n.should_send?
             }

  validates  :enabled, :should_send,
             :inclusion => {:in => [true, false]}

  validates  :event,
             :inclusion => {:in => EVENTS.stringify_keys.keys}

  validates  :for,
             :available_receivers => true

  before_validation(:on => :create) do
    self.enabled = true if self.enabled.nil?
    self.should_send = true if self.should_send.nil?
  end

  def parse_message(event_attributes)
    parsed_message = self.message
    parsed_message.scan(/<\w+>/).each do |attribute|
      parsed_attribute = attribute.gsub(/[<>]/, "").to_sym
      if event_attributes.include?(parsed_attribute)
        parsed_message.gsub!(
          attribute,
          event_attributes[parsed_attribute]
        )
      end
    end
    parsed_message
  end

  def send_to(seller, supplier)
    if self.for == "seller"
      seller
    elsif self.for == "supplier"
      supplier
    end
  end

  def self.for_event(event, options = {})
    scope = where(:event => event, :enabled => true)
    notifications = scope.where(:supplier_id => nil, :product_id => nil).all
    if options[:supplier]
      notifications << scope.where(:supplier_id => options[:supplier].id).all
    end
    if options[:product]
      notifications << scope.where(:product_id => options[:product].id).all
    end
    if options[:product] || options[:supplier]
      notifications.flatten!
      final_notifications = {}
      notifications.each do |notification|
        notification_key = notification.purpose + " " + notification.for
        final_notifications[notification_key] = notification
      end
      notifications = final_notifications.values
    end
    notifications.each do |notification|
      notifications.delete(notification) unless notification.should_send?
    end
    notifications
  end

  def self.create_defaults!
    create!(
      :event => "customer_order_created",
      :for => "seller",
      :purpose => "to inform me about the customer order details",
      :message => I18n.t(
        "notifications.messages.a_customer_completed_payment_for"
      )
    )
    create!(
      :event => "product_order_created",
      :for => "seller",
      :purpose => "to inform me which supplier a product order was sent to",
      :message => I18n.t(
        "notifications.messages.product_order_was_sent_to"
      )
    )
    notification = new(
      :event => "product_order_created",
      :for => "seller",
      :purpose => "to inform me which supplier a product order was sent to",
      :should_send => false
    )
    notification.supplier = notification.seller
    notification.save!
    create!(
      :event => "product_order_created",
      :for => "supplier",
      :purpose => "to inform the supplier about the product order details",
      :message => I18n.t(
        "notifications.messages.new_product_order_from_seller_for_the_following_item"
      )
    )
    notification = new(
      :event => "product_order_created",
      :for => "supplier",
      :purpose => "to inform the supplier about the product order details",
      :message => I18n.t(
        "notifications.messages.your_customer_bought_the_following_item"
      )
    )
    notification.supplier = notification.seller
    notification.save!
    create!(
      :event => "product_order_accepted",
      :for => "seller",
      :purpose => "to inform me when a supplier accepts a product order",
      :message => I18n.t(
        "notifications.messages.your_supplier_processed_their_product_order",
        :processed => "ACCEPTED"
      )
    )
    notification = new(
      :event => "product_order_accepted",
      :for => "seller",
      :purpose => "to inform me when a supplier accepts a product order",
      :should_send => false
    )
    notification.supplier = notification.seller
    notification.save!
    create!(
      :event => "product_order_accepted",
      :for => "supplier",
      :purpose => "to inform the supplier that they successfully accepted their product order",
      :message => I18n.t(
        "notifications.messages.you_successfully_processed_the_product_order",
        :processed => "accepted"
      )
    )
    create!(
      :event => "product_order_accepted",
      :for => "supplier",
      :purpose => "to inform the supplier of the shipping instructions",
      :message => I18n.t(
        "notifications.messages.send_the_product_to"
      )
    )
    notification = new(
      :event => "product_order_accepted",
      :for => "supplier",
      :purpose => "to inform the supplier of the shipping instructions",
      :should_send => false
    )
    notification.supplier = notification.seller
    notification.save!
    create!(
      :event => "product_order_rejected",
      :for => "seller",
      :purpose => "to inform me when a supplier rejects a product order",
      :message => I18n.t(
        "notifications.messages.your_supplier_processed_their_product_order",
        :processed => "REJECTED"
      )
    )
    notification = new(
      :event => "product_order_rejected",
      :for => "seller",
      :purpose => "to inform me when a supplier rejects a product order",
      :should_send => false
    )
    notification.supplier = notification.seller
    notification.save!
    create!(
      :event => "product_order_rejected",
      :for => "supplier",
      :purpose => "to inform the supplier that they successfully rejected their product order",
      :message => I18n.t(
        "notifications.messages.you_successfully_processed_the_product_order",
        :processed => "rejected"
      )
    )
    create!(
      :event => "product_order_completed",
      :for => "seller",
      :purpose => "to inform me when a supplier completes a product order",
      :message => I18n.t(
        "notifications.messages.your_supplier_processed_their_product_order",
        :processed => "COMPLETED"
      )
    )
    notification = new(
      :event => "product_order_completed",
      :for => "seller",
      :purpose => "to inform me when a supplier completes a product order",
      :should_send => false
    )
    notification.supplier = notification.seller
    notification.save!
    create!(
      :event => "product_order_completed",
      :for => "supplier",
      :purpose => "to inform the supplier that they successfully completed their product order",
      :message => I18n.t(
        "notifications.messages.you_successfully_processed_the_product_order",
        :processed => "completed"
      )
    )
  end
end

