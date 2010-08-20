class Notification < ActiveRecord::Base

  belongs_to :seller,
             :class_name => "User"

  belongs_to :product

  belongs_to :supplier,
             :class_name => "User"

  EVENTS = {
    :supplier_order_accepted => {
      :notification_attributes => SupplierOrderNotification::ATTRIBUTES,
      :send_notification_to => User.roles(
        SupplierOrderNotification::SEND_TO_MASK
      )
    },
    :supplier_order_rejected => {
      :notification_attributes => SupplierOrderNotification::ATTRIBUTES,
      :send_notification_to => User.roles(
        SupplierOrderNotification::SEND_TO_MASK
      )
    },
    :supplier_order_completed => {
      :notification_attributes => SupplierOrderNotification::ATTRIBUTES,
      :send_notification_to => User.roles(
        SupplierOrderNotification::SEND_TO_MASK
      )
    },
    :supplier_order_created => {
      :notification_attributes => SupplierOrderNotification::ATTRIBUTES,
      :send_notification_to => User.roles(
        SupplierOrderNotification::SEND_TO_MASK
      )
    }
  }

  validates  :message, :seller, :purpose,
             :presence => true

  validates  :enabled, :should_send,
             :inclusion => {:in => [true, false]}

  validates  :event,
             :inclusion => {:in => EVENTS.stringify_keys.keys},
             :presence => true

  validates  :for,
             :inclusion => {:in => User::ROLES},
             :presence => true

  before_validation(:on => :create) do
    enabled = true if enabled.nil?
    should_send = true if should_send.nil?
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
end

