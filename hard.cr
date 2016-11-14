require "stumpy_utils"
require "stumpy_png"
require "stumpy_gif"
# require "linalg/vector"
require "../../cralgebra/src/vector"
require "./diamond_square"

include StumpyPNG

exponent = 10

test = DiamondSquare.new(exponent, 1.0)
width = test.max
height = test.max
canvas = Canvas.new(width, height, RGBA.from_rgb_n({255, 255, 255}, 8))

max = -Float64::MAX
min = Float64::MAX

(0...height).each do |y|
  (0...width).each do |x|
    current = test.get(x, y)
    max = current if current > max
    min = current if current < min
  end
end

(0...height).each do |y|
  (0...width).each do |x|
    current = test.get(x, y)
    gray = ((current - min) / (max - min)) * 255

    canvas[x, y] = RGBA.from_gray_n(gray, 8)
  end
end

StumpyPNG.write(canvas, "dia.png")
