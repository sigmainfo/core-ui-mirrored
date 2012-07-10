desc "Short for server:start"
task :server => "server:start"

namespace :server do
  desc "Start development server"
  task :start do
    sh "thin --chdir server --environment development --daemonize start"
  end

  desc "Stop development server"
  task :stop do
    sh "thin --chdir server stop"
  end
end
