require_relative 'lib/robot'
require_relative 'lib/table'
require 'rack'
require 'oj'

valid_cmds = Robot.public_instance_methods - Object.methods

Oj.default_options = {:mode => :compat }

use Rack::Session::Cookie, :secret => "toast",
                           :old_secret => "toast"

map "/robot/" do
  run lambda { |env|
    req = Rack::Request.new(env) 
    if req.post?
      cmd = /^\/robot\/([a-z]+)/.match(req.path)[1]
      args = /^\/robot\/[a-z]+\/(\d+)\/(\d+)\/([a-z]+)$/.match(req.path).to_a.drop(1)
      robot = env['rack.session'][:robot]
      if robot.nil? 
        robot = Robot.new(Table.new(0,0,4,4))
      end
      robot.send cmd,*args if valid_cmds.index(cmd.to_sym)
      env['rack.session'][:robot] = robot
      ["200", {"Content-Type" => "text/html"}, [Oj.dump(robot)]] 
    else
      ["404", {"Content-Type" => "text/html"}, ["404"]] 
    end
  }
end

run Proc.new { |env| ['200', {'Content-Type' => 'text/html'}, ['get rack\'d']] }

