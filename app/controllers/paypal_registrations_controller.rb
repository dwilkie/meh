class PaypalRegistrationsController < Devise::PaypalPermissionsAuthableController
  def new
    @permissions = {:mass_pay => true}
    super
  end
end

