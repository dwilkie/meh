class PaymentRequestObserver < ActiveRecord::Observer
  def after_update(payment_request)
    if notification_verified?(payment_request)
      payment_request.successful_payment? ?
        successfully_paid(payment_request) :
        did_not_pay(payment_request, payment_request.notification_errors)
    elsif given_up?(payment_request)
      did_not_pay(
        payment_request,
        payment_request.seller_failure_error
      ) unless payment_request.remote_application_received?
    end
  end

  private
    def given_up?(payment_request)
      payment_request.gave_up_at_changed? &&
      payment_request.given_up? &&
      payment_request.gave_up_at_was.nil?
    end

    def notification_verified?(payment_request)
      payment_request.notification_verified_at_changed? &&
      payment_request.notification_verified? &&
      payment_request.notification_verified_at_was.nil?
    end

    def did_not_pay(payment_request, errors)
      payment = payment_request.payment
      seller = payment.seller
      PaymentNotification.new(:with => seller).did_not_pay(
        payment,
        :seller => seller,
        :errors => errors
      ) if seller.can_text?
    end

    def successfully_paid(payment_request)
      payment = payment_request.payment
      seller = payment.seller
      supplier_order = payment.supplier_order
      supplier = supplier_order.supplier
      product = supplier_order.product
      seller_order = supplier_order.seller_order
      order_notification = seller_order.order_notification

      notifications = seller.notifications.for_event(
        "payment_successfully_completed",
        :supplier => supplier,
        :product => product
      )
      notifications.each do |notification|
        with = notification.send_to(seller, supplier)
        if with.can_text?
          GeneralNotification.new(:with => with).notify(
            notification,
            :product => product,
            :supplier_order => supplier_order,
            :seller_order => seller_order,
            :seller => seller,
            :supplier => supplier,
            :payment => payment,
            :order_notification => order_notification
          )
        end
      end
    end
end

