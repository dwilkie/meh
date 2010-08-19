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

  validates  :message, :seller,
             :presence => true

  validates  :event,
             :inclusion => {:in => EVENTS.stringify_keys.keys},
             :presence => true

  validates  :for,
             :inclusion => {:in => User::ROLES},
             :presence => true

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
    scope = where(:event => event)
    notifications = []
    if options[:product]
      notifications = scope.where(:product_id => options[:product].id).all
    end
    if notifications.empty? && options[:supplier]
      scope.where(:supplier_id => options[:supplier].id).all
    end
    if notifications.empty?
      notifications = scope.all
    end
    notifications
  end
end

