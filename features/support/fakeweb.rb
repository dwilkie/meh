require 'fakeweb'

Before do
  FakeWeb.clean_registry
  FakeWeb.allow_net_connect = false
end
