class PaymentRequestObserver < ActiveRecord::Observer
  def after_update(payment_request)
    if payment_request.notification_verified_at &&
      payment_request.notification_verified_at_changed?
      payment = payment_request.payment
      PaymentRequestNotification.new(
        :with => payment.seller
      ).completed(payment_request)
#      PaymentRequestNotification.new(
#        :with => payment.supplier
#      ).notify_supplier(payment_request) if payment_request.successful?
    end
  end
end

