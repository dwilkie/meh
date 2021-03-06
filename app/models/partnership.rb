class Partnership < ActiveRecord::Base

  belongs_to  :seller,
              :class_name => "User"

  belongs_to  :supplier,
              :class_name => "User"

  has_many    :products

  validates :seller, :supplier,
            :presence => true

  validates :supplier_id,
            :uniqueness => { :scope => :seller_id },
            :presence => true

  def unconfirmed?
    self.confirmed_at.nil?
  end

  def confirmed?
    !unconfirmed?
  end

end

