class RenderHelper
  class << self
    def render(options, request = {})
      ENV["RAILS_ENV"] = "staging"
      
      request = { 
        "SERVER_PROTOCOL" => "http", 
        "REQUEST_URI" => "/",
        "SERVER_NAME" => "localhost", 
        "SERVER_PORT" => 80
      }.merge(request)

      av = ActionView::Base.new(ActionController::Base.view_paths)
      
      av.config = Rails.application.config.action_controller
      av.extend ApplicationController._helpers
      av.controller = ActionController::Base.new
      av.controller.request = ActionDispatch::Request.new(request)
      av.controller.response = ActionDispatch::Response.new
      av.controller.headers = Rack::Utils::HeaderHash.new

      av.class_eval do
        include Rails.application.routes.url_helpers
      end

      av.render options 
    end
  end
end

namespace :deploy do
  desc "Deploy Staging Server" 
  task :staging do
    ENV["RAILS_ENV"] = "staging"

    #Rake::Task['assets:precompile'].invoke
    #Rake::Task['deploy:build_html'].invoke
    
    command = "bundle exec rake assets:precompile RAILS_ENV=#{ENV["RAILS_ENV"]} RAILS_GROUPS=assets"
    result = %x[command]
    raise "rake task failed..........\n#{result}" if result.include?('rake aborted!')
    
    command = "bundle exec rake deploy:build_html RAILS_ENV=#{ENV["RAILS_ENV"]}"
    result = %x[command]
    raise "rake task failed..........\n#{result}" if result.include?('rake aborted!')

    
  end
  
  task :build_html => :environment do
    File.open(Rails.root.join('public', 'index.html'), 'w') do |f|
      f.puts RenderHelper.render(template: 'repository/show', layout: 'layouts/application')
    end
    
  end
end