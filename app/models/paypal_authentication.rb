class PaypalAuthentication < Devise::PaypalAuthentication
  class GetPaypalAuthenticationTokenJob < Struct.new(:id, :callback_url)
    include Paypal::Authentication
    def perform
      response = set_auth_flow_param!(callback_url)
      raise("Failed to get token") unless response.success?
      PaypalAuthentication.find(id).update_attributes(
        :token => response.token
      )
    end
  end

  def get_authentication_token!
    Delayed::Job.enqueue(
      GetPaypalAuthenticationTokenJob.new(id, callback_url), :priority => 5
    )
  end
end

