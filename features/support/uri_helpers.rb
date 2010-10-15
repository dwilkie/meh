module URIHelpers
  def register_outgoing_text_message_uri(options = {})
    sms_gateway = ActionSms::Base.connection
    options[:body] ||= sms_gateway.sample_delivery_response(
      :failed => options[:for_failure]
    )
    FakeWeb.register_uri(
      :post,
      sms_gateway.service_url,
      :body => options[:body]
    )
  end
end

World(URIHelpers)

