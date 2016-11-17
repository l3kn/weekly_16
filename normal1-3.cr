require "stumpy_gif"
require "./midpoint_displacement"
include StumpyGIF

mpd = MidpointDisplacement.new(500, 500, 200.0, 0.5)
canvases = [] of Canvas

canvases << mpd.draw
10.times do |i|
  puts "Iteration #{i}"
  mpd.generate(1, true)
  canvases << mpd.draw
end

StumpyGIF.write(canvases, "output.gif", delay_time: 100)
