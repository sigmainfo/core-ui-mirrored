set :deploy_to, "/var/www/rails"
set :rails_env, "acceptance"
set :branch, "acceptance" 
set :repository_cache, "cached-acceptance"

role :web, "10.42.1.50"
role :app, "10.42.1.50"
role :db,  "10.42.1.50", :primary => true