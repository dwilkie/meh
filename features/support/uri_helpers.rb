module URIHelpers
  def register_outgoing_text_message_uri(options = {})
    options[:success] ||= true
    options[:body] ||= options[:success] ? "OK: 0; Sent queued message ID: 86b1a945370734f4 SMSGlobalMsgID:6942744494999745" : "ERROR: No action requested"
    FakeWeb.register_uri(
      :post,
      "https://smsglobal.com.au/http-api.php",
      :body => options[:body]
    )
  end
end

World(URIHelpers)

