from __future__  import division
from solid       import *
from solid.utils import *

hole_z = 5
hole_x = range(1,6)
pad_x  = 5
pad_z  = 4
depth  = 15

v = []

trans = 0
base = cube([0,0,0])
for x in hole_x:
  c = cube(
      [
        pad_x + x + pad_x,
        depth,
        pad_z + hole_z + pad_z,
      ], center=True)
  d = up(hole_z/2)(cube([x, depth + 5, hole_z*2], center=True))
        
  v.append(right(trans)(c - d))
  trans += pad_x + x*2

print scad_render(union()(v))
