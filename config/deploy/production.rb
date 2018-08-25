set :rails_env, :production
set :branch, 'master'
set :sidekiq_env, :production
set :stage, :production

server '104.236.115.227', user: 'deploy', roles: [:web, :app, :db], primary: true
