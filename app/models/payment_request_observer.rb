class PaymentRequestObserver < ActiveRecord::Observer
  def after_update(payment_request)
    if notification_verified?(payment_request)
      payment = payment_request.payment
      PaymentRequestNotification.new(
        :with => payment.seller
      ).completed(payment_request)
#      PaymentRequestNotification.new(
#        :with => payment.supplier
#      ).notify_supplier(payment_request) if payment_request.successful?
    elsif given_up?(payment_request)
      payment = payment_request.payment
      seller = payment.seller
      PaymentNotification.new(:with => seller).did_not_pay(
        payment,
        :seller => seller,
        :errors => payment_request.seller_failure_error
      ) if seller.can_text?
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

end

