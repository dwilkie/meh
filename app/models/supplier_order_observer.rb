class SupplierOrderObserver < ActiveRecord::Observer
  def after_create(supplier_order)
    notify(supplier_order, "product_order_created")
  end

  def after_update(supplier_order)
    if supplier_order.accepted? && supplier_order.accepted_at_changed? && supplier_order.accepted_at_was.nil?
      notify(supplier_order, "product_order_accepted")
    elsif supplier_order.completed? && supplier_order.completed_at_changed? && supplier_order.completed_at_was.nil?
      notify(supplier_order, "product_order_completed")
    end
  end

  private
    def pay_supplier_and_notify_seller(supplier_order, transition)
      product = supplier_order.product
      seller = supplier_order.seller_order.seller
      supplier = supplier_order.supplier
      if seller != supplier
        payment_agreement = find_payment_agreement(product, seller, supplier)
        if payment_agreement &&
           payment_agreement.automatic? &&
           payment_agreement.payment_trigger_on_order == transition.to

          payment = seller.outgoing_payments.build(
            :supplier_order => order,
            :supplier => supplier,
            :amount => order.supplier_total
          )
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

