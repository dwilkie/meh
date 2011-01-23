class PaypalAuthentication < Devise::PaypalAuthentication
  class GetPaypalAuthenticationTokenJob < Struct.new(:id, :callback_url)
    def perform
      authenticate_with_paypal_url(callback_url)
    end
  end


  def get_authentication_token
    Delayed::Job.enqueue(
      GetPaypalAuthenticationTokenJob.new(id, callback_url), :priority => 5
    )
  end

end

