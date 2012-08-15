desc "Run features"
task :spinach => "spinach:run"

namespace :spinach do
  task :env do
    ENV["RAILS_ENV"] = "test"
  end

  def run_spinach(*args)
    sh "spinach " << args.join(" ")
  end

  task :run => :env do
    run_spinach "--tags ~@wip --tags ~@skip"
  end

  task :generate => :env do
    run_spinach "--generate"
  end

  task :wip => :env do
    run_spinach "--tags @wip,~@skip"
  end

  task :all => :env do
    run_spinach
  end
end
