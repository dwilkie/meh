class PaypalIpn < ActiveRecord::Base
  serialize :params
end
