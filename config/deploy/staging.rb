set :deploy_to, "/var/www/rails"
set :rails_env, "staging"
set :branch, "staging" 
set :repository_cache, "cached-staging"

role :web, "10.42.1.1"
role :app, "10.42.1.1"
role :db,  "10.42.1.1", :primary => true