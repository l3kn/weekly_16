require "../../hacky_isometric/hacky_isometric"
require "./diamond_square"

exponent = 8
grid = DiamondSquare.new(exponent, 0.4)

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

heights = grid.grid.map { |row| row.map { |value| (value - min) / (max - min) } }
width, height = {800, 400}
world = Canvas.new(width, height, RGBA.from_rgb_n({255, 255, 255}, 8))
z_buffer = ZBuffer.new(width, height, -999999)

blocks = [] of Block

size = 10.0

grid.max.times do |x_|
  grid.max.times do |z_|
    height = heights[x_][z_]

    x = x_ - (grid.max / 2)
    z = z_ - (grid.max / 2)

    y_max = (height * 80.0).to_i
    y = y_max
    # (0..y_max).each do |y|
      blocks << Block.new(
        Vector3.new(x * size, y * size, z * size), 
        Vector3.new(size),
        RGBA.from_rgb_n({
          0,
          128 * Math.sin(x.to_f / 100) + 127,
          128 * Math.sin(z.to_f / 100) + 127,
        }, 8)
      )
    # end
  end
end

blocks.each(&.draw(world, z_buffer, draw_edges: true))
StumpyPNG.write(world, "output.png")
