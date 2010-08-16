class Notification < ActiveRecord::Base

  belongs_to :seller,
             :class_name => "User"

  belongs_to :product

  ATTRIBUTES = {
    :supplier_order_processed => {
      :supplier_order_number,
      :seller_order_number,
      :supplier_name,
      :seller_name,
      :supplier_mobile_number,
      :seller_mobile_number
    }
  }

  EVENTS = {
    :supplier_order_accepted => ATTRIBUTES[:supplier_order_processed],
    :supplier_order_rejected => ATTRIBUTES[:supplier_order_processed],
    :supplier_order_completed => ATTRIBUTES[:supplier_order_processed]
  }

  validates  :message, :seller,
             :presence => true

  validates  :event,
             :inclusion => {:in => EVENTS.keys.to_s},
             :presence => true

  validates  :for,
             :inclusion => {:in => User::ROLES},
             :presence => true

  before_validation :link_supplier

  def parse_message(event_attributes)
    "Congratulations your order has been accepted. Your order number is <order_number>"
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

  def send_to(seller, seller)
    if self.for == "seller"
      seller
    elsif self.for == "supplier"
      supplier
    end
  end

  def self.for_event(event, options)
    if options[:seller] && options[:supplier] && options[:seller] == options[:supplier]
      scope = for_supplier_who_is_a_seller
    end
  end

  private
    def link_supplier
      product = self.product
      self.seller = product.seller if product
    end
end

