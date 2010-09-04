class MobileNumber < ActiveRecord::Base

  before_validation :normalize_number

  belongs_to  :user

  belongs_to  :active_user,
              :class_name => "User"

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
    self.number
  end

  private
    def normalize_number
      self.number.gsub!(/[^\d]/, "").slice!(/^0+/) if number
    end
end

