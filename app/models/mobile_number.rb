class MobileNumber < ActiveRecord::Base

  before_validation :normalize_number

  belongs_to  :user

  has_many   :outgoing_text_messages
  has_many   :incoming_text_messages

  validates :number,
            :presence => true,
            :uniqueness => true,
            :format => {:with => /^[1-9]{1}[0-9]{0,2}[1-9]{1}\d{5,12}$/ },
            :allow_nil => true,
            :allow_blank => true

  validates :user,
            :presence => true

  before_save :activate

  def humanize(show_unverified = false)
    (verified? || show_unverified) ? '+' + self.to_s :
    I18n.t(
      "activerecord.states.mobile_number.unverified"
    )
  end

  def to_s
    number
  end

  def unverified?
    verified_at.nil?
  end

  def verified?
    !unverified?
  end

  def activate!
    activate
    save! if active_changed?
  end

  def verify!
    self.update_attributes!(:verified_at => Time.now)
  end

  private
    def activate
      user = self.user
      if user && self.active != user.id
        user.active_mobile_number = self
      end
    end

    def normalize_number
      if number
        number.gsub!(/\D/, "")
        number.slice!(/^0+/)
      end
    end
end

