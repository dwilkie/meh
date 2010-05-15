class PaypalIpn < ActiveRecord::Base
  serialize  :params
  belongs_to :customer_order, :class_name => "Order"
  before_create :create_order
  
  private
    def create_order
      seller = User.with_role("seller").where(
        ["email = ?", params[:receiver_email]]
      ).first
      # if no seller it means that either the user is not registered as a seller
      # or they do not exist in the system with this email....probably need to notifiy
      # myself if this happens...
      self.customer_order = Order.create!(:seller => seller,
        :supplier_orders_attributes=>build_supplier_orders_attributes(seller))
    end
    
    # Will return a hash in the following format ready for mass assignment
    # {
    #   "0" => {
    #     :supplier => #<User id: 1>,
    #     :details => "Some details no longer than 160 chars",
    #     :product => #<Product id: 1, external_id: 12345>
    #     :quantity => 2
    #   },
    #   "1" => {
    #     :supplier => #<User id: 1>,
    #     :details => "Some details no longer than 160 chars",
    #     :product => #<Product id: 2, external_id: 45678>
    #     :quantity => 1
    #   }
    # }
    def build_supplier_orders_attributes(seller)
      supplier_orders_attributes = {}
      params["num_cart_items"].to_i.times do |index|
        product = seller.selling_products.where("external_id = ?",
                  params["item_number#{index + 1}"]).first
        supplier_orders_attributes["#{index}"] = {
          :supplier => product.supplier,
          :product => product,
          :quantity => params["quantity#{index + 1}"].to_i
        }
      end
      supplier_orders_attributes
    end
    
    def build_supplier_order_details
      
    end
end
