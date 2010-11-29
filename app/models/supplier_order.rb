class SupplierOrder < ActiveRecord::Base

  belongs_to :seller_order

  belongs_to :supplier,
             :class_name => "User"

  has_many   :line_items

  has_one    :payment

  validates :seller_order,
            :supplier,
            :presence => true

  validates :supplier_id,
            :uniqueness => {:scope => :seller_order_id}

  validates :tracking_number,
            :uniqueness => {:scope => :supplier_id, :case_sensitive => false},
            :allow_nil => true

  scope :incomplete, where(:completed_at => nil)
  scope :unconfirmed, where(:confirmed_at => nil)

  def supplier_total
    line_items.each do |line_item|
      line_item_subtotal = line_item.supplier_subtotal
      break if total && total.currency != line_item_subtotal.currency
      total ? total += line_item_subtotal : line_item_subtotal
    end
    total if total
  end

  def human_tracking_number
    tracking_number ? tracking_number :
    I18n.t(
      "activerecord.default_attribute_values.supplier_order.tracking_number"
    )
  end

  def line_item_numbers
    line_item_numbers = []
    line_items.each do |line_item|
      line_item_numbers << "##{line_item.id}"
    end
    line_item_numbers.to_sentence
  end

  def number_of_line_items
    line_items.count
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

  def complete!
    self.update_attributes!(:completed_at => Time.now)
  end

  def confirm!
    self.update_attributes!(
      :confirmed_at => Time.now
    ) if line_items.unconfirmed.empty?
  end

  def self.find_or_create_for!(supplier)
    record = where(:supplier_id => supplier.id).first
    record = scoped.create!(:supplier => supplier) unless record
    record
  end
end

