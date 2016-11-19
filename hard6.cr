# require "raytracer/raytracer"
# require "raytracer/phong/*"
# require "raytracer/backgrounds/*"
# require "raytracer/helper"
require "../../raytracer/src/raytracer"
require "../../raytracer/src/phong/*"
require "../../raytracer/src/backgrounds/*"
require "../../raytracer/src/helper"
require "./diamond_square"
require "./color_ramp"

MAX_HEIGHT = 5.0

class TerrainTexture < Texture
  def initialize
    @noise = Perlin.new(100)
    @colors = HexColorRamp.new([
      {"#333333", 0.0},
      {"#555555", 0.6},
      {"#016814", 0.8},
      {"#04d82b", 1.0},
    ])
  end

  def value(hit)
    if hit.point.y > 1.0
      n = @noise.perlin(hit.point) * 0.4 - 0.2
      @colors.get(hit.normal.y + n)
    else
      Color.from_hex("#0000ff") * hit.point.y
    end
  end
end

exponent = 9
grid = DiamondSquare.new(exponent, 0.8)

# Normalize the height values to 0..MAX_HEIGHT
max = -Float64::MAX
min = Float64::MAX

(0...grid.max).each do |y|
  (0...grid.max).each do |x|
    current = grid.get(x, y)
    max = current if current > max
    min = current if current < min
  end
end

factor = (max - min) / MAX_HEIGHT
heights = grid.grid.map { |row| row.map { |value| (value - min) / factor } }

size = 20.0
step = size / grid.size
offset = size / 2

# Create two triangles for each set of points
tex = TerrainTexture.new
# tex = NormalTexture.new
mat = Phong::Material.new(0.3, 0.8, 0.1, 0.5, tex)

hitables = [] of FiniteHitable

def triangles(tl, tr, bl, br, mat)
  [Triangle.new(bl, tl, tr, mat), Triangle.new(bl, tr, br, mat)]
end

(0...grid.max).each do |x|
  (0...grid.max).each do |z|
    tl = Point.new(step * x - offset, heights[x][z], step * z - offset)
    tr = Point.new(step * (x + 1) - offset, heights[x+1][z], step * z - offset)
    bl = Point.new(step * x - offset, heights[x][z+1], step * (z + 1) - offset)
    br = Point.new(step * (x + 1) - offset, heights[x+1][z+1], step * (z + 1) - offset)
    hitables.concat(triangles(tl, tr, bl, br, mat))
  end
end

# Render the image
width, height = {800, 400}

# These values are more or less random...
camera = PerspectiveCamera.new(
  look_from: Point.new(-5.0, 7.0, 20.0),
  look_at: Point.new(5.0, 1.0, -20.0),
  vertical_fov: 20.0,
  dimensions: {width, height}
)

lights = [
  # Fake sun
  Phong::Light.new(Point.new(100.0, 50.0, 0.0), 0.7),
  # Fake skydome
  Phong::Light.new(Point.new(0.0, 100.0, 0.0), 0.2)
]

raytracer = Phong::Raytracer.new(
  width, height,
  hitables: SAHBVHNode.new(hitables),
  camera: camera,
  samples: 1,
  lights: lights,
  ambient: 0.0,
  background: SkyBackground.new)

raytracer.render("terrain.png")
