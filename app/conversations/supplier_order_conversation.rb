class SupplierOrderConversation < IncomingTextMessageConversation

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

    validate :tracking_number_format

    def initialize(supplier_order, tracking_number_format, params)
      @tracking_number_format = tracking_number_format
      unless params[0].nil? || (params.count == 1 && params[0].to_i == supplier_order.id)
        @tracking_number = (params[0].to_i == supplier_order.id) ?
          params[1..-1] : params[0..-1]
        @tracking_number = @tracking_number.join(" ")
      end
    end

    private
      def tracking_number_format
        errors.add(:tracking_number, :invalid) unless tracking_number.nil? ||
          tracking_number =~ Regexp.new(@tracking_number_format, true)
      end
  end

  def accept
    if supplier_order = find_supplier_order(:unconfirmed, :accept)
      unless user == supplier_order.seller_order.seller
        if supplier_order.unconfirmed?
          message = AcceptSupplierOrderMessage.new(supplier_order, params)
          if message.valid?
            say successfully("accepted", supplier_order)
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
        else
          say already_processed(supplier_order)
        end
      end
    end
  end
  alias_method :a, :accept

  def complete
    if supplier_order = find_supplier_order(:incomplete, :complete)
      if supplier_order.incomplete?
        seller = supplier_order.seller_order.seller
        if user == seller || supplier_order.accepted?
          product = supplier_order.product
          tracking_number_format = seller.tracking_number_formats.find_for(
            :product => product,
            :supplier => user
          ).first
          if tracking_number_format && tracking_number_format.required?
            message = CompleteSupplierOrderMessage.new(
              supplier_order,
              tracking_number_format.format,
              params
            )
            if message.valid?
              supplier_order.tracking_number = message.tracking_number
              if supplier_order.save
                will_complete = true
              else
                say I18n.t(
                  "notifications.messages.built_in.this_tracking_number_was_already_used_by_you",
                  :supplier_name => user.name
                )
              end
            else
              say I18n.t(
                "notifications.messages.built_in.the_tracking_number_is_missing_or_invalid",
                :supplier_name => user.name,
                :errors => message.errors.full_messages.to_sentence.downcase,
                :topic => self.topic,
                :action => self.action,
                :supplier_order_number => supplier_order.id.to_s
              )
            end
          else
            will_complete = true
          end
          if will_complete
            say successfully("completed", supplier_order)
            supplier_order.complete
          end
        else
          say I18n.t(
            "notifications.messages.built_in.you_must_accept_the_supplier_order_first",
            :supplier_name => user.name,
            :topic => self.topic,
            :supplier_order_number => supplier_order.id.to_s,
            :quantity => supplier_order.quantity.to_s
          )
        end
      else
        say already_processed(supplier_order)
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

  def require_user?
    true
  end

  def require_verified_mobile_number?
    true
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

    def find_supplier_order(status, human_action)
      supplier_orders = find_supplier_orders(status)
      if supplier_orders.empty?
        say I18n.t(
          "notifications.messages.built_in.you_do_not_have_any_supplier_orders",
          :supplier_name => user.name,
          :status => status,
          :human_action => human_action.to_s
        )
      elsif supplier_orders.count > 1
        say I18n.t(
          "notifications.messages.built_in.be_specific_about_the_supplier_order_number",
          :supplier_name => user.name,
          :topic => self.topic,
          :action => self.action,
          :human_action => human_action.to_s
        )
      else
        supplier_order = supplier_orders.first
      end
      supplier_order
    end

    def already_processed(supplier_order)
      I18n.t(
        "notifications.messages.built_in.supplier_order_was_already_processed",
        :supplier_name => user.name,
        :status => supplier_order.status
      )
    end

    def successfully(processed, supplier_order)
       I18n.t(
          "notifications.messages.built_in.you_successfully_processed_the_supplier_order",
          :supplier_name => user.name,
          :processed => processed,
          :supplier_order_number => supplier_order.id.to_s
        )
    end
end

