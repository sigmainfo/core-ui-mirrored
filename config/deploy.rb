default_environment['PATH'] = '/opt/www/Latest/bin:/usr/local/bin:/usr/bin:/bin'

require 'capistrano/ext/multistage'
require 'bundler/capistrano'
load 'deploy/assets'

set :user, 'www'
set :domain, 'www.core'
set :application, "core-ui"

set :scm, :git
set :repository, "git@devel.spom.net:core-ui.git"
set :scm_verbose, true
set :use_sudo, false
set :git_shallow_clone, 1
set :deploy_via, :remote_cache

set :stages, %w(staging production)
set :default_stage, "staging"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  
  desc 'Build static HTML for index'
  task :build_html do
    run "cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} deploy:build_html"
  end
end

after "deploy:restart", "deploy:cleanup"
after "deploy:assets:precompile", "deploy:build_html"
