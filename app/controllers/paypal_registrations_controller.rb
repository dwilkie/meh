class PaypalRegistrationsController < Devise::PaypalAuthableController
  private
    def render_for_paypal
      render root_path
    end

    def set_paypal_flash_message(key, type, options={})
      options[:user_name] = options[:resource].try(:name)
      set_flash_message(key, type, options)
    end
end

