class SellerOrder < ActiveRecord::Base

  belongs_to :seller,
             :class_name => "User"

  belongs_to :order_notification, :polymorphic => true

  has_many   :line_items

  has_many   :supplier_orders

  has_many   :suppliers,
             :through => :supplier_orders,
             :uniq => true,
             :readonly => false

  validates :seller,
            :order_notification,
            :presence => true

  scope :incomplete, where(:completed_at => nil)

  def supplier
    suppliers.first if suppliers.count == 1
  end

  def supplier_names_and_mobile_numbers(include_seller = false)
    names_and_mobile_numbers = []
    suppliers.each do |supplier|
      names_and_mobile_numbers << "#{supplier.name} (#{supplier.human_active_mobile_number})" unless include_seller || seller == supplier
    end
    names_and_mobile_numbers.to_sentence
  end

  def tracking_numbers(include_seller = false)
    tracking_numbers = []
    supplier_orders.each do |supplier_order|
      tracking_number = supplier_order.human_tracking_number
      tracking_numbers << tracking_number unless include_seller || seller == supplier
    end
    tracking_numbers.to_sentence
  end

  def tracking_numbers?(include_seller = false)
    tracking_numbers = nil
    supplier_orders.each do |supplier_order|
      tracking_numbers = !supplier_order.tracking_number.nil? unless include_seller || seller == supplier
      break if tracking_numbers
    end
    tracking_numbers
  end

  def confirmed?
    !unconfirmed?
  end

  def unconfirmed?
    self.confirmed_at.nil?
  end

  def completed?
    !incomplete?
  end

  def incomplete?
    self.completed_at.nil?
  end

  def confirm
    self.update_attributes(
      :confirmed_at => Time.now
    ) if supplier_orders.unconfirmed.empty?
  end

  def complete
    self.update_attributes(
      :completed_at => Time.now
    ) if supplier_orders.incomplete.empty?
  end

  def order_notification_with_type
    order_notification = order_notification_without_type
    order_notification.respond_to?(:type) ?
      order_notification.type :
      order_notification
  end

  alias_method_chain :order_notification, :type

end

