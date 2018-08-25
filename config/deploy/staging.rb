set :rails_env, :staging
set :branch, 'staging'
set :sidekiq_env, :staging
set :stage, :staging

server '142.93.61.91', user: 'deploy', roles: [:web, :app, :db], primary: true
