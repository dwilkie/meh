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
      :number_of_cart_items => Proc.new { |options|
        options[:order_notification].number_of_cart_items.to_s
      },
      :customer_order_payment_currency => Proc.new { |options|
        options[:order_notification].payment_currency
      },
      :customer_order_gross_payment => Proc.new { |options|
        options[:order_notification].gross_payment_amount.to_s
      }
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
    :product_order => {
      :product_order_number => Proc.new { |options|
        options[:product_order].id.to_s
      },
      :product_order_quantity => Proc.new { |options|
        options[:product_order].quantity.to_s
      }
    },
    :item => {
      :item_number => Proc.new { |options|
        options[:item_number].to_s
      },
      :item_name => Proc.new { |options|
        options[:item_name].to_s
      },
      :item_quantity => Proc.new { |options|
        options[:item_quantity].to_s
      }
    },
    :seller => {
      :seller_name => Proc.new { |options|
        options[:seller].name
      },
      :seller_mobile_number => Proc.new { |options|
        active_mobile_number = options[:seller].active_mobile_number
        active_mobile_number && active_mobile_number.verified? ?
        active_mobile_number.humanize :
        I18n.t(
          "notifications.messages.custom.attributes.mobile_number.not_verified"
        )
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
        active_mobile_number = options[:supplier].active_mobile_number
        active_mobile_number && active_mobile_number.verified? ?
        active_mobile_number.humanize :
        I18n.t(
          "notifications.messages.custom.attributes.mobile_number.not_verified"
        )
      },
      :supplier_email => Proc.new { |options|
        options[:supplier].email
      },
      :and_or_but_not_sent => Proc.new { |options|
        active_mobile_number = options[:supplier].active_mobile_number
        active_mobile_number && active_mobile_number.verified? ?
        I18n.t(
          "notifications.messages.custom.attributes.and_or_but_not_sent.and_sent"
        ) : I18n.t(
          "notifications.messages.custom.attributes.and_or_but_not_sent.but_not_sent"
        )
      }
    },
    :tracking_number => Proc.new { |options|
      options[:product_order].tracking_number.to_s
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

  COMMON_EVENT_ATTRIBUTES = {
    :product_order => EVENT_ATTRIBUTES[:seller_order].merge(
      EVENT_ATTRIBUTES[:product_order]
    ).merge(
      EVENT_ATTRIBUTES[:product]
    ).merge(
      EVENT_ATTRIBUTES[:customer_address]
    ).merge(
      EVENT_ATTRIBUTES[:seller]
    ).merge(
      EVENT_ATTRIBUTES[:supplier]
    ),
    :seller_order => EVENT_ATTRIBUTES[:seller_order].merge(
      :seller_name => EVENT_ATTRIBUTES[:seller][:seller_name]
    )
  }

  EVENTS = {
    :customer_order_created => {
      :notification_attributes => EVENT_ATTRIBUTES[:customer_address].merge(
        COMMON_EVENT_ATTRIBUTES[:seller_order]
      ),
      :send_notification_to => User.roles(1)
    },
    :product_order_created => {
      :notification_attributes => COMMON_EVENT_ATTRIBUTES[:product_order],
      :send_notification_to => User.roles(3)
    },
    :product_order_accepted => {
      :notification_attributes => COMMON_EVENT_ATTRIBUTES[:product_order],
      :send_notification_to => User.roles(3)
    },
    :product_order_completed => {
      :notification_attributes => COMMON_EVENT_ATTRIBUTES[:product_order].merge(
        :tracking_number => EVENT_ATTRIBUTES[:tracking_number]
      ),
      :send_notification_to => User.roles(3)
    },
    :supplier_payment_successfully_completed => {
      :notification_attributes => COMMON_EVENT_ATTRIBUTES[:product_order].merge(
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
      :purpose => "to inform me about the customer order details",
      :message => I18n.t(
        "notifications.messages.custom.a_customer_completed_payment_for"
      )
    )
    create!(
      :event => "product_order_created",
      :for => "seller",
      :purpose => "to inform me which supplier a product order was sent to",
      :message => I18n.t(
        "notifications.messages.custom.product_order_was_sent_to"
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
        "notifications.messages.custom.new_product_order_from_seller_for_the_following_item"
      )
    )
    notification = new(
      :event => "product_order_created",
      :for => "supplier",
      :purpose => "to inform the supplier about the product order details",
      :message => I18n.t(
        "notifications.messages.custom.your_customer_bought_the_following_item"
      )
    )
    notification.supplier = notification.seller
    notification.save!
    create!(
      :event => "product_order_accepted",
      :for => "seller",
      :purpose => "to inform me when a supplier accepts a product order",
      :message => I18n.t(
        "notifications.messages.custom.your_supplier_processed_their_product_order",
        :processed => "ACCEPTED"
      )
    )
    create!(
      :event => "product_order_accepted",
      :for => "supplier",
      :purpose => "to inform the supplier of the shipping instructions",
      :message => I18n.t(
        "notifications.messages.custom.send_the_product_to"
      )
    )
    create!(
      :event => "product_order_completed",
      :for => "seller",
      :purpose => "to inform me when a supplier completes a product order",
      :message => I18n.t(
        "notifications.messages.custom.your_supplier_processed_their_product_order",
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
      :event => "supplier_payment_successfully_completed",
      :for => "seller",
      :purpose => "to inform me that my supplier has been paid",
      :message => I18n.t(
        "notifications.messages.custom.your_supplier_payment_was_successful"
      )
    )
    create!(
      :event => "supplier_payment_successfully_completed",
      :for => "supplier",
      :purpose => "to inform my supplier that they have been paid",
      :message => I18n.t(
        "notifications.messages.custom.you_have_received_a_payment"
      )
    )
  end
end

