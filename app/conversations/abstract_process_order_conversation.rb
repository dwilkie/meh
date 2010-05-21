class AbstractProcessOrderConversation < AbstractConversation
  class OrderMessage
    include ActiveModel::Validations

    attr_reader   :order_number, :order, :raw_message, :command

    validates :order,
              :presence => true

    def initialize(raw_message, supplier)
      @raw_message = raw_message
      message_contents = raw_message.split(" ")
      @command = message_contents[0]
      @order_number = message_contents[1].try(:to_i)
      @order = supplier.supplier_orders.find_by_id(@order_number)
      message_contents
    end
  end
    
  def move_along!(message)
    say unauthorized(message.command) unless user.is?(:supplier)
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
        :order_number => order.id
      )
    end
    
    def invalid(message, processed)
      I18n.t(
        "messages.process_order_invalid_message",
        :supplier => user.name,
        :errors => message.errors.full_messages.to_sentence,
        :raw_message => message.raw_message,
        :command => message.command,
        :processed => processed
      )
    end

  private
  
    def unauthorized(command)
      I18n.t(
        "messages.unauthorized",
        :name => user.name,
        :command => command
      )
    end
end