class Notification < ActiveRecord::Base

  belongs_to :seller,
             :class_name => "User"

  belongs_to :product

  belongs_to :supplier,
             :class_name => "User"

  EVENT_ATTRIBUTES = {
    :seller_order => {
      :customer_order_number => Proc.new { |options|
        options[:seller_order].id.to_s
      },
      :total_number_of_items => Proc.new { |options|
        options[:order_notification].number_of_cart_items.to_s
      },
      :customer_order_payment_currency => Proc.new { |options|
        options[:order_notification].payment_currency
      },
      :customer_order_gross_payment => Proc.new { |options|
        options[:order_notification].gross_payment_amount.to_s
      }
    },
    :supplier_order => {
    },
    :customer_address => {
      :customer_address => Proc.new { |options|
        options[:order_notification].customer_address
      },
      :customer_address_name => Proc.new { |options|
        options[:order_notification].customer_address_name
      },
      :customer_address_street => Proc.new { |options|
        options[:order_notification].customer_address_street
      },
      :customer_address_city => Proc.new { |options|
        options[:order_notification].customer_address_city
      },
      :customer_address_state => Proc.new { |options|
        options[:order_notification].customer_address_state
      },
      :customer_address_country => Proc.new { |options|
        options[:order_notification].customer_address_country
      },
      :customer_address_zip => Proc.new { |options|
        options[:order_notification].customer_address_zip
      },
    },
    :product => {
      :product_number => Proc.new { |options|
        options[:product].number.to_s
      },
      :product_name => Proc.new { |options|
        options[:product].name
      },
      :product_verification_code => Proc.new { |options|
        options[:product].verification_code.to_s
      },
      :product_price => Proc.new { |options|
        options[:product].price
      }
    },
    :line_item => {
      :line_item_number => Proc.new { |options|
        options[:line_item].id.to_s
      },
      :line_item_quantity => Proc.new { |options|
        options[:line_item].quantity.to_s
      }
    },
    :seller => {
      :seller_name => Proc.new { |options|
        options[:seller].name
      },
      :seller_mobile_number => Proc.new { |options|
        options[:seller].human_active_mobile_number
      },
      :seller_email => Proc.new { |options|
        options[:seller].email
      }
    },
    :supplier => {
      :supplier_name => Proc.new { |options|
        options[:supplier].name
      },
      :supplier_mobile_number => Proc.new { |options|
        options[:supplier].human_active_mobile_number
      },
      :supplier_email => Proc.new { |options|
        options[:supplier].email
      }
    },
    :suppliers => {
      :supplier_names_and_mobile_numbers => Proc.new { |options|
        options[:seller_order].supplier_names_and_mobile_numbers
      }
     },
    :tracking_number => {
      :smart_tracking_number_label => Proc.new { |options|
        options[:supplier_order].tracking_number ?
        options[:supplier_order].class.human_attribute_name(
          :tracking_number
        ) : ""
      },
      :tracking_number => Proc.new { |options|
        options[:supplier_order].tracking_number.to_s
      }
    },
    :tracking_numbers => {
      :smart_tracking_number_label => Proc.new { |options|
        options[:seller_order].tracking_numbers? ?
        options[:seller_order].class.human_attribute_name(
          :tracking_numbers
        ) : ""
      },
      :tracking_numbers => Proc.new { |options|
        options[:seller_order].tracking_numbers? ?
        options[:seller_order].tracking_numbers :
        ""
      }
    },
    :supplier_payment => {
      :supplier_payment_amount => Proc.new { |options|
        options[:supplier_payment].amount.to_s
      },
      :supplier_payment_currency => Proc.new { |options|
        options[:supplier_payment].amount.currency.to_s
      }
    }
  }

  SELLER_ORDER_ATTRIBUTES = EVENT_ATTRIBUTES[:seller_order].merge(
    EVENT_ATTRIBUTES[:seller]
  ).merge(
    EVENT_ATTRIBUTES[:customer_address]
  )

  SUPPLIER_ORDER_ATTRIBUTES = EVENT_ATTRIBUTES[:supplier_order].merge(
    EVENT_ATTRIBUTES[:seller_order]
  ).merge(
    EVENT_ATTRIBUTES[:supplier]
  )

  LINE_ITEM_ATTRIBUTES = SUPPLIER_ORDER_ATTRIBUTES.merge(
    EVENT_ATTRIBUTES[:line_item]
  ).merge(
    EVENT_ATTRIBUTES[:product]
  )

  EVENTS = {
    :customer_order_created => {
      :notification_attributes => SELLER_ORDER_ATTRIBUTES,
      :send_notification_to => User.roles(1)
    },
    :customer_order_confirmed => {
      :notification_attributes => SELLER_ORDER_ATTRIBUTES.merge(
        EVENT_ATTRIBUTES[:suppliers]
      ),
      :send_notification_to => User.roles(1)
    },
    :customer_order_completed => {
      :notification_attributes => SELLER_ORDER_ATTRIBUTES.merge(
        EVENT_ATTRIBUTES[:suppliers]
      ).merge(
        EVENT_ATTRIBUTES[:tracking_numbers]
      ),
      :send_notification_to => User.roles(1)
    },
    :supplier_order_created => {
      :notification_attributes => SUPPLIER_ORDER_ATTRIBUTES,
      :send_notification_to => User.roles(3)
    },
    :supplier_order_confirmed => {
      :notification_attributes => SUPPLIER_ORDER_ATTRIBUTES,
      :send_notification_to => User.roles(3)
    },
    :supplier_order_completed => {
      :notification_attributes => SUPPLIER_ORDER_ATTRIBUTES.merge(
        EVENT_ATTRIBUTES[:tracking_number]
      ),
      :send_notification_to => User.roles(3)
    },
    :line_item_created => {
      :notification_attributes => LINE_ITEM_ATTRIBUTES,
      :send_notification_to => User.roles(3)
    },
    :line_item_confirmed => {
      :notification_attributes => LINE_ITEM_ATTRIBUTES,
      :send_notification_to => User.roles(3)
    },
    :supplier_payment_completed => {
      :notification_attributes => SUPPLIER_ORDER_ATTRIBUTES.merge(
        EVENT_ATTRIBUTES[:supplier_payment]
      ),
      :send_notification_to => User.roles(3)
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
            available_receivers.include?(value) ||
            (available_receivers.empty? && value.nil?)
        end
      end
    end
  end

  validates  :seller_id,
             :uniqueness => {
               :scope => [
                 :product_id,
                 :supplier_id,
                 :event,
                 :for,
                 :purpose
               ]
             },
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

  validates :purpose,
            :presence => true

  before_validation do
    self.supplier = nil if self.product
  end

  before_validation(:on => :create) do
    self.enabled = true if self.enabled.nil?
    self.should_send = true if self.should_send.nil?
  end

  def parse_message(event_attribute_values = {})
    event_attributes = {}
    EVENTS[self.event.to_sym][:notification_attributes].each do |k,v|
      event_attributes[k] = v.call(event_attribute_values)
    end
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
      :purpose => "to inform me about a new customer order",
      :message => I18n.t(
        "notifications.messages.custom.customer_completed_payment"
      )
    )
    create!(
      :event => "supplier_order_created",
      :for => "supplier",
      :purpose => "to inform the supplier about a new order",
      :message => I18n.t(
        "notifications.messages.custom.new_order_from_seller"
      )
    )
    notification = new(
      :event => "supplier_order_created",
      :for => "supplier",
      :purpose => "to inform the supplier about a new order",
      :should_send => false
    )
    notification.supplier = notification.seller
    notification.save!
    create!(
      :event => "line_item_created",
      :for => "seller",
      :purpose => "to inform me which supplier a line item was sent to",
      :message => I18n.t(
        "notifications.messages.custom.line_item_was_sent_to"
      )
    )
    notification = new(
      :event => "line_item_created",
      :for => "seller",
      :purpose => "to inform me which supplier a line item was sent to",
      :should_send => false
    )
    notification.supplier = notification.seller
    notification.save!
    create!(
      :event => "line_item_created",
      :for => "supplier",
      :purpose => "to inform the supplier about the line item details",
      :message => I18n.t(
        "notifications.messages.custom.line_item_details_for_supplier"
      )
    )
    notification = new(
      :event => "line_item_created",
      :for => "supplier",
      :purpose => "to inform the supplier about the line item details",
      :message => I18n.t(
        "notifications.messages.custom.line_item_details_for_seller"
      )
    )
    notification.supplier = notification.seller
    notification.save!
    create!(
      :event => "supplier_order_confirmed",
      :for => "supplier",
      :purpose => "to inform the supplier of the shipping instructions",
      :message => I18n.t(
        "notifications.messages.custom.send_the_order_to"
      )
    )
    create!(
      :event => "supplier_order_completed",
      :for => "supplier",
      :purpose => "to confirm that the order was successfully completed",
      :message => I18n.t(
        "notifications.messages.custom.you_successfully_completed_the_order"
      )
    )
    create!(
      :event => "customer_order_confirmed",
      :for => "seller",
      :purpose => "to inform me that the seller order has been confirmed",
      :message => I18n.t(
        "notifications.messages.custom.order_has_been_confirmed"
      )
    )
    notification = new(
      :event => "customer_order_confirmed",
      :for => "seller",
      :purpose => "to inform me that the customer order has been confirmed",
      :should_send => false
    )
    notification.supplier = notification.seller
    notification.save!
    create!(
      :event => "customer_order_completed",
      :for => "seller",
      :purpose => "to inform me that the customer order has been completed",
      :message => I18n.t(
        "notifications.messages.custom.order_has_been_completed"
      )
    )
    notification = new(
      :event => "customer_order_confirmed",
      :for => "seller",
      :purpose => "to inform me that the customer order has been completed",
      :should_send => false
    )
    notification.supplier = notification.seller
    notification.save!
    create!(
      :event => "supplier_payment_completed",
      :for => "seller",
      :purpose => "to inform me that my supplier has been paid",
      :message => I18n.t(
        "notifications.messages.custom.your_supplier_payment_was_successful"
      )
    )
    create!(
      :event => "supplier_payment_completed",
      :for => "supplier",
      :purpose => "to inform my supplier that they have been paid",
      :message => I18n.t(
        "notifications.messages.custom.you_have_received_a_payment"
      )
    )
  end
end

