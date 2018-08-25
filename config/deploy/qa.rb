set :rails_env, :qa
set :branch, :develop
set :sidekiq_env, :qa
set :stage, :qa

server '46.101.47.7', user: 'deploy', roles: [:web, :app, :db], primary: true
