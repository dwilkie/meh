class OrderConversation < IncomingTextMessageConversation
  private
    class CompleteOrderMessage
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
end

