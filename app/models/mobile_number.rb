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

  def humanize
    '+' + self.to_s
  end

  def to_s
    number
  end

  def unverified?
    verified_at.nil?
  end

  private
    def normalize_number
      if number
        number.gsub!(/\D/, "")
        number.slice!(/^0+/)
      end
    end
end

