module URIHelpers
  def register_outgoing_text_message_uri(options = {})
    options[:body] ||= options[:for_failure] ? "ERROR: No action requested" : "OK: 0; Sent queued message ID: 86b1a945370734f4 SMSGlobalMsgID:6942744494999745"
    FakeWeb.register_uri(
      :post,
      "https://smsglobal.com.au/http-api.php",
      :body => options[:body]
    )
  end
end

World(URIHelpers)

