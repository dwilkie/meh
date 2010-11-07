source 'http://rubygems.org'

gem 'rails', '3.0.1'

# Bundle edge Rails instead:
#gem 'rails', :git => 'git://github.com/rails/rails.git'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# Bundle the extra gems:
gem 'devise', :git => "git://github.com/plataformatec/devise.git"
gem 'devise_paypal', :path => '/home/dave/work/plugins/devise_paypal'
gem 'conversational'
gem 'money'
gem 'httparty'
gem 'delayed_job', ' >=2.1.0.pre2'
gem 'action_sms', :path => '/home/dave/work/plugins/action_sms'
#gem 'action_sms', :git => 'git://github.com/dwilkie/action_sms.git'
gem 'paypal-ipn', :require => 'paypal', :path => '/home/dave/work/plugins/paypal'
gem "haml-rails"

# gem 'bj'
# gem 'nokogiri', '1.4.1'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

group :development do
  gem 'ruby-debug19'
  gem 'sqlite3-ruby', :require => 'sqlite3'
end

## Bundle gems for certain environments:
group :test do
  gem 'test-unit'
  gem 'rspec'
  gem 'rspec-core'
  gem 'rspec-mocks'
  gem 'rspec-expectations'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'pickle'
  gem 'cucumber-rails'
  gem 'spork'
  gem 'fakeweb'
  gem 'ruby-debug19'
  gem 'launchy'
end

