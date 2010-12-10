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

  before_save :activate

  def self.with_number(number)
    where(:number => normalize(number))
  end

  def humanize(show_unverified = true)
    (verified? || show_unverified) ? '+' + self.to_s :
    I18n.t(
      "activerecord.states.mobile_number.unverified"
    ) + " #{self.class.model_name.human}"
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
    def self.normalize(number)
      if number
        normalized_number = number.gsub(/\D/, "")
        normalized_number.slice!(/^0+/)
      end
      normalized_number
    end

    def activate
      user = self.user
      if user && active != user.id
        user.active_mobile_number = self
      end
    end

    def normalize_number
      self.number = self.class.normalize(number)
    end
end

