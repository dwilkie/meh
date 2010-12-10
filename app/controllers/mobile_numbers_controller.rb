class MobileNumbersController < ApplicationController
  before_filter :authenticate_user!
  def index
    @mobile_numbers = current_user.mobile_numbers
  end

  def new
    @mobile_number = current_user.mobile_numbers.build
  end
end

