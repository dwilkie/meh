{
  :'en' => {
    :messages => {
      :base => lambda { |key, options|
        I18n.t("messages.elements.greeting", :name => options[:name]) << options[:body]
      },
      :elements => {
        :greeting => "Hey %{name}, "
      },
      :commands => {
        :elements => {
          :pin_number => "<ur pin code>",
          :order_number => "<order number>",
          :quantity => "<quantity>",
          :pv_code => "<pv code>"
        },
        :base => lambda { |key, options|
          I18n.t("messages.commands.elements.pin_number") << " " << options[:command]
        },
        :templates => {
          :acceptorder => lambda { |key, options|
            options[:order_number] ||= I18n.t("messages.commands.elements.order_number")
            options[:quantity] ||= I18n.t("messages.commands.elements.quantity")
            options[:pv_code] ||= I18n.t("messages.commands.elements.pv_code")
            I18n.t(
              "messages.commands.base",
              :command => "acceptorder #{options[:order_number]} #{options[:quantity]} x #{options[:pv_code]}"
            )
          },
          :rejectorder => lambda { |key, options|
            options[:order_number] ||= I18n.t("messages.commands.elements.order_number")
            I18n.t(
              "messages.commands.base",
              :command => "rejectorder #{options[:order_number]}"
            )
          },
          :completeorder => lambda { |key, options|
            options[:order_number] ||= I18n.t("messages.commands.elements.order_number")
            I18n.t(
              "messages.commands.base",
              :command => "completeorder #{options[:order_number]}"
            )
          }
        }
      },
      :supplier_order_notification => lambda { |key, options|
        message = "u have a new order ##{options[:order_number]} "
        message << "from #{options[:seller]} (#{options[:seller_contact_details]}) " if
          options[:seller]
        message << "for #{options[:quantity]} x "
        message << "your product " unless options[:seller]
        message << "##{options[:product_code]}. To accept the order, look up the pv code for ##{options[:product_code]} and reply with: " << 
        I18n.t(
          "messages.commands.templates.acceptorder",
          :order_number => options[:order_number],
          :quantity => options[:quantity]
          ) <<
        ". To reject the order reply with: " <<
        I18n.t(
          "messages.commands.templates.rejectorder",
          :order_number => options[:order_number]
        ) << "."
        I18n.t("messages.base", :name => options[:supplier], :body => message)
      },
      :process_order_invalid_message => lambda { |key, options|
        message = "u just sent us: \"#{options[:raw_message]}\". The order can't be " <<
        I18n.t(
          "activerecord.attribute_values.order.status.#{options[:processed]}"
        ) <<
        " because the #{options[:errors]}. Please check the details and try again. The format is: " <<
        I18n.t(
          "messages.commands.templates.#{options[:command]}"
        )
        I18n.t("messages.base", :name => options[:supplier], :body => message)
      },
      :successfully_processed_order => lambda { |key, options|
        message = "u successfully " << 
        I18n.t("activerecord.attribute_values.order.status.#{options[:processed]}") <<
        " the order ##{options[:order_number]}."
        I18n.t("messages.base", :name => options[:supplier], :body => message)
      },
      :cannot_process_order => lambda { |key, options|
        message = "we cannot process ur request because this order is " << 
        I18n.t("activerecord.attribute_values.order.status.#{options[:status]}")
        I18n.t("messages.base", :name => options[:supplier], :body => message)
      },
      :confirm_reject_order => lambda { |key, options|
        message = "r u sure u want to reject this order? Text: " << 
        I18n.t(
          "messages.commands.templates.rejectorder",
          :order_number => options[:order_number]
        ) << " CONFIRM! to go ahead and reject the order."
        I18n.t("messages.base", :name => options[:supplier], :body => message)
      },
      :unauthorized => lambda { |key, options|
        message = "u're not authorized to issue the command #{options[:command]}"
        I18n.t("messages.base", :name => options[:name], :body => message)
      },
      :supplier_processed_sellers_order_notification => lambda { |key, options|
        message = "#{options[:supplier]} (#{options[:supplier_contact_details]}) " <<
        I18n.t("activerecord.attribute_values.order.status.#{options[:processed]}") <<
        " their order ##{options[:supplier_order_number]} for ur product ##{options[:product_code]} which is part of your order ##{options[:seller_order_number]}."
        I18n.t("messages.base", :name => options[:seller], :body => message)
      },
      :not_authenticated => lambda { |key, options|
        "Hey, we could not process ur request because your #{options[:errors]}. Try again with " <<
        I18n.t("messages.commands.base", :command => "<your request>")
      },
      :order_details_notification => lambda { |key, options|
        message = "here r the details for order: ##{options[:order_number]}, product: ##{options[:product_code]}: #{options[:details]}. Reply with " <<
        I18n.t(
          "messages.commands.templates.completeorder",
          :order_number => options[:order_number]
        ) << " when ur done."
        I18n.t("messages.base", :name => options[:supplier], :body => message)
      }
    },
    :activerecord => {
      :attribute_values => {
        :order => {
          :status => {
            :accepted => "accepted",
            :rejected => "rejected",
            :completed => "completed",
            :unconfirmed => "unconfirmed"
          }
        }
      }
    },
    :errors => {
      :messages => {
        :not_matching_order_quantity => "isn't %{value} for this order",
        :not_matching_product_verification_code => "isn't %{value} for this product"
      }
    },
    :activemodel => {
      :errors => {
        :models => {
          :'abstract_process_order_conversation/order_message' => {
            :attributes => {
              :order => {
                :blank => "can't be found"
              }
            }
          },
          :'rejectorder_conversation/reject_order_message' => {
            :attributes => {
              :confirmation => {
                :invalid => "must be CONFIRM! if you really want to reject the order"
              }
            }
          },
          :'not_authenticated_conversation/unauthenticated_message' => {
            :attributes => {
              :pin_number => {
                :incorrect => "was incorrect",
                :invalid => "was not supplied, or it was invalid (should be 4 digits)",
                :blank => "must be supplied"
              }
            }
          }
        }
      }
    }
  }
}
