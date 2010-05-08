require 'ebay'
class Order < ActiveRecord::Base
  belongs_to :product

  def initialize(raw_notification)
    ebay_notification = Ebay::Notification.new(raw_notification)
    ebay_paypal_email = ebay_notification.transactions.first.paypal_email_address

    puts "Seller paypal email: " + ebay_paypal_email
    puts "Ebay Item ID: " + ebay_notification.body.item.item_id
    puts "Event name: " + ebay_notification.event_name

    # note ebay_item.seller returns a Ebay::Types::User
    product = Product.joins(:seller).where(
              ["external_id = ? AND users.email = ?",
               ebay_item.item_id, ebay_item.seller.email]).first
  end
end
