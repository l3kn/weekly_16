require "stumpy_gif"
require "./midpoint_displacement"
include StumpyGIF

lines = [
  Line.new(
    Vector.new(100.0, 100.0),
    Vector.new(400.0, 100.0)
  ),
  Line.new(
    Vector.new(100.0, 100.0),
    Vector.new(100.0, 400.0)
  ),
  Line.new(
    Vector.new(400.0, 100.0),
    Vector.new(400.0, 400.0)
  ),
  Line.new(
    Vector.new(100.0, 400.0),
    Vector.new(400.0, 400.0)
  ),
]

mpd = MidpointDisplacement.new(500, 500, 100.0, 0.5, lines)
canvases = [] of Canvas

canvases << mpd.draw
10.times do |i|
  puts "Iteration #{i}"
  mpd.generate(1, true)
  canvases << mpd.draw
end

StumpyGIF.write(canvases, "square.gif", delay_time: 100)
