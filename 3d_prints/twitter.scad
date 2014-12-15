//Import a file and center it. As a side effect, scale it such that its x
// dimension is as specified.
module import_center_size(filename, sizex=50)
{
	translate([-sizex/2, 0, 0])
		resize([sizex, 0, 0], auto=true)
			translate([0, -sizex/2, 0])
				resize([0, sizex, 0], auto=true)
					import(filename);
}

//To find out the size of an imported file, look for the 
// %%BoundingBox: 0 -1 138 113
// line. This is llx, lly, urx, ury in points (1 in = 72 p), so
// the width in mm = (urx - llx) * 25.4/72 .
// Use:
// awk '/%%BoundingBox: ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*)/{print ($4-$2)*25.4/72,($5-$3)*25.4/72}' twitter.eps
/*
translate([-48.6833/2, -40.2167/2, 0])
	linear_extrude(10)
		import("twitter_outline.dxf");
		*/

//translate([-48.6833/2, -40.2167/2, 0])
	//linear_extrude(1)
		import("twitter.dxf");

/*
translate([0,0,10])
	linear_extrude(1)
		import_center_size("twitter_inset.dxf");
		*/



/*
difference()
{
	render()
	{
		minkowski()
		{
		 cube(1);
		 //cylinder(r=2,h=1);
		 linear_extrude(1)
			 import("twitter.dxf");
		}
	}
	linear_extrude(2)
		import("twitter.dxf");
}
*/
