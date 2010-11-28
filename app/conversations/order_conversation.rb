class OrderConversation < IncomingTextMessageConversation

  def require_verified_mobile_number?
    true
  end

  def process
    if action != "complete" && action != "c" && message_words.first == topic
      self.params.insert(0, action)
      self.action = nil
      # list the orders
    else
      complete
    end
  end

  private
    class CompleteOrderMessage
      include ActiveModel::Validations
      extend ActiveModel::Translation

      attr_reader :tracking_number, :order_id

      validates :tracking_number,
                :presence => true,
                :if => Proc.new {
                  @tracking_number_format &&
                  @tracking_number_format.required?
                }

      validate :order_id_exists,
               :tracking_number_format_valid

      def initialize(order, tracking_number_format, params)
        @order = order
        @tracking_number_format = tracking_number_format
        @params = params
        @order_id = params[0]
        unless params[0].nil? || (params.count == 1 && order_id_correct?)
          tracking_number = order_explicit? ? params[1..-1] : params[0..-1]
          @tracking_number = tracking_number.join(" ")
        end
      end

      def retry_suggestion(topic, action)
        suggestion = "#{action} #{topic} "
        order_id_suggestion = order_id_correct? ?
          "#{order_id} " :
          "<#{self.class.human_attribute_name(:order_id)}> " if
          order_explicit?
        suggestion << order_id_suggestion if order_id_suggestion
        suggestion << "<#{self.class.human_attribute_name(:tracking_number)}>"
        suggestion
      end

      private
        def order_id_exists
          errors.add(
            :order_id,
            :does_not_exist
          ) if order_id_does_not_exist?
        end

        def tracking_number_format_valid
          errors.add(
            :tracking_number,
            :invalid
          ) unless tracking_number.nil? ||
            order_id_does_not_exist? ||
            @tracking_number_format.nil? ||
            !@tracking_number_format.required? ||
            tracking_number =~ Regexp.new(
              @tracking_number_format.format, true
            )
        end

        def order_id_correct?
          @order_id.to_i == @order.id
        end

        def order_id_does_not_exist?
          order_explicit? && !order_id_correct?
        end

        def order_explicit?
          order_id_correct? ||
          (@order_id =~ /^\d+$/ && @params.count > 1) || (
            @order_id &&
            @tracking_number_format &&
            !@tracking_number_format.required?
          ) || (
            @order_id &&
            @tracking_number_format.nil?
          )
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
        say no_orders_to_complete
      elsif supplier_orders.count > 1
        say be_specific_about_the_order
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
          tracking_number_format = seller.tracking_number_formats.find_for(
            :supplier => user
          ).first
          message = CompleteOrderMessage.new(
            supplier_order,
            tracking_number_format,
            params
          )
          if message.valid?
            supplier_order.tracking_number = message.tracking_number
            supplier_order.valid? ?
            supplier_order.complete! :
            say(tracking_number_already_used(supplier_order))
          else
            say invalid_tracking_number(message)
          end
        else
          say you_must_confirm_the_line_items_for(supplier_order)
        end
      end
    end

    def tracking_number_already_used(supplier_order)
      I18n.t(
        "notifications.messages.built_in.this_tracking_number_was_already_used_by_you",
        :supplier_name => user.name,
        :errors => supplier_order.errors.full_messages.to_sentence
      )
    end

    def no_orders_to_complete
      I18n.t(
        "notifications.messages.built_in.you_have_no_orders_to_complete",
        :supplier_name => user.name
      )
    end

    def you_must_confirm_the_line_items_for(supplier_order)
      I18n.t(
        "notifications.messages.built_in.you_must_confirm_the_line_items_first",
        :supplier_name => user.name,
        :line_item_numbers => supplier_order.line_item_numbers
      )
    end

    def be_specific_about_the_order
      sanitized_params = params.join(" ")
      sanitized_params = " #{sanitized_params}" unless sanitized_params.blank?
      I18n.t(
        "notifications.messages.built_in.be_specific_about_the_order_number",
        :supplier_name => user.name,
        :topic => topic,
        :action => action,
        :params => sanitized_params
      )
    end

    def invalid_tracking_number(message)
      I18n.t(
        "notifications.messages.built_in.the_tracking_number_is_missing_or_invalid",
        :supplier_name => user.name,
        :errors => message.errors.full_messages.to_sentence,
        :retry_suggestion => message.retry_suggestion(topic, action)
      )
    end

end

