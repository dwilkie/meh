class Pay4orderConversation < AbstractProcessOrderConversation
  
  class Message
    include ActiveModel::Validations

    attr_reader :customer_order,
                :supplier_order,
                :raw_message,
                :command,
                :confirmation

    validates :confirmation,
              :format => /^confirm\!$/i,
              :allow_nil => true

    validates :customer_order,
              :presence => true
              
    validates :supplier_order,
              :presence => true,
              :if => Proc.new { |message|
                message.customer_order
              }

    def initialize(raw_message, seller)
      @raw_message = raw_message
      message_contents = raw_message.split(" ")
      @command = message_contents[0]
      customer_order_number = message_contents[1].try(:to_i)
      supplier_order_number = message_contents[2].try(:to_i)
      @customer_order = seller.customer_orders.find_by_id(customer_order_number)
      @supplier_order = @customer_order.supplier_orders.find_by_id(supplier_order_number) if @customer_order
      @confirmation = message_contents[3]
    end
    
    def confirmed?
      !confirmation.nil?
    end
  end

  def move_along!(message)
    if user.is?(:seller)
      message = Message.new(message, user)
      if message.valid?
        supplier_order = message.supplier_order
        payment = user.outgoing_payments.build(
          :supplier_order => supplier_order,
          :supplier => supplier_order.supplier,
          :amount => supplier_order.supplier_total
        )
        finish
        if payment.valid?
          if message.confirmed?
            payment.save!
            payment.pay
          else
            ConfirmPaymentNotificationConversation.create!(
              :with => user,
              :topic => "confirm_payment_notification"
            ).move_along!(payment)
          end
        else
          PaymentInvalidNotificationConversation.create!(
            :with => seller,
            :topic => "payment_invalid_notification"
          ).move_along!(payment)
        end
      else
        say invalid(message, processed)
      end
    else
      say unauthorized
    end
  end
end
