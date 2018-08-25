source 'http://rubygems.org'
ruby '2.3.4'

gem 'rails', '5.0.6'
gem 'foreman', '~> 0.84.0'

# web server : there are 3 of them. choose just one and stick with it?
gem 'puma', '~> 3.10.0'
gem 'rack-cors', '~> 1.0.1'

# database
gem 'pg', '~> 0.18.4'
gem 'pg_search', '~> 2.1.0'
gem 'redis', '~> 3.3.3'
gem 'redis-namespace'

# css related (precomiler, fonts)
gem 'sass-rails', '~> 5.0.6'
gem 'less-rails', '~> 2.8.0'
gem 'bourbon', '~> 4.2.4'
gem 'font-awesome-sass-rails', '~> 3.0.2.2'

# js related
gem 'therubyracer', '~> 0.12.3'
gem 'coffee-rails', '~> 4.2.2'
gem 'uglifier', '~> 3.2.0'
gem 'turbolinks', '~> 5.0.1'
gem 'js-routes', '~> 1.4.0'
gem 'jquery-rails', '~> 4.3.1'
gem 'sprockets-rails', '2.3.3'
gem 'sprockets', '3.6.3'
gem 'jquery-atwho-rails' # to implement @mention autocomplete in text field
gem 'gon' # pass variable from rails to js

# authentication
gem 'devise', '~> 4.3.0'

# authorization
gem 'cancancan', '~>2.0.0'
gem 'pundit', '1.1.0'
gem 'sentient_user', '0.4.0'

# data related
gem 'paranoia', '~> 2.3.1'                          # soft delete
gem 'ranked-model', '~> 0.4'                        # ranking?
gem 'state_machines', '~> 0.5.0'                    # give states to model
gem 'state_machines-activerecord', '~> 0.5.0'       # give states to model
gem 'groupdate', '~> 3.2.0'                         # group by date
gem "ransack", '~> 1.8.3' #, branch: "rails-4.2" # search models
gem "polyamorous", '~> 1.3.1'
#gem 'squeel'     , github: "activerecord-hackery/squeel"
#gem "polyamorous" #, :git => "git://github.com/activerecord-hackery/polyamorous.git"
#gem 'squeel'      #, git: 'https://github.com/activerecord-hackery/squeel.git'

# add comments, votes on models
gem 'acts_as_commentable_with_threading', '~> 2.0.1'
gem 'acts_as_votable', '~> 0.10.0'

# encryption on data
gem 'symmetric-encryption', '~> 3.9.1'

# Track changes to your models' data. Good for auditing or versioning; any perf issues?
gem 'paper_trail', '~> 7.1.1'

# attributes to pojo; used only in OccurrenceOption;
gem 'virtus', '~> 1.0.5'

# views
gem 'haml-rails', '~> 1.0.0'
gem 'slim', '~> 3.0.8'
gem 'simple_form', '~> 3.5.0'
gem 'select2-rails', '~> 4.0.3'
gem 'kaminari', '~> 1.0.1'          # pagination
gem 'kaminari-bootstrap', '~> 3.0.1'
gem 'breadcrumbs_on_rails', '~> 3.0.1'           # creating and managing a breadcrumb navigation

# json/view output
gem 'draper', '~> 3.0.0'
gem 'rabl', '~> 0.13.1'
gem 'oj', '~> 3.3.5'
gem 'active_model_serializers'

# mail related
gem 'actionview-encoded_mail_to', '~> 1.0.9'

# image manipulation
gem 'carrierwave', '~> 1.1.0'
gem 'mini_magick', '~> 4.8.0'
gem 'paperclip', '~> 5.1.0'
gem 'rmagick'

# Simpler currency conversions and display helpers; for currency objects
gem 'money-rails', '~> 1.9.0'

# manage settings with yaml
gem 'settingslogic', '~> 2.0.9'

# used to implement tagging
gem 'closure_tree', '~> 6.6.0'

# 3rd party service
gem 'airbrake', '~> 6.2.1'    # error reporting
gem 'twilio-ruby', '~> 5.1.2' # send sms
gem 'pusher', '~> 1.3.1'                  # push service

# export data
gem 'wicked_pdf', '~> 1.1.0'         # pdf
gem 'roo', '~> 2.7.1'   # spreadsheets
gem 'rubyzip', '~> 1.2.1' # Higher breaks roo

