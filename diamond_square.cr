class DiamondSquare
  getter grid : Array(Array(Float64))
  property roughness : Float64
  getter size : Int32
  getter max : Int32
  getter height : Float64

  def initialize(exponent, @roughness)
    @size = 2**exponent + 1
    @grid = Array.new(@size) { Array.new(@size, 0.0) }
    @max = @size - 1
    @height = 10.0

    # seed_corners { rand(0.0..@max.to_f) }
    seed_corners { 0.0 }
    divide(@max)
  end

  def seed_corners
    set(  0,   0, yield)
    set(max,   0, yield)
    set(max, max, yield)
    set(  0, max, yield)
  end


  def divide(size)
    @height *= @roughness

    x = size / 2
    y = size / 2
    half = size / 2

    return if half < 1

    (half...@max).step(size).each do |y|
      (half...@max).step(size).each do |x|
        s_scale = rand(-1.0..1.0) * @height
        square(x, y, half, s_scale)
      end
    end

    (0..@max).step(half).each do |y|
      (((y + half) % size)..@max).step(size).each do |x|
        d_scale = rand(-1.0..1.0) * @height
        diamond(x, y, half, d_scale)
      end
    end

    divide(half)
  end

  def set(x, y, value)
    @grid[x][y] = value
  end

  def get(x, y)
    if x < 0 || x > @max || y < 0 || y > @max
      -1.0
    else
      @grid[x][y]
    end
  end

  def square(x, y, size, scale)
    top_left = get(x - size, y - size)
    top_right = get(x + size, y - size)
    bottom_left = get(x - size, y + size)
    bottom_right = get(x + size, y + size)

    average = (top_left + top_right + bottom_left + bottom_right) / 4
    set(x, y, average + scale)
  end

  def diamond(x, y, size, scale)
    top_left = get(x, y - size)
    top_right = get(x + size, y)
    bottom_left = get(x - size, y)
    bottom_right = get(x, y + size)

    average = (top_left + top_right + bottom_left + bottom_right) / 4
    set(x, y, average + scale)
  end
end
