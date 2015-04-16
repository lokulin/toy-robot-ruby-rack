require_relative 'lib/robot'
require_relative 'lib/table'
require 'rack'
require 'oj'

valid_cmds = Robot.public_instance_methods - Object.methods

Oj.default_options = {:mode => :compat }

use Rack::Session::Cookie, :secret => 'toast',
                           :old_secret => 'toast'

map '/robot/' do
  run lambda { |env|
    req = Rack::Request.new(env) 
    if req.post?
      cmd = /^\/robot\/([a-z]+)/.match(req.path)[1]
      args = /^\/robot\/[a-z]+\/(\d+)\/(\d+)\/([a-z]+)$/.match(req.path).to_a.drop(1)
      args[3] = Table.new(0,0,4,4) if cmd == 'place'

      robot = env['rack.session'][:robot]
      robot ||= Robot.new
      robot.freeze
      env['rack.session'][:robot] = robot.send(cmd, *args) if valid_cmds.index(cmd.to_sym)

      [200, {'Content-Type' => 'text/json'}, [Oj.dump(env['rack.session'][:robot])]] 
    else
      [404, {'Content-Type' => 'text/html'}, ['404 No such method']] 
    end
  }
end

run Proc.new { |env| [404, {'Content-Type' => 'text/html'}, ['404 No such method']] }

