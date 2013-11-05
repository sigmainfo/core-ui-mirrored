set :stage, :staging
set :branch, "staging" 
set :rails_env, "staging"

server '10.43.1.10', user: 'www', roles: %w{web app db}

fetch(:default_env).merge!(rails_env: :staging)
