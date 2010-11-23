class LineItemConversation < IncomingTextMessageConversation

  def process
    if action == "accept" || action == "a"
      accept
    elsif action == "complete" || action == "c"
      complete
    else
      invalid_action
    end
  end

  def require_verified_mobile_number?
    true
  end

  private

    class AcceptLineItemMessage
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

    class CompleteLineItemMessage
      include ActiveModel::Validations

      attr_reader :tracking_number

      validates :tracking_number,
                :presence => true

      validate :tracking_number_format

      def initialize(line_item, tracking_number_format, params)
        @tracking_number_format = tracking_number_format
        unless params[0].nil? || (params.count == 1 && params[0].to_i == line_item.id)
          @tracking_number = (params[0].to_i == line_item.id) ?
            params[1..-1] : params[0..-1]
          @tracking_number = @tracking_number.join(" ")
        end
      end

      private
        def tracking_number_format
          errors.add(
            :tracking_number,
            :invalid
          ) unless tracking_number.nil? ||
            tracking_number =~ Regexp.new(@tracking_number_format, true)
        end
    end

    def accept
      if line_item = find_line_item(:unconfirmed, :accept)
        self.payer = line_item.seller_order.seller
        unless user == payer
          if line_item.unconfirmed?
            message = AcceptLineItemMessage.new(line_item, params)
            if message.valid?
              say successfully("accepted", line_item)
              line_item.accept!
            else
              say I18n.t(
              "notifications.messages.built_in.you_supplied_incorrect_values_while_trying_to_accept_the_line_item",
                :supplier_name => user.name,
                :errors => message.errors.full_messages.to_sentence,
                :topic => self.topic,
                :action => self.action,
                :line_item_number => line_item.id.to_s,
                :quantity => line_item.quantity.to_s
              )
            end
          else
            say already_processed(line_item)
          end
        end
      end
    end

    def complete
      if line_item = find_line_item(:incomplete, :complete)
        self.payer = line_item.seller_order.seller
        if line_item.incomplete?
          if user == payer || line_item.accepted?
            product = line_item.product
            tracking_number_format = payer.tracking_number_formats.find_for(
              :product => product,
              :supplier => user
            ).first
            if tracking_number_format && tracking_number_format.required?
              message = CompleteLineItemMessage.new(
                line_item,
                tracking_number_format.format,
                params
              )
              if message.valid?
                line_item.tracking_number = message.tracking_number
                if line_item.save
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
                  :errors => message.errors.full_messages.to_sentence,
                  :topic => self.topic,
                  :action => self.action,
                  :line_item_number => line_item.id.to_s
                )
              end
            else
              will_complete = true
            end
            if will_complete
              say successfully("completed", line_item)
              line_item.complete!
            end
          else
            say I18n.t(
              "notifications.messages.built_in.you_must_accept_the_line_item_first",
              :supplier_name => user.name,
              :topic => self.topic,
              :line_item_number => line_item.id.to_s,
              :quantity => line_item.quantity.to_s
            )
          end
        else
          say already_processed(line_item)
        end
      end
    end

    def invalid_action
      action ?
        say(
          I18n.t(
            "notifications.messages.built_in.invalid_action_for_line_item",
            :topic => topic,
            :action => action
          )
        ) :
        say(
           I18n.t(
            "notifications.messages.built_in.no_action_for_line_item",
            :topic => topic
          )
        )
    end

    def sanitize_id(value = nil)
      sanitized_id = value.try(:gsub, /\D/, "").try(:to_i)
      sanitized_id = nil if sanitized_id == 0
      sanitized_id
    end

    def find_line_items(status)
      status = status.to_s
      line_item = user.line_items.find_by_id(
        sanitize_id(params[0])
      )
      line_item ? [line_item] : user.line_items.send(status).all
    end

    def find_line_item(status, human_action)
      line_items = find_line_items(status)
      if line_items.empty?
        say I18n.t(
          "notifications.messages.built_in.you_do_not_have_any_line_items",
          :supplier_name => user.name,
          :status => status,
          :human_action => human_action.to_s
        )
      elsif line_items.count > 1
        say I18n.t(
          "notifications.messages.built_in.be_specific_about_the_line_item_number",
          :supplier_name => user.name,
          :topic => self.topic,
          :action => self.action,
          :human_action => human_action.to_s
        )
      else
        line_item = line_items.first
      end
      line_item
    end

    def already_processed(line_item)
      I18n.t(
        "notifications.messages.built_in.line_item_was_already_processed",
        :supplier_name => user.name,
        :status => line_item.status
      )
    end

    def successfully(processed, line_item)
       I18n.t(
          "notifications.messages.built_in.you_successfully_processed_the_line_item",
          :supplier_name => user.name,
          :processed => processed,
          :line_item_number => line_item.id.to_s
        )
    end

    def say(message)
      self.payer = user.sellers.first if payer.nil? && user.sellers.count == 1
      super(message)
    end
end

