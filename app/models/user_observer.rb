class UserObserver < ActiveRecord::Observer
  def after_create(user)
    if user.is?(:seller)
      user.notifications.create_defaults!
    end
  end
end

