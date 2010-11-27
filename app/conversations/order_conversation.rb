class OrderConversation < IncomingTextMessageConversation

  def require_verified_mobile_number?
    true
  end

  def process
    if action != "complete" && action != "c" && message_words.first == topic
      self.params.insert(0, action)
      self.action = nil
    end
    complete
  end

  private
    class CompleteOrderMessage
      include ActiveModel::Validations
      extend ActiveModel::Translation

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
          errors.add(
            :tracking_number,
            :invalid
          ) unless tracking_number.nil? ||
            tracking_number =~ Regexp.new(@tracking_number_format, true)
        end
    end

    def find_supplier_orders
      incomplete_supplier_orders = user.supplier_orders.incomplete
      supplier_orders = incomplete_supplier_orders.where(
        :seller_order_id => sanitize_id(params[0])
      )
      supplier_orders.empty? ?
      incomplete_supplier_orders :
      supplier_orders
    end

    def find_supplier_order
      supplier_orders = find_supplier_orders
      if supplier_orders.empty?
        say no_incomplete_orders
      elsif supplier_orders.count > 1
        sanitized_action = " #{action}" if action
        sanitized_params = params.join(" ")
        sanitized_params = " #{sanitized_params}" unless sanitized_params.blank?
        say I18n.t(
          "notifications.messages.built_in.be_specific_about_the_order_number",
          :supplier_name => user.name,
          :topic => topic,
          :action => sanitized_action,
          :params => sanitized_params
        )
      else
        supplier_order = supplier_orders.first
      end
      supplier_order
    end

    def complete
      if supplier_order = find_supplier_order
        seller_order = supplier_order.seller_order
        seller = seller_order.seller
        self.payer = seller
        if user == seller || supplier_order.confirmed?
          tracking_number_format = payer.tracking_number_formats.find_for(
            :supplier => user
          ).first
          if tracking_number_format && tracking_number_format.required?
            message = CompleteOrderMessage.new(
              supplier_order,
              tracking_number_format.format,
              params
            )
            if message.valid?
              supplier_order.tracking_number = message.tracking_number
              supplier_order.save ?
              will_complete = true :
              say(tracking_number_already_used)
            else
              say I18n.t(
                "notifications.messages.built_in.the_tracking_number_is_missing_or_invalid",
                :supplier_name => user.name,
                :errors => message.errors.full_messages.to_sentence,
                :topic => self.topic,
                :action => self.action,
                :order_number => supplier_order.id.to_s
              )
            end
          else
            will_complete = true
          end
          supplier_order.complete! if will_complete
        else
          say no_incomplete_orders
        end
      end
    end

    def tracking_number_already_used
      I18n.t(
        "notifications.messages.built_in.this_tracking_number_was_already_used_by_you",
        :supplier_name => user.name
      )
    end

    def no_incomplete_orders
      I18n.t(
        "notifications.messages.built_in.you_have_no_incomplete_orders",
        :supplier_name => user.name
      )
    end
end

