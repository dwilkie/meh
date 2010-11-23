class ProductOrderObserver < ActiveRecord::Observer
  def after_create(product_order)
    notify_and_pay product_order, "product_order_created"
  end

  def after_update(product_order)
    if product_order.accepted? && product_order.accepted_at_changed? && product_order.accepted_at_was.nil?
      notify_and_pay product_order, "product_order_accepted"
    elsif product_order.completed? && product_order.completed_at_changed? && product_order.completed_at_was.nil?
      notify_and_pay product_order, "product_order_completed"
    end
  end

  private
    def notify_and_pay(product_order, event)
      notify product_order, event
      pay_for product_order, event
    end

    def pay_for(product_order, event)
      supplier = product_order.supplier
      seller = product_order.seller_order.seller
      product = product_order.product
      payment_agreement = seller.payment_agreements_with_suppliers.for_event(
        event,
        supplier,
        product
      ).first
      if payment_agreement && payment_agreement.enabled?
        supplier_payment = seller.outgoing_supplier_payments.build(
          :product_order => product_order,
          :supplier => supplier,
          :amount => product_order.supplier_total
        )
        supplier_payment.save
        SupplierPaymentNotification.new(:with => seller).did_not_pay(
          supplier_payment,
          :supplier => supplier,
          :seller => seller,
          :product => product,
          :errors => supplier_payment.errors
        ) unless supplier_payment.valid? || seller.cannot_text?
      end
    end

    def find_payment_agreement(product, seller, supplier)
      payment_agreement = product.payment_agreement
      payment_agreement = seller.payment_agreement_with_supplier(supplier) if payment_agreement.nil?
      payment_agreement
    end

    def notify(product_order, event)
      product = product_order.product
      seller_order = product_order.seller_order
      seller = seller_order.seller
      supplier = product_order.supplier
      order_notification = seller_order.order_notification

      notifications = seller.notifications.for_event(
        event,
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
          :product_order => product_order,
          :seller_order => seller_order,
          :seller => seller,
          :supplier => supplier,
          :order_notification => order_notification
        )
      end
    end
end

