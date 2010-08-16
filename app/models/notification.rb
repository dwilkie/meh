class Notification < ActiveRecord::Base

  belongs_to :seller,
             :class_name => "User"

  belongs_to :product

  EVENTS = {
    :supplier_order_accepted => {
      :notification_attributes => SupplierOrderNotification.ATTRIBUTES,
      :notification_sent_to => SupplierOrderNotification.SENT_TO
    },
    :supplier_order_rejected => {
      :notification_attributes => SupplierOrderNotification.ATTRIBUTES,
      :notification_sent_to => SupplierOrderNotification.SENT_TO
    },
    :supplier_order_completed => {
      :notification_attributes => SupplierOrderNotification.ATTRIBUTES,
      :notification_sent_to => SupplierOrderNotification.SENT_TO
    }
    :supplier_order_created => {
      :notification_attributes => SupplierOrderNotification.ATTRIBUTES,
      :notification_sent_to => SupplierOrderNotification.SENT_TO
    }
  }

  SENT_TO = %w[seller supplier supplier_who_is_also_the_seller]

  validates  :message, :seller,
             :presence => true

  validates  :event,
             :inclusion => {:in => EVENTS.keys.to_s},
             :presence => true

  validates  :for,
             :inclusion => {:in => SENT_TO},
             :presence => true

  before_validation :link_supplier

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
    elsif self.for == "supplier_who_is_also_the_seller"
      seller
    end
  end

  def self.for_event(event, options = {})
    scope = where(:event => event)
    if options[:seller] && options[:supplier] && options[:seller] == options[:supplier]
      scope = scope.where(:for => "supplier_who_is_also_the_seller")
    end
    notifications = []
    if options[:product]
      notifications = scope.where(:product => options[:product]).all
    end
    if notifications.empty?
      notifications = scope.all
    end
    notifications
  end

  private
    def link_supplier
      product = self.product
      self.seller = product.seller if product
    end
end

