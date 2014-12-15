//To compensate for shrinkage
printer_multiplier = 1.13;

mm_per_in     = 25.4;
hole_diameter = 7/32 * mm_per_in;
hole_depth    = 3;
between_holes = 1.0;
slot_width    = 1.5;
C             = hole_diameter + between_holes;


//A magnetic module end needs two circle holes; enlarge the holes by
// the printer_multiplier factor.
module mag_end()
{
	translate([0, 0, 0])
		cylinder(d=hole_diameter * printer_multiplier, h=hole_depth, $fn=25);
	translate([0, -C, 0])
		cylinder(d=hole_diameter * printer_multiplier, h=hole_depth, $fn=25);
	translate([0, C, 0])
		cylinder(d=hole_diameter * printer_multiplier, h=hole_depth, $fn=25);
}

//Create holes for a double-ended magnetic module with length_in_C
// full holes in between the ends (not counting the ends themselves).
// Holes will be centered on the origin.
module double_mag_module(length_in_C)
{
	translate([-length_in_C/2*C, 0, 0])
		mag_end();
	translate([length_in_C/2*C, 0, 0])
		mag_end();
}

//A cCc x c3c module hole

difference()
{
	cube([C*5+2, 22, hole_depth*1.5], center=true);
	double_mag_module(4);
	/*
	translate([0,0,hole_depth*1.5-hole_depth-1])
		cube([C*3-2, 22, hole_depth+1], center=true);
		*/
	//mag_end();
}
