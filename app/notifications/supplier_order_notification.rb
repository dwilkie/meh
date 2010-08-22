class SupplierOrderNotification < Conversation

  ATTRIBUTES = {
    :product_order_number => Proc.new{|params|
      params[:supplier_order].id.to_s
    },
    :customer_order_number => Proc.new{|params|
      params[:seller_order].id.to_s
    },
    :supplier_name => Proc.new{|params|
      params[:supplier].name
    },
    :seller_name => Proc.new{|params|
      params[:seller].name
    },
    :supplier_mobile_number => Proc.new{|params|
      params[:supplier].mobile_number.humanize
    },
    :seller_mobile_number => Proc.new{|params|
      params[:seller].mobile_number.humanize
    },
    :supplier_email => Proc.new{|params|
      params[:supplier].email
    },
    :seller_email => Proc.new{|params|
      params[:seller].email
    },
    :product_order_quantity => Proc.new{|params|
      params[:supplier_order].quantity.to_s
    },
    :product_number => Proc.new{|params|
      params[:product].number
    },
    :product_name => Proc.new{|params|
      params[:product].name
    },
    :product_verification_code => Proc.new{|params|
      params[:product].verification_code
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

  SEND_TO_MASK = 3

  def notify(notification, options = {})
    say notification.parse_message(options)
  end
end

