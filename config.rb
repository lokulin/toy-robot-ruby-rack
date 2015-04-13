require_relative 'lib/robot'
require_relative 'lib/table'
require 'webrick'
require 'oj'

root = File.expand_path './public_html'
server = WEBrick::HTTPServer.new :Port => 8000, :DocumentRoot => root

trap 'INT' do server.shutdown end

class RobotRestServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET request, response
    #status, content_type, body = do_stuff_with request
    robot = Robot.new(Table.new(0,0,4,4))
    response.status = 200
    response['Content-Type'] = 'text/json'
    response.body = Oj.dump robot
  end
end
 
server.mount '/robot/', RobotRestServlet
Oj.default_options = {:mode => :compat }
server.start


