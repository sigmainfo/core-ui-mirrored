desc "Run features"
task :spinach => "spinach:run"

namespace :spinach do
  task :env do
    ENV["RAILS_ENV"] = "test"
    require "spinach"
    require Rails.root.join "config", "initializers", "spinach"
  end

  def run_spinach(*args)
    sh "spinach " << args.join(" ")
  end

  task :run => :env do
    run_spinach "--tags ~@wip"
  end

  task :generate => :env do
    run_spinach "--generate"
  end

  task :wip => :env do
    run_spinach "--tags @wip"
  end

  task :all => :env do
    run_spinach
  end
end
