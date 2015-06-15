set :application, "coreonapp"
set :scm, :git
set :repo_url, "git@github.com:gmah/core-ui.git"

set :user, 'www'
set :domain, 'appcoreon.com'
set :deploy_to, "/var/www/rails"

set :default_env, { path: '/opt/www/Latest/bin:/usr/local/bin:/usr/bin:/bin' }
set :keep_releases, 5

set :ssh_options, { :forward_agent => true }
SSHKit.config.command_map[:rake]  = "bundle exec rake"
SSHKit.config.command_map[:rails] = "bundle exec rails"
