require "stumpy_utils"
require "linalg"

alias Vector = LA::Vector2

class Array
  # Monadic bind, should behave like `>>=` in haskell
  def bind
    reduce([] of T) { |acc, e| acc += yield e }
  end
end

class Line
  getter point1 : Vector
  getter point2 : Vector
  getter normal : Vector

  def initialize(@point1, @point2, normal = nil)
    edge = @point1 - @point2

    if normal.nil?
      @normal = Vector.new(
        edge.y,
        -edge.x
      ).normalize
    else
      @normal = normal
    end
  end

  def draw(canvas, color)
    StumpyUtils.line(canvas,
                     point1.x.to_i, point1.y.to_i,
                     point2.x.to_i, point2.y.to_i,
                     color)
  end

  def displace(max_offset, keep_normal = true)
    center = (point1 + point2) / 2.0
    offset = rand(-1.0..1.0) * max_offset

    new_center = center + @normal * offset

    if keep_normal
      [
        Line.new(point1, new_center, @normal),
        Line.new(new_center, point2, @normal)
      ]
    else
      [
        Line.new(point1, new_center),
        Line.new(new_center, point2)
      ]
    end
  end
end

class MidpointDisplacement
  @lines : Array(Line)
  @offset : Float64
  @falloff : Float64

  @width : Int32
  @height : Int32

  def initialize(@width, @height, @offset, @falloff, lines = nil)
    center = height.to_f / 2

    if lines.nil?
      @lines = [
        Line.new(
          Vector.new(0.0, center),
          Vector.new(width.to_f, center)
        )
      ]
    else
      @lines = lines
    end
  end

  def generate(iterations = 1, keep_normals = true)
    iterations.times do
      @lines = @lines.bind { |l| l.displace(@offset, keep_normals) }
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
