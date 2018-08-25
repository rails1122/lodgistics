set :rails_env, :production
set :branch, 'master'
set :sidekiq_env, :production
set :stage, :production

server '138.197.100.48', user: 'deploy', roles: [:web, :app, :db], primary: true
