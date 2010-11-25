class LineItemConversation < IncomingTextMessageConversation

  def process
    self.params.insert(0, action) if
      action != "confirm" && action != "c" && message_words.first == topic
    confirm
  end

  def require_verified_mobile_number?
    true
  end

  private

    class ConfirmLineItemMessage
      include ActiveModel::Validations

      attr_reader :quantity, :product_verification_code

      validates :quantity, :product_verification_code,
                :presence => true

      validate :quantity_is_correct, :product_verification_code_is_correct

      def initialize(line_item, params)
        @line_item = line_item
        unless params.count == 1 && params[0].to_i == line_item.id
          if params.count > 2
            @quantity = params[1]
            @product_verification_code = params[2]
          else # 0 or 2
            @quantity = params[0] if params[0]
            @product_verification_code = params[1]
          end
        end
      end

      private
        def quantity_is_correct
          errors.add(
            :quantity,
            :incorrect
          ) unless quantity.nil? || quantity.to_i == @line_item.quantity
        end

        def product_verification_code_is_correct
          errors.add(
            :product_verification_code,
            :incorrect
            ) unless product_verification_code.nil? ||
              product_verification_code.downcase ==
                @line_item.product.verification_code.downcase
        end
    end

    def confirm
      if line_item = find_line_item
        self.payer = line_item.supplier_order.seller_order.seller
        unless user == payer
          message = ConfirmLineItemMessage.new(line_item, params)
          if message.valid?
            line_item.confirm!
          else
            say I18n.t(
            "notifications.messages.built_in.you_supplied_incorrect_values_while_trying_to_confirm_the_line_item",
              :supplier_name => user.name,
              :errors => message.errors.full_messages.to_sentence,
              :topic => self.topic,
              :action => self.action,
              :line_item_number => line_item.id.to_s,
              :quantity => line_item.quantity.to_s
            )
          end
        end
      end
    end

    def sanitize_id(value = nil)
      sanitized_id = value.try(:gsub, /\D/, "").try(:to_i)
      sanitized_id = nil if sanitized_id == 0
      sanitized_id
    end

    def find_line_items
      unconfirmed_line_items = user.line_items.unconfirmed
      line_items = unconfirmed_line_items.where(
        :id => sanitize_id(params[0]
      )
      line_items.empty? ? unconfirmed_line_items : line_items
    end

    def find_line_item
      line_items = find_line_items
      if line_items.empty?
        say I18n.t(
          "notifications.messages.built_in.you_have_no_unconfirmed_line_items",
          :supplier_name => user.name,
        )
      elsif line_items.count > 1
        say I18n.t(
          "notifications.messages.built_in.be_specific_about_the_line_item_number",
          :supplier_name => user.name,
          :topic => topic,
          :action => action,
          :params => params.join(" ")
        )
      else
        line_item = line_items.first
      end
      line_item
    end

    def say(message)
      self.payer = user.sellers.first if payer.nil? && user.sellers.count == 1
      super(message)
    end
end

