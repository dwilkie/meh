module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /create paypal ipn/
      paypal_ipns_path

    when /create text message delivery receipt/
      text_message_delivery_receipts_path

    when /create incoming text message/
      incoming_text_messages_path

    when /^the paypal authable callback page$/
      user_paypal_authable_callback_path(
        :token => @token || "token"
      )

    when /^the login page$/
      new_user_session_path

    when /^the overview page$/
      user_root_path

    when /^the order simulation page$/
      new_order_simulation_path

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)

