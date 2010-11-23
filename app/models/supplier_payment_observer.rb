class SupplierPaymentObserver < ActiveRecord::Observer
  def after_update(supplier_payment)
    if notification_set?(supplier_payment)
      if supplier_payment.completed?
        successfully_paid(supplier_payment)
      elsif supplier_payment.unclaimed?
        unclaimed(supplier_payment)
      end
    elsif pay_response_set?(supplier_payment)
      did_not_pay(supplier_payment) unless supplier_payment.successful?
    end
  end

  private

    def notification_set?(supplier_payment)
      supplier_payment.notification_id_changed? &&
      supplier_payment.notification &&
      supplier_payment.notification_id_was.nil?
    end

    def pay_response_set?(supplier_payment)
      supplier_payment.payment_response_changed? &&
      supplier_payment.payment_response? &&
      supplier_payment.payment_response_was.nil?
    end

    def did_not_pay(supplier_payment)
      seller = supplier_payment.seller
      SupplierPaymentNotification.new(:with => seller).did_not_pay(
        supplier_payment,
        :seller => seller,
        :errors => supplier_payment.payment_error
      )
    end

    def unclaimed(supplier_payment)
      unclaimed_for(supplier_payment, :seller)
      unclaimed_for(supplier_payment, :supplier)
    end

    def unclaimed_for(supplier_payment, role)
      role = role.to_s
      actor = supplier_payment.send(role)
      notifier = SupplierPaymentNotification.new(:with => actor)
      notifier.payer = supplier_payment.seller
      notifier.send("unclaimed_for_#{role}", supplier_payment)
    end

    def successfully_paid(supplier_payment)
      seller = supplier_payment.seller
      supplier_order = supplier_payment.supplier_order
      supplier = supplier_order.supplier
      product = supplier_order.product
      seller_order = supplier_order.seller_order
      order_notification = seller_order.order_notification

      notifications = seller.notifications.for_event(
        "supplier_payment_successfully_completed",
        :supplier => supplier,
        :product => product
      )
      notifications.each do |notification|
        with = notification.send_to(seller, supplier)
        notifier = GeneralNotification.new(:with => with)
        notifier.payer = seller
        notifier.notify(
          notification,
          :product => product,
          :supplier_order => supplier_order,
          :seller_order => seller_order,
          :seller => seller,
          :supplier => supplier,
          :supplier_payment => supplier_payment,
          :order_notification => order_notification
        )
      end
    end
end

