require 'net/http'
require 'uri'

module CoreAPI
  attr_writer :port
  
  def self.start_server
    #return @server if @server
    #require 'rails/commands/server'
    #@server =  Rack::Server.new
    #Dir.chdir(Rails.application.root.join '..', 'core-api')
    
    #@server.options[:Port] = port
    #@server.options[:environment] = 'test'
    #@server.options[:daemonize] = false
    #@server.send :options, {Port: port, environment: 'test'}
    #@thread = Thread.new { @server.start }
    #puts @server.start
    #@server = Thin::Server.start( '0.0.0.0', port )
    
    puts `cd #{Rails.application.root.join '..', 'core-api'} && RAILS_ENV=test thin start -d -p #{port}`
    sleep 10
    Dir.chdir(Rails.application.root)
  end
  
  def self.stop_server
    `cd #{Rails.application.root.join '..', 'core-api'} && RAILS_ENV=test thin stop`
    #Thread.kill(@thread) if @thread
    #@thread = nil
    #@server = nil
  end
  
  def self.port
    @port ||= 3336
  end
  
  def self.host_with_port
    "localhost:#{self.port}"
  end
  
  def self.session=(session)
    @core_session = session
  end
  
  def self.build_headers(headers)
    { 
      "X-Core-Session" => @core_session || '',
      "Content-Type" => "application/json; charset=utf-8",
      "Accept" => "application/json"
    }.merge(headers.stringify_keys)
  end
  
  def self.get action, headers = {}
    uri = URI.parse("http://#{host_with_port}/#{action}")
    
    http = Net::HTTP.new(uri.host, uri.port)
    
    response, data = http.get(
      uri.request_uri,
      build_headers(headers)
    )
  end
  
  def self.post action, payload = {}, headers = {}
    uri = URI.parse("http://#{host_with_port}/#{action}")
    #puts uri
    
    http = Net::HTTP.new(uri.host, uri.port)
    
    #puts "VORHER"
    #puts uri.request_uri
    #puts payload.to_json
    #puts headers
    #puts build_headers(headers)
    begin
      response, data = http.post(
        uri.request_uri,
        payload.to_json,
        build_headers(headers)
      )
    rescue => me
      puts "Some error occured: #{me.inspect}"
      raise
    end
    #puts "NACHHER"
  end
  
  def self.put action, payload = {}, headers = {}
    uri = URI.parse("http://#{host_with_port}/#{action}")
    
    http = Net::HTTP.new(uri.host, uri.port)
    
    response, data = http.put(
      uri.request_uri,
      payload.to_json,
      build_headers(headers)
    )
  end
  
  def self.delete action, headers = {}
    uri = URI.parse("http://#{host_with_port}/#{action}")
    http = Net::HTTP.new(uri.host, uri.port)
    
    response, data = http.delete(
      uri.request_uri,
      build_headers(headers)
    )
  end

  def self.purge!
    delete("test/purge").class.should == ::Net::HTTPOK
  end
end                          

class Net::HTTPResponse
  def success?
    self.is_a? ::Net::HTTPSuccess
  end
  def json
    JSON.parse body
  end
end


                               
