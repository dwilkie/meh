class Pay4orderConversation < Conversation
  
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
        if payment.valid?
          if message.confirmed?
            payment.save!
            payment_application = user.payment_application
            if payment_application && payment_application.active?
              payment.build_payment_request(
                :application_uri => payment_application.uri
              ).save!
            else
              notify_problem_with(payment_application, payment)
            end
          else
            notify_confirm(payment)
          end
        else
          notify_invalid(payment)
        end
      else
        say invalid(message)
      end
    else
      say unauthorized
    end
  end
  
  private

    def notify_invalid(payment)
      PaymentNotification.new(:with => user).invalid(payment)
    end
    
    def notify_confirm(payment)
      PaymentNotification.new(:with => user).confirm(payment)
    end
    
    def notify_problem_with(payment_application, payment)
      PaymentApplicationNotification.new(
        :with => user
      ).invalid(payment_application, payment)
    end

    def invalid(message)
      I18n.t(
        "messages.pay4order_invalid_message",
        :user => user.name,
        :errors => message.errors.full_messages.to_sentence,
        :raw_message => message.raw_message,
        :command => message.command
      )
    end
    
    def unauthorized
      I18n.t(
        "messages.unauthorized",
        :name => user.name
      )
    end
end
