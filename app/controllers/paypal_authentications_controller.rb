class PaypalAuthenticationsController < Devise::PaypalAuthableController
  def new
    if callback_url = paypal_authentication_callback_url
      redirect_to callback_url
      callback_url = nil
    else
      unless paypal_authentication_token_requested?
        request_paypal_authentication_token
        callback_url = paypal_authable_callback_uri(:user => params[:user])
        set_paypal_authentication_callback_url(callback_url)
      end
    end
  end

  def create
    paypal_authentication = PaypalAuthentication.create(
      paypal_authable_callback_uri, :params => params
    )
    redirect_to paypal_authentication_path(paypal_authentication)
  end

  def show
    @paypal_authentication = PaypalAuthentication.find(params[:id])
    redirect_to @paypal_authentication.url if @paypal_authentication.token
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

    def paypal_authentication_token_requested?
      session[:paypal_authentication_token_requested]
    end

    def request_paypal_authentication_token
      session[:paypal_authentication_token_requested] = true
    end

    def paypal_authentication_callback_url
      session[:paypal_authentication_callback_url]
    end

    def set_paypal_authentication_callback_url(callback_url)
      session[:paypal_authentication_callback_url] = delay.authenticate_with_paypal_url(
        callback_url
      )
      session[:paypal_authentication_token_requested] = nil
    end
end

