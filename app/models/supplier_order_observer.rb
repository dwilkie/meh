class SupplierOrderObserver < ActiveRecord::Observer
  def after_create(supplier_order)
    SupplierOrderNotification.new(
      :with => supplier_order.supplier
    ).notification_for_new(supplier_order)
  end

  def after_accept(supplier_order, transition)
    product = supplier_order.product
    seller = supplier_order.seller_order.seller
    supplier = supplier_order.supplier
    notifications = seller.notifications.for_event(
      "supplier_order_accepted",
      :seller => seller,
      :supplier => supplier,
      :product => product
    )
    notifications = seller.find_notifications(
      :product => product,
      :seller => seller,
      :supplier => supplier,
      :event => event
    end
    notifications.each do |notification|
      if notification.is_for_supplier == "seller_who_is_also_a_supplier"
      with = notification.for == "seller" ? seller : supplier
      Notifier.new(:with => with).notify(notification.parse_message)
    end
    supplier = supplier_order.supplier
    SupplierOrderNotification.new(:with => supplier).details(supplier_order)
    pay_supplier_and_notify_seller(supplier_order, transition)
  end

  def after_reject(supplier_order, transition)
    notify_seller(supplier_order)
  end

  def after_complete(supplier_order, transition)
    pay_supplier_and_notify_seller(supplier_order, transition)
  end

  private
    def notify_seller(supplier_order)
      seller = supplier_order.seller_order.seller
      unless seller == supplier_order.supplier
        SupplierOrderNotification.new(
          :with => seller
        ).notify_seller(supplier_order)
      end
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

    def find_notifications(event, options)
      notifications = seller.notifications.where(
        :product => product,
        :event => event
      )
      notifications = seller.notifications.where(
        :event => event
      ) if notifications.empty?
      notifications
    end

    def notify

    end
end

