class SupplierOrderNotification < Conversation

  ATTRIBUTES = [
    :supplier_order_number => Proc.new{|*args|
      args[:supplier_order].id.to_s
    },
    :seller_order_number => Proc.new{|*args|
      args[:seller_order].id.to_s
    },
    :supplier_name => Proc.new{|*args|
      args[:supplier].name
    },
    :seller_name => Proc.new{|*args|
      args[:seller].name
    },
    :supplier_mobile_number => Proc.new{|*args|
      args[:supplier].mobile_number.humanize
    },
    :seller_mobile_number => Proc.new{|*args|
      args[:seller].mobile_number.humanize
    },
    :customer_address => Proc.new{|*args|
      args[:order_notification].customer_address
    },
    :customer_address_name => Proc.new{|*args|
      args[:order_notification].customer_address_name
    },
    :customer_address_street => Proc.new{|*args|
      args[:order_notification].customer_address_street
    },
    :customer_address_city => Proc.new{|*args|
      args[:order_notification].customer_address_city
    },
    :customer_address_state => Proc.new{|*args|
      args[:order_notification].customer_address_state
    },
    :customer_address_zip => Proc.new{|*args|
      args[:order_notification].customer_address_zip
    },
    :customer_address_country => Proc.new{|*args|
      args[:order_notification].customer_address_country
    }
  ]

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