# xml creation
gem 'builder', '~> 3.2.3'
gem 'xml-simple', '~> 1.1.5', require: 'xmlsimple'
gem 'activemodel-serializers-xml', '~> 1.0.2'

# to send fax
gem 'phaxio', '~> 0.5.0'

# background job
gem 'sidekiq', '~> 5.0.4'
# gem 'sinatra' # required for sidekiq?

# cronjob
gem 'whenever', '~> 0.9.7', require: false
gem 'ice_cube', '~> 0.16.2' # Ruby Date Recurrence Library - Allows easy creation of recurrence rules and fast querying

# api documentation
gem 'apipie-rails', '~> 0.5.1'

# dashboard ui
gem 'blazer', '~> 1.8.0'

# rest/http client
gem 'rest-client', '~> 2.0.2'

# feed
gem 'public_activity', '~> 1.5.0'

# aws
gem 'aws-sdk', '~> 2.10.29'
gem 'fog-aws'

# push service
gem 'rpush', '~> 2.7.0'
gem 'net-http-persistent', '~> 2.9.4'

# APM tool
gem 'newrelic_rpm'
gem 'skylight'

gem 'mail_view', "~> 2.0.4"   # is this in use in :production?
gem 'request_store', '~> 1.3.2'           # Per-request global storage for Rack
#gem 'sinatra', require: false # not in use?

# https://github.com/rails/rails/issues/8005
#gem 'activerecord_lax_includes' #, path: './vendor/patch/active-record-lax-includes'

# mocking time - not in use? it should probably be placed under :test env
gem 'delorean', '~> 2.1.0'

# Restrict logging
gem 'lograge', '~> 0.7.1'

# Translation
gem 'google-cloud-translate'

group :test do
  gem 'simplecov', '~> 0.15.0'#, require: false
  gem 'guard-minitest', '~> 2.4.6'
  gem 'minitest-rails', '~> 3.0.0'
  gem 'minitest-rails-capybara', '~> 3.0.1'
  gem 'capybara_minitest_spec', '~> 1.0.6'
  gem 'rb-fsevent', '~> 0.10.2'
  gem 'minitest-metadata', '~> 0.6.0'
  gem 'minitest-reporters', '~> 1.1.15'
  gem 'database_cleaner', '~> 1.6.1'
  # gem 'capybara-webkit', '~> 1.0.0'
  gem 'poltergeist', '~> 1.16.0'
  gem 'timecop', '~> 0.9.1'
  gem 'selenium-webdriver', '~> 3.5.1'
  gem 'capybara-screenshot', '~> 1.0.17'
  gem 'm'
end

group :development do
  gem 'coffee-rails-source-maps', '~> 1.4.0'

  gem 'better_errors', '~> 2.2.0'
  gem 'binding_of_caller', '~> 0.7.2'
  gem 'meta_request', '~> 0.4.3'
  gem 'rails-erd', '~> 1.5.2'
  #gem 'guard-livereload', '~> 1.4.0'
  #gem 'quiet_assets'
  gem 'letter_opener_web', '~> 1.3.1'
  gem 'bullet', '~> 5.6.1'
  gem 'capistrano', '~> 3.9.0'
  gem 'capistrano-rvm', '~> 0.1.2',     require: false
  gem 'capistrano-rails', '~> 1.3.0',   require: false
  gem 'capistrano-bundler', '~> 1.2.0', require: false
  gem 'capistrano3-puma', '~> 3.1.1',   require: false
  gem 'capistrano-sidekiq', '~> 0.20.0', require: false
  gem 'capistrano-rpush', '~> 0.1.7'
  gem 'airbrussh', '~> 1.3.0', require: false
  gem 'rack-mini-profiler', require: false
  gem 'memory_profiler'
end

# group :development, :test do
  gem 'wkhtmltopdf-binary', '~> 0.12.3.1'
  gem 'factory_girl_rails', '~> 4.8.0'
  gem 'faker', '~> 1.8.4'
# end
  #
group :test, :development do
  gem 'jasmine-rails', '~> 0.14.1'
  #gem 'jazz_hands'
  gem 'pry' , '~> 0.10.4'
  gem 'pry-rails' , '~> 0.3.6'
  # gem 'pry-debugger', '~> 0.2.2'
  #gem 'pry-byebug'
  gem 'pry-stack_explorer' , '~> 0.4.9.2'
  gem 'sinon-rails', '~> 1.15.0'
  gem "parallel_tests", '~> 2.14.2'
  gem 'rails-controller-testing', '~> 1.0.2'
end
