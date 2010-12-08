class PaypalAuthenticationsController < Devise::PaypalAuthableController
  private
    def render_for_paypal
      redirect_to user_root_path
    end

    def set_paypal_flash_message(key, type, options={})
      options[:user_name] = options[:resource].try(:name)
      options[:returning] = options[:resource].try(:sign_in_count).to_i > 0 ?
      I18n.t("devise.returning") : ""
      set_flash_message(key, type, options)
    end
end

