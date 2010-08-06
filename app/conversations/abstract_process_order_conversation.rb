class AbstractProcessOrderConversation < Conversation
  class Message < AbstractAuthenticatedConversation::Message
    attr_reader  :order, :command

    validates :order,
              :presence => true

    def initialize(raw_message, supplier)
      message_contents = super
      @command = message_contents[0]
      order_number = message_contents[2].try(:gsub, /\D/, "").try(:to_i)
      @order = supplier.supplier_orders.find_by_id(order_number)
      message_contents
    end
  end

  protected

    def cannot_process(order)
      I18n.t(
        "messages.cannot_process_order",
        :supplier => user.name,
        :status => order.status
      )
    end

    def successfully(processed, order)
      I18n.t(
        "messages.successfully_processed_order",
        :supplier => user.name,
        :processed => processed,
        :order_number => order.id.to_s
      )
    end

    def invalid(message, processed)
      I18n.t(
        "messages.process_order_invalid_message",
        :user => user.name,
        :errors => message.errors.full_messages.to_sentence,
        :raw_message => message.raw_message,
        :command => message.command,
        :processed => processed
      )
    end

    def unauthorized
      I18n.t(
        "messages.unauthorized",
        :name => user.name
      )
    end
end

