class SellerOrderNotification < Conversation

  ATTRIBUTES = {
    :seller_name => Proc.new{|params|
      params[:seller].name
    },
    :number_of_cart_items => Proc.new{|params|
      params[:order_notification].number_of_cart_items
    },
    :customer_address => Proc.new{|params|
      params[:order_notification].customer_address
    },
    :customer_address_name => Proc.new{|params|
      params[:order_notification].customer_address_name
    },
    :customer_address_street => Proc.new{|params|
      params[:order_notification].customer_address_street
    },
    :customer_address_city => Proc.new{|params|
      params[:order_notification].customer_address_city
    },
    :customer_address_state => Proc.new{|params|
      params[:order_notification].customer_address_state
    },
    :customer_address_country => Proc.new{|params|
      params[:order_notification].customer_address_country
    },
    :customer_address_zip => Proc.new{|params|
      params[:order_notification].customer_address_zip
    }
  }

  SEND_TO_MASK = 1

  def products_not_found(seller_order, number_of_missing_products, number_of_items)
    say I18n.t(
      "messages.products_not_found_notification",
      :seller => seller_order.seller.name,
      :seller_order_number => seller_order.id.to_s,
      :number_of_missing_products => number_of_missing_products,
      :number_of_items => number_of_items
    )
  end
end

