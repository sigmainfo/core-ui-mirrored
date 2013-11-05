set :stage, :production
set :branch, "production"
set :rails_env, "production"

server '10.43.2.2', user: 'www', roles: %w{web app db}

fetch(:default_env).merge!(rails_env: :production)
