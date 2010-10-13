class UserObserver < ActiveRecord::Observer
  def after_create(user)
    allocate_free_credits(user)
    if user.is?(:seller)
      user.notifications.create_defaults!
    end
  end

  private
    def allocate_free_credits(user)
      user.add_message_credits(15)
    end
end

