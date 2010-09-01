class SupplierOrderConversation < AbstractAuthenticatedConversation

  class AcceptSupplierOrderMessage
    include ActiveModel::Validations

    attr_reader :quantity, :product_verification_code

    validates :quantity, :product_verification_code,
              :presence => true

    validate :quantity_is_correct, :product_verification_code_is_correct

    def initialize(supplier_order, params)
      @supplier_order = supplier_order
      unless params.count == 1 && params[0].to_i == supplier_order.id
        if params.count > 2
          @quantity = params[1].to_i
          @product_verification_code = params[2]
        else # 0 or 2
          @quantity = params[0].to_i if params[0]
          @product_verification_code = params[1]
        end
      end
    end

    private
      def quantity_is_correct
        errors.add(
          :quantity,
          :incorrect
        ) unless quantity.nil? || quantity == @supplier_order.quantity
      end

      def product_verification_code_is_correct
        errors.add(
          :product_verification_code,
          :incorrect
          ) unless product_verification_code.nil? ||
            product_verification_code.downcase ==
              @supplier_order.product.verification_code.downcase
      end
  end

  class CompleteSupplierOrderMessage
    include ActiveModel::Validations

    attr_reader :tracking_number

    validates :tracking_number,
              :presence => true

    def validate
      if tracking_number
        errors.add(:tracking_number, :format) unless
          tracking_number =~ Regexp.new(@tracking_number_format)
      end
    end

    def initialize(tracking_number_format)
      @tracking_number_format = tracking_number_format
      @tracking_number = params[1]
    end
  end

  def accept
    supplier_orders = find_supplier_orders(:unconfirmed)
    if supplier_orders.empty?
      say I18n.t(
        "notifications.messages.built_in.you_do_not_have_any_supplier_orders",
        :supplier_name => user.name,
        :status => "unconfirmed",
        :human_action => "accept"
      )
    elsif supplier_orders.count > 1
      say I18n.t(
        "notifications.messages.built_in.be_specific_about_the_supplier_order_number",
        :supplier_name => user.name,
        :topic => self.topic,
        :action => self.action,
        :human_action => "accept"
      )
    else
      supplier_order = supplier_orders.first
      if supplier_order.unconfirmed?
        if user == supplier_order.seller_order.seller
          supplier_order.accept
        else
          message = AcceptSupplierOrderMessage.new(supplier_order, params)
          if message.valid?
            say I18n.t(
              "notifications.messages.built_in.you_successfully_processed_the_supplier_order",
              :supplier_name => user.name,
              :processed => "accepted",
              :supplier_order_number => supplier_order.id.to_s
            )
            supplier_order.accept
          else
            say I18n.t(
            "notifications.messages.built_in.you_supplied_incorrect_values_while_trying_to_accept_the_supplier_order",
              :supplier_name => user.name,
              :errors => message.errors.full_messages.to_sentence.downcase,
              :topic => self.topic,
              :action => self.action,
              :supplier_order_number => supplier_order.id.to_s,
              :quantity => supplier_order.quantity.to_s
            )
          end
        end
      else
        say I18n.t(
          "notifications.messages.built_in.supplier_order_was_already_confirmed",
          :supplier_name => user.name,
          :status => supplier_order.status
        )
      end
    end
  end
  alias_method :a, :accept

  def complete
    supplier_order = find_supplier_order(:incomplete)
    if supplier_order
      seller = supplier_order.seller_order.seller
      product = supplier_order.product
      supplier = supplier
      tracking_number_format = seller.tracking_number_format(
        :product => product,
        :supplier => supplier
      )
      if tracking_number_format
        message = CompleteSupplierOrderMessage.new(
          tracking_number_format.format
        )
        if message.valid?
          supplier_order.complete
        else
          say I18n.t(
          "notifications.messages.",
          :name => user.name,
          :errors => errors
        )
        end
      else
        supplier_order.complete
      end
    end
  end
  alias_method :c, :complete

  def invalid_action(action = nil)
    if action
      say I18n.t(
        "notifications.messages.built_in.invalid_action_for_supplier_order",
        :topic => self.topic,
        :action => action
      )
    else
      say I18n.t(
        "notifications.messages.built_in.no_action_for_supplier_order",
        :topic => self.topic
      )
    end
  end

  private
    def sanitize_id(value = nil)
      sanitized_id = value.try(:gsub, /\D/, "").try(:to_i)
      sanitized_id = nil if sanitized_id == 0
      sanitized_id
    end

    def find_supplier_orders(status)
      status = status.to_s
      supplier_order = user.supplier_orders.find_by_id(
        sanitize_id(params[0])
      )
      supplier_order ? [supplier_order] : user.supplier_orders.send(status).all
    end
end

