require "stumpy_gif"
require "./midpoint_displacement"
include StumpyGIF

mpd = MidpointDisplacement.new(500, 500, 200.0, 0.5)
canvases = [] of Canvas

canvases << mpd.draw
10.times do |i|
  puts "Iteration #{i}"

  # This will calculate normals for each line
  # and use these to displace the midpoint
  mpd.generate(1, false)
  canvases << mpd.draw
end

StumpyGIF.write(canvases, "perpendicular.gif", delay_time: 100)
