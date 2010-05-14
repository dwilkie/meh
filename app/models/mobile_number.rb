class MobileNumber < ActiveRecord::Base
  #############################################################################
  # CALLBACKS
  #############################################################################

  before_validation :normalise_phone
  before_save       :change_state_or_generate_codes

  #############################################################################
  # ASSOCIATONS
  #############################################################################

  belongs_to :phoneable, :polymorphic => true
  has_many   :conversations, :foreign_key => "with"
  has_many   :outgoing_text_messages, :as => :smsable
  has_many   :incoming_text_messages, :as => :smsable

  #############################################################################
  # STATES
  #############################################################################

  state_machine :state, :initial => :unverified do
    event :internal_verify do
      transition :unverified => :active, :if => :verification_code_valid_and_registered?
    end

    event :unverify do
      transition [:active, :inactive] => :unverified
    end

    event :internal_activate do
      transition :inactive => :active, :if => :activation_code_valid?
    end

    event :deactivate do
      transition :active => :inactive
    end
  end

  def verify!
    self.verification_code_confirmation = self.verification_code
    self.save!
    raise "Mobile number not verified" unless self.active?
  end

  def activate!
    generate_activation_code unless was_requested_for_activation?
    self.activation_code_confirmation = self.activation_code
    self.save!
    raise "Mobile number not active" unless self.active?
  end

  def deactivate_active_number_unless!(mobile_number)
    unless self == mobile_number || !self.active?
      self.deactivate
      self.save!
    end
  end

  def reset_activation_code_unless!(mobile_number)
    unless self == mobile_number || self.activation_code.nil?
      self.activation_code = nil
      self.save!
    end
  end

  def verified?
    self unless self.unverified?
  end

  def unverified?
    self if state == 'unverified'
  end
  alias :find_unverified_numbers :unverified?

  def active?
    self if self.state == 'active'
  end

  def inactive?
    self unless self.active?
  end

  def registered?
    self unless self.unregistered?
  end

  def unregistered?
    self if self.phoneable.nil?
  end


  validates :number, :presence => true,
            :uniqueness => true,
            :format => {:with => %r{^[1-9]{1}[0-9]{0,2}[1-9]{1}\d{5,12}$}},
            :length => {:in => 7..15}

  validates :state, :presence => true,
            :inclusion => {:in => ["unverified", "active", "inactive"] }

  validates :verification_code,
            :confirmation => {:on => :update,
                              :unless => Proc.new { |p| p.new_verification_code_requested?
                                                  }
                             }


  validates :activation_code,
            :confirmation => {:on => :update,
                              :unless => Proc.new { |p| p.activation_code_confirmation.blank? || p.new_activation_code_requested?
                                                  }

                             }

  attr_accessor :request_new_verification_code, :request_new_activation_code

  def humanize
    '+' + self.number if self.number && !self.number.blank?
  end

  def to_s
    self.number
  end

  def locale=(locale)
    if registered?
      phoneable.locale = locale
    else
      super(locale)
    end
  end

  def locale
    if registered?
      phoneable.locale
    else
      super
    end
  end

  def new_verification_code_requested?
    @request_new_verification_code == "1"
  end

  def new_activation_code_requested?
    @request_new_activation_code == "1"
  end

  def activation_code_generated?
    !self.activation_code.nil?
  end

  def request_new_activation_code=(value)
    if !value || value == "0" || value == 0
      @request_new_activation_code = "0"
    else
      @request_new_activation_code = "1"
    end
  end

  def request_new_verification_code=(value)
    if !value || value == "0" || value == 0
      @request_new_verification_code = "0"
    else
      @request_new_verification_code = "1"
    end
  end

  def was_requested_for_activation?
    self if activation_code_generated? && !active?
  end
  alias :find_number_with_activation_request :was_requested_for_activation?

  def self.active_mobile_number
    self.find_by_state('active')
  end

  private
    # normalises the mobile number by removing invalid characters
    def normalise_phone
      if self.number && !self.number.blank?
        # remove everything that is not a digit from the number
        self.number.gsub!(/[^\d]/, "")
        # remove leading zeros from phone
        self.number.slice!(/^0+/)
      end
    end

    def change_state_or_generate_codes
      if self.number_changed? || self.new_verification_code_requested?
        generate_verification_code
        self.unverify if self.verified?
      elsif self.new_activation_code_requested?
        generate_activation_code
        self.phoneable.reset_activation_code_on_other_numbers(self)
      # validation has already ensured that the code matches
      elsif !self.verification_code_confirmation.blank? && !self.verified? && self.registered?
        self.internal_verify
      elsif !self.activation_code_confirmation.blank? && self.verified? && !self.active?
        self.internal_activate
        self.activation_code = nil
      end
      if self.active? && self.state_changed?
        self.phoneable.deactivate_other_active_numbers(self)
      end
      true
    end

    def generate_verification_code
      self.verification_code = generate_random_code.to_s
    end

    def generate_activation_code
      self.activation_code = generate_random_code.to_s
    end

    def generate_random_code
      SecureRandom.random_number(99999-10000) + 10000
    end

    def verification_code_valid_and_registered?
      self.registered? && self.verification_code == self.verification_code_confirmation
    end

    def activation_code_valid?
      self.activation_code == self.activation_code_confirmation
    end
end

