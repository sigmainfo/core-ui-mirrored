set :deploy_to, "/var/www/rails"
set :rails_env, "staging"
set :branch, "staging" 

role :web, "10.43.1.10"
role :app, "10.43.1.10"
role :db,  "10.43.1.10", :primary => true