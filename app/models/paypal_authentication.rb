class PaypalAuthentication < Devise::PaypalAuthentication
  class GetPaypalAuthenticationTokenJob < Struct.new(:id, :callback_url)
    include Paypal::Authentication

    def max_attempts
      3
    end

    def perform
      response = set_auth_flow_param!(callback_url)
      raise("Failed to get paypal authentication token. Paypal error: #{response.long_error_message}") if response.failure?
      PaypalAuthentication.find(id).update_attributes(
        :token => response.token
      )
    end

    def failure
      PaypalAuthentication.find_by_id(id).try(:destroy)
    end

  end

  class GetPaypalAuthenticationDetailsJob < Struct.new(:id)
    include Paypal::Authentication
    def perform
      paypal_authentication = PaypalAuthentication.find(id)
      response = get_auth_details!(paypal_authentication.token)
      raise("Failed to get paypal authentication details. Paypal error: #{response.long_error_message}") if response.failure?
      paypal_authentication.update_attributes(
        :user_details => response.user_details
      )
    end
  end

  def get_authentication_token!
    Delayed::Job.enqueue(
      GetPaypalAuthenticationTokenJob.new(id, callback_url), :priority => 5
    )
  end

  def get_authentication_details!
    self.update_attributes!(:queued_for_confirmation_at => Time.now)
    Delayed::Job.enqueue(
      GetPaypalAuthenticationDetailsJob.new(id), :priority => 5
    )
  end

  def confirming?
    queued_for_confirmation_at.present? && user_details.nil?
  end
end

