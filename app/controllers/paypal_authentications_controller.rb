class PaypalAuthenticationsController < Devise::PaypalAuthableController
  def new
    callback_url = paypal_authable_callback_uri(:user => params[:user])
    redirect_to authenticate_with_paypal_url(callback_url)
  end

  private
    def render_for_paypal
      redirect_to root_path
    end

    def set_paypal_flash_message(key, type, options={})
      options[:user_name] = options[:resource].try(:name)
      options[:returning] = options[:resource].try(:sign_in_count).to_i > 0 ?
      I18n.t("devise.returning") : ""
      options[:errors] = options[:resource].errors.full_messages.to_sentence
      set_flash_message(key, type, options)
    end
end

