require "raytracer/raytracer"
require "raytracer/backgrounds/*"
require "raytracer/helper"
require "./diamond_square"

MAX_HEIGHT = 3.0

class ColorRamp
  property steps : Array(Tuple(Color, Float64))

  def initialize(steps)
    # Make sure all steps have valid values
    steps.each do |c, v|
      if v < 0.0 || v > 1.0
        raise "Invalid value ColorRamp step: #{v} (must be in 0..1)"
      end
    end

    # TODO: make sure there are at least two steps
    # one with value 0.0 and one with value 1.0
    @steps = steps.sort_by { |e| e[1] }
  end

  def get(value)
    if value <= 0.0
      steps[0][0]
    elsif value >= 1.0
      steps[-1][0]
    else
      c0, v0 = steps[0]
      c1, v1 = steps[0]

      steps[1..-1].each do |c, v|
        c0 = c1
        v0 = v1
        c1 = c
        v1 = v

        break if v >= value
      end

      t = (value - v0) / (v1 - v0)
      mix(c1, c0, t)
    end
  end
end

class HexColorRamp < ColorRamp
  def initialize(steps : Array(Tuple(String, Float64)))
    super(steps.map { |hex, v| {Color.from_hex(hex), v} })
  end
end

class TerrainTexture < Texture
  def initialize
    @noise = Perlin.new(100)
    @colors = HexColorRamp.new([
      {"#016814", 0.0},
      {"#04d82b", 0.2},
      {"#222222", 0.5},
      {"#111111", 1.0},
    ])
  end

  def value(hit)
    v = hit.point.y / MAX_HEIGHT
    # v / hit.normal.y

    noise = (@noise.perlin(hit.point * 2.0) + 5.0) / 6.0
    c = @colors.get(v * noise)

    # factor = ((hit.normal.y - 0.6) / 0.4) * [v / 0.2, 1.0].min * [(hit.normal.y / 0.4), 1.0].min
    # c = mix(c, Color.from_hex("#ffffff"), factor)

    c
  end
end

exponent = 9

grid = DiamondSquare.new(exponent, 20.0)
width = grid.max
height = grid.max

max = -Float64::MAX
min = Float64::MAX

(0...height).each do |y|
  (0...width).each do |x|
    current = grid.get(x, y)
    max = current if current > max
    min = current if current < min
  end
end

hitables = [] of FiniteHitable

mat = Lambertian.new(TerrainTexture.new)
# mat = Lambertian.new(NormalTexture.new)

def triangles(tl, tr, bl, br, mat)
  [Triangle.new(bl, tl, tr, mat), Triangle.new(bl, tr, br, mat)]
end

factor = (max - min) / MAX_HEIGHT
heights = grid.grid.map { |row| row.map { |value| (value - min) / factor } }

size = 20.0
step = size / grid.size
offset = size / 2

(0...grid.max).each do |x|
  (0...grid.max).each do |z|
    tl = Point.new(step * x - offset, heights[x][z], step * z - offset)
    tr = Point.new(step * (x + 1) - offset, heights[x+1][z], step * z - offset)
    bl = Point.new(step * x - offset, heights[x][z+1], step * (z + 1) - offset)
    br = Point.new(step * (x + 1) - offset, heights[x+1][z+1], step * (z + 1) - offset)
    hitables.concat(triangles(tl, tr, bl, br, mat))
  end
end

width, height = {800, 400}

camera = PerspectiveCamera.new(
  look_from: Point.new(0.0, 5.0, 14.0),
  look_at: Point.new(0.0, 1.0, 0.0),
  vertical_fov: 20.0,
  dimensions: {width, height}
)

raytracer = SimpleRaytracer.new(width, height,
  hitables: BVHNode.new(hitables),
  camera: camera,
  samples: 5,
  background: SkyBackground.new)

raytracer.render("terrain.png")
