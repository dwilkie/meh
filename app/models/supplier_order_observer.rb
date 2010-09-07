class SupplierOrderObserver < ActiveRecord::Observer
  def after_create(supplier_order)
    notify_and_pay supplier_order, "product_order_created"
  end

  def after_update(supplier_order)
    if supplier_order.accepted? && supplier_order.accepted_at_changed? && supplier_order.accepted_at_was.nil?
      notify_and_pay supplier_order, "product_order_accepted"
    elsif supplier_order.completed? && supplier_order.completed_at_changed? && supplier_order.completed_at_was.nil?
      notify_and_pay supplier_order, "product_order_completed"
    end
  end

  private
    def notify_and_pay(supplier_order, event)
      notify supplier_order, event
      pay_for supplier_order, event
    end

    def pay_supplier_and_notify_seller(supplier_order, transition)
      product = supplier_order.product
      seller = supplier_order.seller_order.seller
      supplier = supplier_order.supplier
      if seller != supplier
        payment_agreement = find_payment_agreement(product, seller, supplier)
        if payment_agreement &&
           payment_agreement.automatic? &&
           payment_agreement.payment_trigger_on_order == transition.to


          if payment.valid?
            if payment_agreement.confirm?
              PaymentNotification.new(:with => seller).confirm(payment)
            else
              payment.save!
              payment_application = seller.payment_application
              if payment_application && payment_application.active?
                payment.build_payment_request(
                  :application_uri => payment_application.uri
                ).save!
              else
                PaymentApplicationNotification.new(
                  :with => seller
                ).invalid(payment_application, payment)
              end
            end
          else
            PaymentNotification.new(:with => seller).invalid(payment)
          end
        else
          notify_seller(order)
        end
      end
    end

    def pay_for(supplier_order, event)
      supplier = supplier_order.supplier
      seller = supplier_order.seller_order.seller
      product = supplier_order.product
      payment_agreement = supplier.payment_agreements.for_event(
        event,
        seller,
        product
      ).first
      if payment_agreement && payment_agreement.enabled?
        payment = seller.outgoing_payments.build(
          :supplier_order => supplier_order,
          :supplier => supplier,
          :amount => supplier_order.supplier_total
        )
        unless payment.save
          notification = GeneralNotification.new(:with => seller)
          supplier_mobile_number = Notification::EVENT_ATTRIBUTES[
            :supplier
          ][:supplier_mobile_number].call(:supplier => supplier)
          notification.notify(
            I18n.t(
              "messages.we_did_not_pay_your_supplier",
              :seller_name => seller.name,
              :supplier_name => supplier.name,
              :supplier_mobile_number => supplier_mobile_number,
              :supplier_order_quantity => supplier_order.quantity,
              :product_number => product.number,
              :product_name => product.name,
              :errors => payment.errors.full_messages.to_sentence
            )
          )
        end
      end
    end

    def find_payment_agreement(product, seller, supplier)
      payment_agreement = product.payment_agreement
      payment_agreement = seller.payment_agreement_with_supplier(supplier) if payment_agreement.nil?
      payment_agreement
    end

    def notify(supplier_order, event)
      product = supplier_order.product
      seller_order = supplier_order.seller_order
      seller = seller_order.seller
      supplier = supplier_order.supplier
      order_notification = seller_order.order_notification

      notifications = seller.notifications.for_event(
        event,
        :supplier => supplier,
        :product => product
      )
      notifications.each do |notification|
        with = notification.send_to(seller, supplier)
        active_mobile_number = with.active_mobile_number
        if active_mobile_number && active_mobile_number.verified?
          GeneralNotification.new(:with => with).notify(
            notification,
            :product => product,
            :supplier_order => supplier_order,
            :seller_order => seller_order,
            :seller => seller,
            :supplier => supplier,
            :order_notification => order_notification
          )
        end
      end
    end
end

