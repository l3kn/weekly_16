# Midpoint Displacement

[Weekly Programming Challenge #16](http://weblog.jamisbuck.org/2016/11/12/weekly-programming-challenge-16.html)

## TODO

* Fix dependencies on local shard versions (raytracer / hacky_isometric / linalg)

## Usage

```bash
shards install
crystal run --release hard6.cr
```

## Dependencies

* [l3kn/stumpy_png](http://github.com/l3kn/stumpy_png) for creating .png files
* [l3kn/stumpy_gif](http://github.com/l3kn/stumpy_gif) for creating .gif files
* [l3kn/linalg](http://github.com/l3kn/linalg) for the vector structs
* [l3kn/raytracer](http://github.com/l3kn/raytracer) to render the raytraced images
* [l3kn/hacky_isometric](http://github.com/l3kn/hacky_isometric) to render the isometric images

## Normal mode (1, 2, 3)

![Animated gif of the midpoint displacement algorithm](images/output.gif)

## Hard mode (1)

![Animated gif of the midpoint displacement algorithm](images/square.gif)

## Hard mode (2)

![Animated gif of the midpoint displacement algorithm](images/perpendicular.gif)

## Hard mode (3)

TODO

## Hard mode (4)

TODO

## Hard mode (5)

Already implemented

## Hard mode (6)

It seems like finding parameters that produce a nice image
is harder than implementing the algorithm

![Raytraced terrain generated with the diamond-square algorithm](images/terrain.png)

Phong shading looks much better, but sadly the raytracer is not efficient enough
to render images where the exponent is higher...

![Raytraced terrain generated with the diamond-square algorithm](images/terrain2.png)

Maybe some hacky water will do the trick

![Raytraced terrain generated with the diamond-square algorithm](images/terrain3.png)

It turned out that my implementation of the roughness parameter was not optimal,
here are some images generated with the fixed version (using `0.2`, `0.5` and `0.8` as roughness)

![Raytraced terrain generated with the diamond-square algorithm](images/terrain4_02.png)
![Raytraced terrain generated with the diamond-square algorithm](images/terrain4_05.png)
![Raytraced terrain generated with the diamond-square algorithm](images/terrain4_08.png)

BONUS: A blocky isometric rendering of the terrain

![Raytraced terrain generated with the diamond-square algorithm](images/terrain5.png)
