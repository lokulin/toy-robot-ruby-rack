require_relative 'robot'
require_relative 'table'

class RobotRunner
  def run file
    robot = Robot.new(Table.new(0,0,4,4))
    valid_cmds = Robot.public_instance_methods - Object.methods
    
    IO.foreach file do |line|
      if /\A[A-Z]+( \d+,\d+,[A-Z]+){0,1}\n\z/ === line
        cmd, *args = line.downcase.split(/[\s,","]/)
        robot.send cmd,*args if valid_cmds.index(cmd.to_sym)
      end
    end
  end
end
