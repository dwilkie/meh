class AbstractConfirmOrderConversation < AbstractConversation
  class AbstractMessage
    include ActiveModel::Validations

    attr_reader   :order_number, :order, :raw_message

    validates :order,
              :presence => true

    def initialize(raw_message, supplier)
      @raw_message = raw_message
      message_contents = raw_message.split(" ")
      @order_number = message_contents[1].try(:to_i)
      @order = supplier.supplier_orders.find_by_id(@order_number)
      message_contents
    end
  end
    
  def move_along!(message, options)
    if user.is?(:supplier)
      if message.valid?
        say(already_confirmed(message.order)) if message.order.confirmed?
      else
        say invalid_message(message, options[:invalid_message_i18n_key])
      end
    else
      say unauthorized(options[:confirm_order_action])
    end
  end
    private
      def invalid_message(message, invalid_message_i18n_key)
        I18n.t(
          invalid_message_i18n_key,
          :errors => message.errors.full_messages.to_sentence,
          :raw_message => message.raw_message
        )
      end
      
      def unauthorized(confirm_order_action)
        I18n.t(
          "messages.unauthorized",
          :action => confirm_order_action
        )
      end
      
      def already_confirmed(order)
        confirmation = order.status
        confirmation = "confirmed" unless
          confirmation == "accepted" || confirmation == "rejected"
        I18n.t(
          "messages.order_already_confirmed",
          :confirmation => confirmation
        )
      end
end
