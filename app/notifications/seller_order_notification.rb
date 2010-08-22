class SellerOrderNotification < Conversation

  GENERAL_ATTRIBUTES = {
    :seller_name => Proc.new{|params|
      params[:seller].name
    },
    :number_of_cart_items => Proc.new{|params|
      params[:order_notification].number_of_cart_items.to_s
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

  PRODUCT_ATTRIBUTES = {
    :product_number => Proc.new{|params|
      params[:product].number.to_s
    },
    :product_name => Proc.new{|params|
      params[:product].name.to_s
    }
  }

  ITEM_ATTRIBUTES = {
    :item_number => Proc.new{|params|
      params[:item_number].to_s
    },
    :item_name => Proc.new{|params|
      params[:item_name]
    },
    :item_quantity => Proc.new{|params|
      params[:item_quantity].to_s
    }
  }

  SEND_TO_MASK = 1

  def notify(notification, options = {})
    say notification.parse_message(options)
  end
end

