require "stumpy_utils"
require "stumpy_png"
require "stumpy_gif"

include StumpyPNG

offset = 50.0
falloff = 0.5

struct Point
  getter x : Float64
  getter y : Float64

  def initialize(@x, @y)
  end

  def +(other : Point)
    Point.new(
      x + other.x,
      y + other.y
    )
  end

  def /(other)
    Point.new(
      x / other,
      y / other
    )
  end
end

class Line
  getter point1 : Point
  getter point2 : Point

  def initialize(@point1, @point2)
  end

  def draw(canvas, color)
    StumpyUtils.line(canvas,
                     point1.x.to_i, point1.y.to_i,
                     point2.x.to_i, point2.y.to_i,
                     color)
  end

  def displace(max_offset)
    center = (point1 + point2) / 2
    offset = rand(-1.0..1.0) * max_offset

    new_center = Point.new(
      center.x,
      center.y + offset
    )

    [
      Line.new(point1, new_center),
      Line.new(new_center, point2)
    ]
  end
end

class MidpointDisplacement
  @lines : Array(Line)
  @offset : Float64
  @falloff : Float64

  @width : Int32
  @height : Int32

  def initialize(@width, @height, @offset, @falloff)
    center = height.to_f / 2
    @lines = [
      Line.new(
        Point.new(0.0, center),
        Point.new(width.to_f, center)
      )
    ]
  end

  def generate(iterations = 1)
    iterations.times do
      @lines = @lines.reduce([] of Line) { |acc, l| acc += l.displace(@offset) }
      @offset /= 2
    end
  end

  def draw
    canvas = Canvas.new(@width, @height, RGBA.from_rgb_n({255, 255, 255}, 8))
    @lines.each do |line|
      line.draw(canvas, RGBA.from_rgb_n({0, 0, 0}, 8))
    end
    canvas
  end
end

mpd = MidpointDisplacement.new(500, 500, 200.0, 0.5)
# mpd = MidpointDisplacement.new(200, 200, 70.0, 0.5)
canvases = [] of Canvas

canvases << mpd.draw
10.times do |i|
  puts "Iteration #{i}"
  mpd.generate
  canvases << mpd.draw
end

# canvas = mpd.draw
# StumpyPNG.write(canvas, "output.png")

StumpyGIF.write(canvases, "output.gif", delay_time: 100)
