class SupplierOrderObserver < ActiveRecord::Observer
  def after_create(supplier_order)
    notify supplier_order, "supplier_order_created"
  end

  def after_update(supplier_order)
    if supplier_order.confirmed? && supplier_order.confirmed_at_changed? && supplier_order.confirmed_at_was.nil?
      notify_and_pay supplier_order, "supplier_order_confirmed"
    elsif supplier_order.completed? && supplier_order.completed_at_changed? && supplier_order.completed_at_was.nil?
      notify_and_pay supplier_order, "supplier_order_completed"
    end
  end

  private
    def notify_and_pay(supplier_order, event)
      notify supplier_order, event
      pay_for supplier_order, event
    end

    def pay_for(supplier_order, event)
      supplier = supplier_order.supplier
      seller = supplier_order.seller_order.seller
      payment_agreement = seller.payment_agreements_with_suppliers.for_event(
        event,
        supplier,
      ).first
      if payment_agreement && payment_agreement.enabled?
        supplier_payment = seller.outgoing_supplier_payments.build(
          :supplier_order => supplier_order,
          :supplier => supplier,
          :amount => supplier_order.supplier_total
        )
        supplier_payment.save
        SupplierPaymentNotification.new(:with => seller).did_not_pay(
          supplier_payment,
          :supplier => supplier,
          :seller => seller,
          :errors => supplier_payment.errors
        ) unless supplier_payment.valid?
      end
    end

    def notify(supplier_order, event)
      seller_order = supplier_order.seller_order
      seller = seller_order.seller
      supplier = supplier_order.supplier
      order_notification = seller_order.order_notification

      notifications = seller.notifications.for_event(
        event, :supplier => supplier
      )
      notifications.each do |notification|
        with = notification.send_to(seller, supplier)
        notifier = GeneralNotification.new(:with => with)
        notifier.payer = seller
        notifier.notify(
          notification,
          :supplier_order => supplier_order,
          :seller_order => seller_order,
          :seller => seller,
          :supplier => supplier,
          :order_notification => order_notification
        )
      end
    end
end

