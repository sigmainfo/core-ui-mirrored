set :deploy_to, "/var/www/rails"
set :rails_env, "production"
set :branch, "production" 

role :web, "10.43.2.2"
role :app, "10.43.2.2"
role :db,  "10.43.2.2", :primary => true