require_relative 'lib/robot'
require_relative 'lib/table'
require 'rack'
require 'rack/cors'
require 'rack/rewrite' 
require 'omniauth/strategies/github' 
require 'oj'

Oj.default_options = {:mode => :compat }

use Rack::Session::Cookie, :secret => ENV['COOKIE_SECRET'],
                           :old_secret => ENV['OLD_COOKIE_SECRET'],
                           :domain => 'lauchlin.com',
                           :expire_after => 3153600000

use Rack::Cors do
  allow do
    origins 'www.lauchlin.com'
    resource '*', :headers => :any, :methods => [ :get, :post, :options ], :credentials => true
  end
end

use Rack::Static, :urls => { '' => 'index.html' } , :root => 'public_html', :index => 'index.html'

use OmniAuth::Builder do
  provider :github, ENV['GIT_KEY'], ENV['GIT_SECRET']
end

use Rack::Rewrite do
  r301 %r{/(.*)}, '/auth/github', :not => %r{/auth/(.*)}, :if => Proc.new {|env|
    env['rack.session'][:user_id].nil?
  }
end

map '/auth/github/callback' do
  run lambda do |env|
    auth = env['omniauth.auth']
    if auth['credentials'].fetch('token', nil)
        env['rack.session'][:user_id] = auth['info']['nickname']
      out='http://www.lauchlin.com/toyrobot/'
    else
      out='/auth/failure'
    end 
    
    [301, {'Content-Type' => 'text/html',
           'Location' => '#{out}' }, ['']]
  end
end

map '/auth/failure' do
  run lambda { |env| [200, {'Content-Type' => 'text/html'}, ['Nope.']] }
end

map '/robot/' do
  run lambda { |env|
    req = Rack::Request.new(env) 
    path = req.path[%r(^/robot/(move|left|right|report|place/\d+/\d+/(north|east|south|west))$)]
    robot = env['rack.session'][:robot]
    robot ||= Robot.new
    robot.freeze

    env['rack.session'][:robot] = if path.nil?
                                    robot
                                  else
                                    cmd, *args = path.split('/').drop(2)
                                    args[3] = Table.new(0,0,4,4) if cmd == 'place'
                                    args[2] = {east: 0.0, north: 0.5, west: 1.0, south: 1.5}[args[2].to_sym] if cmd == 'place'
                                    robot.send(cmd, *args)
                                  end

    [200, {'Content-Type' => 'text/json'}, [Oj.dump(env['rack.session'][:robot])]] 
  }
end

run Rack::URLMap.new( {
  '/'    => Rack::Directory.new( 'public_html' )
} )
