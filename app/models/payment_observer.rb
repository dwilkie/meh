class PaymentObserver < ActiveRecord::Observer
  def before_create(payment)
    seller = payment.seller
    payment_request = payment.build_payment_request(
      :payment_application => seller.payment_application
    )
    unless payment_request.valid?
      PaymentNotification.new(:with => seller).did_not_pay(
        payment,
        :seller => seller,
        :errors => payment_request.errors
      ) if seller.can_text?
      false
    end
  end
end

