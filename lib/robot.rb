class Robot
  Direction=Struct.new(:name,:x,:y)

  def initialize table
    @table = table 
  end

  def place x, y, direction
    compass=[
       Direction.new("north",0, 1),
       Direction.new("east",1, 0),
       Direction.new("south",-1,0),
       Direction.new("west",0,-1)
    ]
    @x,@y = @table.contains(x.to_i, y.to_i) || nil
    @compass = compass.rotate(compass.index{|d| d.name==direction}) || nil if 
                                    compass.index{|d| d.name==direction} && @x && @y
    return @x,@y,@compass
  end

  def move
    @x, @y = @table.contains(@x+@compass.first.x, @y+@compass.first.y) || [@x, @y]
  end

  def left
    @compass = @compass.rotate(-1)
  end

  def right
    @compass = @compass.rotate
  end

  def report
    puts "#{@x},#{@y},#{@compass.first.name.upcase}" if placed?
  end

  private def placed?
    @x && @y && @compass
  end
end
