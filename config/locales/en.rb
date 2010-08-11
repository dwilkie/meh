{
  :'en' => {
    :messages => {
      :base => lambda { |key, options|
        I18n.t("messages.elements.greeting", :name => options[:name]) << options[:body]
      },
      :invalid_text_message => lambda { |key, options|
        "u just sent us: \"#{options[:raw_message]}\". #{options[:action]} because the #{options[:errors]}. Please check the details and try again. The format is: " <<
        I18n.t(
          "messages.commands.templates.#{options[:command]}"
        )
      },
      :elements => {
        :greeting => "Hi %{name}, ",
        :shared => {
          :order_details_for_seller => "order(#%{supplier_order_number}) of %{quantity} x product(#%{product_code}) which is part of ur seller order(#%{seller_order_number})",
          :supplier_details => "%{supplier} (%{supplier_contact_details})"
        }
      },
      :commands => {
        :elements => {
          :pin_number => "<ur pin code>",
          :order_number => "<order number>",
          :quantity => "<quantity>",
          :pv_code => "<pv code>",
          :confirm => "CONFIRM!",
          :supplier_order_number => "<supplier order number>",
          :seller_order_number => "<customer order number>",
          :tracking_number => "<tracking number>"
        },
        :templates => {
          :acceptorder => lambda { |key, options|
            options[:order_number] ||= I18n.t(
              "messages.commands.elements.order_number"
            )
            options[:quantity] ||= I18n.t("messages.commands.elements.quantity")
            options[:pv_code] ||= I18n.t("messages.commands.elements.pv_code")
            "acceptorder " <<
            I18n.t(
              "messages.commands.elements.pin_number"
            ) << " " <<
            options[:order_number] << " " <<
            options[:quantity] << " x " <<
            options[:pv_code]
          },
          :rejectorder => lambda { |key, options|
            options[:order_number] ||= I18n.t(
              "messages.commands.elements.order_number"
            )
            "rejectorder" << " " <<
            I18n.t(
              "messages.commands.elements.pin_number"
            ) << " " <<
            options[:order_number]
          },
          :completeorder => lambda { |key, options|
            options[:order_number] ||= I18n.t(
              "messages.commands.elements.order_number"
            )
            options[:tracking_number] ||= I18n.t(
              "messages.commands.elements.tracking_number"
            )
            "completeorder" << " " <<
            I18n.t(
              "messages.commands.elements.pin_number"
            ) << " " <<
            options[:order_number] << " " <<
            options[:tracking_number]
          },
          :pay4order => lambda { |key, options|
            options[:seller_order_number] ||= I18n.t(
              "messages.commands.elements.seller_order_number"
            )
            options[:supplier_order_number] ||= I18n.t(
              "messages.commands.elements.supplier_order_number"
            )
            "pay4order" << " " <<
            options[:seller_order_number] << " " <<
            options[:supplier_order_number]
          },
          :paymentdetails => lambda { |key, options|
            options[:supplier_order_number] ||= I18n.t(
              "messages.commands.elements.order_number"
            )
            "paymentdetails" << " " <<
            options[:supplier_order_number]
          },
          :sendorder => lambda { |key, options|
            options[:seller_order_number] ||= I18n.t(
              "messages.commands.elements.order_number"
            )
            command = "sendorder " <<
            I18n.t(
              "messages.commands.elements.pin_number"
            ) << " " <<
            options[:seller_order_number]
            command << " " << options[:supplier_name] if options[:supplier_name]
            command
          },
          :missingproducts => lambda { |key, options|
            options[:seller_order_number] ||= I18n.t(
              "messages.commands.elements.order_number"
            )
            "missingproducts " <<
            I18n.t(
              "messages.commands.elements.pin_number"
            ) << " " <<
            options[:seller_order_number]
          }
        }
      },
      :supplier_order_notification => lambda { |key, options|
        message = "u have a new order ##{options[:order_number]} "
        message << "from #{options[:seller]} (#{options[:seller_contact_details]}) " if
          options[:seller]
        message << "for #{options[:quantity]} x "
        message << "your product " unless options[:seller]
        message << "##{options[:product_code]}. To accept the order, look up the pv code for the product and reply with: " <<
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
        message = "The order can't be " <<
        I18n.t(
          "activerecord.attribute_values.order.status.#{options[:processed]}"
        )
        message = I18n.t(
          "messages.invalid_text_message",
          :action => message,
          :command => options[:command],
          :raw_message => options[:raw_message],
          :errors => options[:errors]
        )
        I18n.t("messages.base", :name => options[:user], :body => message)
      },
      :pay4order_invalid_message => lambda { |key, options|
        message = I18n.t(
          "messages.invalid_text_message",
          :action => "We couldn't process your request",
          :command => options[:command],
          :raw_message => options[:raw_message],
          :errors => options[:errors]
        )
        I18n.t("messages.base", :name => options[:user], :body => message)
      },
      :successfully_processed_order => lambda { |key, options|
        message = "u successfully " <<
        I18n.t("activerecord.attribute_values.order.status.#{options[:processed]}") <<
        " the order ##{options[:order_number]}."
        I18n.t("messages.base", :name => options[:supplier], :body => message)
      },
      :cannot_process_order => lambda { |key, options|
        status_wording = options[:status] == "unconfirmed" ?
        "is not yet confirmed" :
        "was already " <<
        I18n.t(
          "activerecord.attribute_values.order.status.#{options[:status]}"
        )
        message = "we cannot process ur request because this order " <<
        status_wording
        I18n.t("messages.base", :name => options[:supplier], :body => message)
      },
      :confirm_reject_order => lambda { |key, options|
        message = "r u sure u want to reject the order ##{options[:order_number]}? Text: " <<
        I18n.t(
          "messages.commands.templates.rejectorder",
          :order_number => options[:order_number]
        ) << " " <<
        I18n.t(
          "messages.commands.elements.confirm"
          ) << " to go ahead and reject the order."
        I18n.t("messages.base", :name => options[:supplier], :body => message)
      },
      :unauthorized => lambda { |key, options|
        message = "you're not authorized to issue this command"
        I18n.t("messages.base", :name => options[:name], :body => message)
      },
      :supplier_processed_sellers_order_notification => lambda { |key, options|
        message = I18n.t(
          "messages.elements.shared.supplier_details",
          :supplier => options[:supplier],
          :supplier_contact_details => options[:supplier_contact_details]
        ) << " has marked their " <<
        I18n.t(
          "messages.elements.shared.order_details_for_seller",
          :supplier_order_number => options[:supplier_order_number],
          :quantity => options[:quantity],
          :product_code => options[:product_code],
          :seller_order_number => options[:seller_order_number]
        ) << " as " <<
        I18n.t(
          "activerecord.attribute_values.order.status.#{options[:processed]}"
        ) << "."
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
      },
      :confirm_payment_notification => lambda {|key, options|
        message = "u r about to pay " <<
        I18n.t(
          "messages.elements.shared.supplier_details",
          :supplier => options[:supplier],
          :supplier_contact_details => options[:supplier_contact_details]
        ) << " " << options[:amount] << " for their " <<
        I18n.t(
          "messages.elements.shared.order_details_for_seller",
          :supplier_order_number => options[:supplier_order_number],
          :seller_order_number => options[:seller_order_number],
          :product_code => options[:product_code],
          :quantity => options[:quantity]
        ) << ". Their order is marked as " <<
        I18n.t(
          "activerecord.attribute_values.order.status.#{options[:processed]}"
        ) << ". Reply with " <<
        I18n.t(
          "messages.commands.templates.pay4order",
          :seller_order_number => options[:seller_order_number],
          :supplier_order_number => options[:supplier_order_number]
        ) << " " <<
        I18n.t(
          "messages.commands.elements.confirm"
        ) << " to confirm payment."
        I18n.t("messages.base", :name => options[:seller], :body => message)
      },
      :payment_invalid => lambda {|key, options|
        message = "a payment was about to be sent on ur behalf to " <<
        I18n.t(
          "messages.elements.shared.supplier_details",
          :supplier => options[:supplier],
          :supplier_contact_details => options[:supplier_contact_details]
        ) << " for their " <<
        I18n.t(
          "messages.elements.shared.order_details_for_seller",
          :supplier_order_number => options[:supplier_order_number],
          :seller_order_number => options[:seller_order_number],
          :product_code => options[:product_code],
          :quantity => options[:quantity]
        ) << ". Their order is marked as " <<
        I18n.t(
          "activerecord.attribute_values.order.status.#{options[:processed]}"
        ) << ". We couldn't send the payment because the #{options[:errors]}"
        I18n.t("messages.base", :name => options[:seller], :body => message)
      },
      :payment_application_invalid => lambda { |key, options|
        message = "a payment for #{options[:amount]} was about to be sent to " <<
        I18n.t(
          "messages.elements.shared.supplier_details",
          :supplier => options[:supplier],
          :supplier_contact_details => options[:supplier_contact_details]
        ) << " for their order(##{options[:supplier_order_number]}). We couldn't transfer the funds because "
        if options[:status]
          message << "your payment system is " <<
          I18n.t(
            "activerecord.attribute_values.payment_application.status.#{options[:status]}"
          ) << ". Log in to ur account to reactivate it"
        else
          message << "u haven't set up your payment system yet"
        end
        message << ". U can check ur payment details anytime by texting " <<
        I18n.t(
          "messages.commands.templates.paymentdetails",
          :supplier_order_number => options[:supplier_order_number]
        )
        I18n.t("messages.base", :name => options[:seller], :body => message)
      },
      :payment_request_notification => lambda { |key, options|
        message = "ur payment of #{options[:amount]} to " <<
        I18n.t(
          "messages.elements.shared.supplier_details",
          :supplier => options[:supplier],
          :supplier_contact_details => options[:supplier_contact_details]
        ) << " for their " <<
        I18n.t(
          "messages.elements.shared.order_details_for_seller",
          :supplier_order_number => options[:supplier_order_number],
          :seller_order_number => options[:seller_order_number],
          :product_code => options[:product_code],
          :quantity => options[:quantity]
        )
        if options[:error]
          message << " failed because #{options[:error]}"
        else
          message << " succeeded. We notified #{options[:supplier]} for you."
        end
        I18n.t("messages.base", :name => options[:seller], :body => message)
      },
      :products_not_found_notification => lambda { |key, options|
        options[:number_of_items] = options[:number_of_items].to_i
        options[:number_of_missing_products] = options[:number_of_missing_products].to_i
        message = "there is a new order (##{options[:seller_order_number]}) for "
        if options[:number_of_items] == 1
          message << "an item"
        else
          message << "#{options[:number_of_items].to_s} items"
        end
        message << " that you are selling however "

        if options[:number_of_missing_products] > 1
          if options[:number_of_missing_products] == options[:number_of_items]
            message << "none of the item numbers are"
          else
            message << "{options[:number_of_missing_products]} of the item numbers are not yet"
          end
        else
          message << "the item number is not yet"
        end

        message << " registered with us."

        message << " Log in to your account to register the item number"
        message << "s" if options[:number_of_missing_products] > 1
        message << " and resend the order."

#        message << "Since you have "

#        if options[:default_supplier]
#          message << "already nominated "
#          if options[:default_supplier_name]
#            message << "#{options[:default_supplier_name]} (#{options[:default_supplier_mobile_number]}) as the "
#          else
#            message << "yourself as the "
#          end
#        else
#          message << "not yet nominated a "
#        end

#        message << "default supplier you can elect to send the order "
#        message << "either to them or to " if options[:default_supplier_name]
#        message << "yourself. From then on all new orders for the item number"
#        message << "s" if options[:number_of_missing_products] > 1
#        message << " in question will be automatically sent to "
#        message << "either #{options[:default_supplier_name]} or to " if options[:default_supplier_name]
#        message << "you."
#        message << " To send the order to "
#        if options[:default_supplier_name]
#          message << options[:default_supplier_name]
#        else
#          message << "yourself"
#        end
#        message << " text: " <<
#        I18n.t(
#          "messages.commands.templates.sendorder",
#          :seller_order_number => options[:seller_order_number],
#          :supplier_name => options[:default_supplier_name]
#        )
#        if options[:default_supplier_name]
#          message << ". To send the order to yourself simply text: " <<
#          I18n.t(
#            "messages.commands.templates.sendorder",
#            :seller_order_number => options[:seller_order_number]
#          )
#        end
#        message << ". For more details about the missing product"
#        message << "s" if options[:number_of_missing_products] > 1
#        message << " text: " <<
#        I18n.t(
#          "messages.commands.templates.missingproducts",
#          :seller_order_number => options[:seller_order_number]
#        )
#        message << "."
        I18n.t("messages.base", :name => options[:seller], :body => message)
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
          :'abstract_process_order_conversation/supplier_order_message' => {
            :attributes => {
              :order => {
                :blank => "can't be found"
              }
            }
          },
          :'rejectorder_conversation/message' => {
            :attributes => {
              :confirmation => {
                :invalid => "must be CONFIRM! if you really want to reject the order"
              }
            }
          },
          :'pay4order_conversation/message' => {
            :blank => "can't be found",
            :attributes => {
              :confirmation => {
                :invalid => "must be CONFIRM! to confirm payment"
              }
            }
          },
          :'abstract_authenticated_conversation/message' => {
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
    },
    :activerecord => {
      :attributes => {
        :payment => {
          :cents => "amount",
          :supplier_order => "order"
        }
      },
      :attribute_values => {
        :order => {
          :status => {
            :accepted => "accepted",
            :rejected => "rejected",
            :completed => "completed",
            :unconfirmed => "unconfirmed"
          }
        },
        :payment_application => {
          :status => {
            :active => "active",
            :inactive => "inactive",
            :unconfirmed => "unconfirmed"
          }
        }
      },
      :errors => {
        :models => {
          :payment => {
            :attributes => {
              :cents => {
                :greater_than => "must be greater than %{count} (check that u have set a supplier price for this product)"
              },
              :supplier_order_id => {
                :taken => lambda {|key, options|
                  "already has a payment (text (" <<
                  I18n.t(
                    "messages.commands.templates.paymentdetails",
                    :supplier_order_number => options[:value]
                  ) << ") to check its status)"
                }
              }
            }
          },
          :payment_agreement => {
            :attributes => {
              :supplier => {
                :is_the_seller => "cannot be the seller"
              },
              :product => {
                :supplied_by_seller => "is also supplied by the seller",
                :is_not_nil         => "should be cleared"
              }
            }
          },
          :payment_request => {
            :attributes => {
              :notification => {
                :payee_not_found => "u restricted ur payees and %{supplier} isn't on the list. Add %{supplier} to ur payee list at %{application_uri} or clear the list to pay all ur suppliers",
                :payee_maximum_amount_exceeded => "the maximum amount for %{supplier} was exceeded. Increase the amount at %{application_uri}",
                :payee_currency_invalid => "%{supplier} is not allowed to be paid in %{currency}. Change this at %{application_uri}"
              }
            }
          }
        }
      }
    }
  }
}

