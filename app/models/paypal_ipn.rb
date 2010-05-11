class PaypalIpn < ActiveRecord::Base
  serialize  :params
  belongs_to :customer_order, :class_name => "Order"
  before_create :create_order
  
  private
    def create_order
      seller = User.with_role("seller").where(["email = ?", params[:receiver_email]]).first
      # if no seller it means that either the user is not registered as a seller
      # or they do not exist in the system with this email....probably need to notifiy
      # myself if this happens...
      self.customer_order = Order.create!(:seller => seller,
        :supplier_orders_attributes=>build_supplier_orders_attributes)
    end
    
    # Will return a hash in the following format
    # {
    #   "0" => {
    #     :details => "Some details no longer than 160 chars",
    #     :line_item_attributes => {
    #       :item_number => "12345"
    #       :quantity => "2"
    #     }
    #   },
    #   "1" => {
    #     :details => "Some details no longer than 160 chars",
    #     :line_item_attributes => {
    #       :item_number => "23456"
    #       :quantity => "1"
    #     }
    #   }
    # }
    def build_supplier_orders_attributes
      supplier_orders_attributes = {}
      params["num_cart_items"].to_i.times do |index|
        supplier_orders_attributes["#{index}"] = {
          :line_item_attributes=>{
            :item_number=>params["item_number#{index + 1}"],
            :quantity => params["quantity#{index + 1}"]
          }
        }
      end
      supplier_orders_attributes
    end
    
    def build_supplier_order_details
      
    end
end
