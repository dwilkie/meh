source 'http://rubygems.org'

gem 'rails', '3.0.3'

gem 'devise', :git => "git://github.com/plataformatec/devise.git"
gem 'devise_paypal', :git => "git://github.com/dwilkie/devise_paypal.git"
#gem 'devise_paypal', :path => '/home/dave/work/plugins/devise_paypal'
gem 'conversational', :git => "git://github.com/dwilkie/conversational.git"
#gem 'conversational', :path => '/home/dave/work/plugins/conversational'
gem 'money'
gem 'httparty'
gem 'delayed_job'
gem 'action_sms', :git => "git://github.com/dwilkie/action_sms.git"
#gem 'action_sms', :path => '/home/dave/work/plugins/action_sms'
gem 'paypal-ipn', :require => 'paypal', :git => "git://github.com/dwilkie/paypal"
#gem 'paypal-ipn', :require => 'paypal', :path => '/home/dave/work/plugins/paypal'
gem "haml-rails"
gem "simple_form"

group :development do
  gem 'sqlite3-ruby', :require => 'sqlite3'
end

group :development, :test do
  gem 'ruby-debug19'
  gem 'rspec-rails', '>= 2.4'
end

group :test do
  gem "test-unit"
  gem 'cucumber-rails'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'pickle', '>= 0.4.4'
  gem 'spork', '>=0.9.0.rc2'
  gem 'fakeweb'
  gem 'launchy'
end

