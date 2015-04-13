class Table
  def initialize x,y,xx,yy
    @x, @y, @xx, @yy = x, y, xx, yy
  end

  def contains x,y
    return x, y if x >= @x && y >= @y && x <= @xx && y <= @yy
  end
end
