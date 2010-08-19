class SupplierOrderNotification < Conversation

  ATTRIBUTES = {
    :supplier_order_number => Proc.new{|params|
      params[:supplier_order].id.to_s
    },
    :seller_order_number => Proc.new{|params|
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

  def notify(notification, supplier_order, seller_order, seller, product, supplier)
    say notification.parse_message(
      event_attributes(
        supplier_order,
        seller_order,
        seller,
        product,
        supplier
      )
    )
  end

  private

    def event_attributes(supplier_order, seller_order, seller, product, supplier)
      order_notification = seller_order.order_notification
      event_attributes = {}
      ATTRIBUTES.each do |k, v|
        event_attributes[k] = v.call(
          :order_notification => order_notification,
          :supplier_order => supplier_order,
          :seller_order => seller_order,
          :seller => seller,
          :product => product,
          :supplier => supplier
        )
      end
      event_attributes
    end
end

