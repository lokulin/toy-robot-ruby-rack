include Math

class Robot
  def initialize(x=0.0, y=0.0, facing=0.5, table=nil)
    @x, @y, @facing, @table = x.to_f, y.to_f, facing.to_f, table
  end

  def move
    place @x+cos(PI*@facing), @y+sin(PI*@facing), @facing, @table
  end

  def left
    place @x, @y, (@facing+0.5), @table
  end

  def right
    place @x, @y, (@facing-0.5), @table
  end

  def report
    #puts "#{@x},#{@y},#{@facing}" if @table.instance_of? Table
    self
  end

  def place(x, y, facing, table)
    if (table.instance_of?(Table) && table.contains(x.to_i, y.to_i))
      Robot.new(x, y, facing, table)
    else
      self
    end
  end
end

