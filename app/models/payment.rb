class Payment < ActiveRecord::Base

  composed_of :amount,
              :class_name => "Money",
              :mapping => [%w(cents cents), %w(currency currency_as_string)]

  belongs_to  :supplier,
              :class_name => "User"
          
  belongs_to  :seller,
              :class_name => "User"
  
  belongs_to  :supplier_order,
              :class_name => "Order"
              
  has_one     :payment_request
  
  serialize   :params
  
  validates :cents,
            :presence => true,
            :numericality => {:only_integer => true, :greater_than => 0}

  validates :currency,
            :presence => true,
            :unless => Proc.new { |payment|
              payment.cents <= 0
            }
            
  validates :supplier_order,
            :presence => true

  validates :supplier_order_id,
            :uniqueness => true
            
  validates :seller,
            :presence => true
            
  validates :supplier,
            :presence => true
            
  validates :status,
            :presence => true

  state_machine :status, :initial => :payment_not_requested do
  end
  
end
