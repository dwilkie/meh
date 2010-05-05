require 'ebay'
class Order < ActiveRecord::Base
  belongs_to :product

  def initialize(raw_notification)
    ebay_notification = Ebay::Notification.new(raw_notification)
    ebay_item = ebay_notification.body.item
    # note ebay_item.seller returns a Ebay::Types::User
    self.product = Product.joins(:seller).where(
              ["external_id = ? AND users.email = ?",
               ebay_item.item_id, ebay_item.seller.email]).first

    puts "Ebay item id: " + 
    # self.external_id = ebay_item.item_id.to_i

    seller_email = ebay_item.seller.email
    puts "Event name: " + ebay_notification.event_name
    puts "Seller email: " + seller_email
  end
end
