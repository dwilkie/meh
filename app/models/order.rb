#require 'ebay'
class Order < ActiveRecord::Base
  belongs_to :supplier, :class_name => "User"
  belongs_to :seller, :class_name => "User"
  
  has_many   :supplier_orders, :foreign_key => "seller_order_id", :class_name => "Order"
  belongs_to :seller_order, :class_name => "Order"

  has_one :line_item, :foreign_key => "supplier_order_id"

#  def initialize(raw_notification)
#    ebay_notification = Ebay::Notification.new(raw_notification)
#    ebay_paypal_email = ebay_notification.transactions.first.paypal_email_address

#    puts "Seller paypal email: " + ebay_paypal_email
#    puts "Ebay Item ID: " + ebay_notification.body.item.item_id
#    puts "Event name: " + ebay_notification.event_name

#     note ebay_item.seller returns a Ebay::Types::User
#     product = Product.joins(:seller).where(
#              ["external_id = ? AND users.email = ?",
#               ebay_item.item_id, ebay_item.seller.email]).first
#  end
end
