require_relative 'lib/robot'
require_relative 'lib/table'
require 'rack'
require 'oj'

Oj.default_options = {:mode => :compat }

use Rack::Session::Cookie, :secret => ENV['COOKIE_SECRET'],
                           :old_secret => ENV['OLD_COOKIE_SECRET'],
                           :expire_after => 3153600000

use Rack::Cors do
  allow do
    origins 'www.lauchlin.com'
    resource '*', :headers => :any, :methods => :get
  end
end

use Rack::Static, :urls => { "" => "index.html" } , :root => "public_html", :index => "index.html"

map '/robot/' do
  run lambda { |env|
    req = Rack::Request.new(env) 
    if req.get?
      path = req.path[%r(^/robot/(move|left|right|report|place/\d+/\d+/(north|east|south|west))$)]
      robot = env['rack.session'][:robot]
      robot ||= Robot.new
      robot.freeze

      env['rack.session'][:robot] = if path.nil?
                                      robot
                                    else
                                      cmd, *args = path.split("/").drop(2)
                                      args[3] = Table.new(0,0,4,4) if cmd == "place"
                                      args[2] = {east: 0.0, north: 0.5, west: 1.0, south: 1.5}[args[2].to_sym] if cmd == "place"
                                      robot.send(cmd, *args)
                                    end

      [200, {'Content-Type' => 'text/json'}, [Oj.dump(env['rack.session'][:robot])]] 
    else
      [404, {'Content-Type' => 'text/html'}, ['404 No such method']] 
    end
  }
end

run Rack::URLMap.new( {
  "/"    => Rack::Directory.new( "public_html" )
} )
