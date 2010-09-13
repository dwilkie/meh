class PaymentRequestObserver < ActiveRecord::Observer
  def after_update(payment_request)
    if notification_verified?(payment_request)
      if payment_request.successful_payment?
      else
        did_not_pay(payment_request, payment_request.notification_errors)
      end
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
end

