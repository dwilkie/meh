class LineItemConversation < IncomingTextMessageConversation
  def process
    if action != "confirm" && action != "c" && message_words.first == topic
      self.params.insert(0, action)
      self.action = nil
      # list the items
    else
      confirm
    end
  end

  private

    class ConfirmLineItemMessage
      include ActiveModel::Validations
      extend ActiveModel::Translation

      attr_reader :quantity, :product_verification_code, :line_item_id

      validates :quantity,
                :presence => true

      validates :product_verification_code,
                :presence => true,
                :if => :product_verification_code_required?

      validate :line_item_id_exists,
               :quantity_is_correct,
               :product_verification_code_is_correct

      def initialize(line_item, params, filtered = nil)
        @line_item = line_item
        @params = params
        @filtered = filtered
        @line_item_id = params[0]
        if line_item_explicit?
          @quantity = params[1]
          @product_verification_code = params[2]
        else
          @quantity = params[0]
          @product_verification_code = params[1]
        end
      end

      def implicit_line_item_id_text
        " for #{self.class.human_attribute_name(:line_item_id)} #{@line_item.id}" if errors[:line_item_id].empty?
      end

      def retry_suggestion(topic, action)
        sanitized_action = " #{action}" if action
        suggestion = "#{sanitized_action} #{topic} "
        line_item_id_suggestion = line_item_id_correct? ?
          "#{line_item_id} " :
          "<#{self.class.human_attribute_name(:line_item_id)}> " if
          line_item_explicit?
        suggestion << line_item_id_suggestion if line_item_id_suggestion
        suggestion << "<#{self.class.human_attribute_name(:quantity)}>"
        suggestion << " <#{self.class.human_attribute_name(:product_verification_code)}>" if product_verification_code_required?
        suggestion
      end

      private
        def line_item_id_exists
          errors.add(
            :line_item_id,
            :does_not_exist
          ) if line_item_id_does_not_exist?
        end

        def quantity_is_correct
          errors.add(
            :quantity,
            :incorrect
          ) unless quantity.nil? ||
            quantity_correct? ||
            line_item_id_does_not_exist?
        end

        def product_verification_code_is_correct
          errors.add(
            :product_verification_code,
            :incorrect
            ) unless product_verification_code.nil? ||
              !product_verification_code_required? ||
              line_item_id_does_not_exist? ||
              product_verification_code.downcase ==
                @line_item.product.verification_code.downcase
        end

        def product_verification_code_required?
          @line_item.product.verification_code
        end

        def line_item_id_correct?
          line_item_id.to_i == @line_item.id
        end

        def quantity_correct?(value = nil)
          qty = value ? value.to_i : quantity.to_i
          qty == @line_item.quantity
        end

        def line_item_id_does_not_exist?
          !line_item_id_correct? && (
            @params.length > 2 || (
              !product_verification_code_required? &&
              !@params[1].nil?
            )
          )
        end

        def line_item_explicit?
          line_item_id_does_not_exist? ||
          (line_item_id_correct? && !line_item_implicit?)
        end

        def line_item_implicit?
          line_item_id_correct? && !@filtered && ((
            @params[1].nil? &&
            !product_verification_code_required?
          ) ||
          (
            @params[2].nil? &&
            product_verification_code_required?
          ))
        end
    end

    def confirm
      line_item, filtered = find_line_item
      if line_item
        seller = line_item.supplier_order.seller_order.seller
        self.payer = seller
        unless user == seller
          message = ConfirmLineItemMessage.new(line_item, params, filtered)
          message.valid? ? line_item.confirm! : say(invalid_confirmation(message))
        end
      end
    end

    def find_line_items
      unconfirmed_line_items = user.line_items.unconfirmed
      line_items = unconfirmed_line_items.where(
        :id => sanitize_id(params[0])
      )
      if line_items.empty?
        return unconfirmed_line_items, nil
      else
        return line_items, unconfirmed_line_items.length > 1
      end
    end

    def find_line_item
      line_items, filtered = find_line_items
      if line_items.empty?
        say no_line_items_to_confirm
      elsif line_items.count > 1
        say be_specific_about_the_line_item
      else
        line_item = line_items.first
      end
      return line_item, filtered
    end

    def invalid_confirmation(message)
      I18n.t(
      "notifications.messages.built_in.you_supplied_incorrect_values_while_trying_to_confirm_the_line_item",
        :supplier_name => user.name,
        :errors => message.errors.full_messages.to_sentence,
        :implicit_line_item_id => message.implicit_line_item_id_text,
        :retry_suggestion => message.retry_suggestion(topic, action)
      )
    end

    def no_line_items_to_confirm
      I18n.t(
        "notifications.messages.built_in.you_have_no_line_items_to_confirm",
        :supplier_name => user.name
      )
    end

    def be_specific_about_the_line_item
      sanitized_params = params.join(" ")
      sanitized_params = " #{sanitized_params}" unless sanitized_params.blank?
      I18n.t(
        "notifications.messages.built_in.be_specific_about_the_line_item_number",
        :supplier_name => user.name,
        :topic => topic,
        :action => action,
        :params => sanitized_params
      )
    end
end

