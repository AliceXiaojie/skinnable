use <write.scad>;

in2mm              = 25.4;         //convert inches to mm
board_thickness    = 1.75;         //thickness of circuit board
width              = .8 * in2mm;   //width of whole module (y)
leg_support_height = .1 * in2mm;   //height of square leg part

//Generate one magnetic end, translated so that the feet sink below
// the x/y plane
module mag_end(tab=false)
{
	depth              = 3/16 * in2mm; //depth of plastic end (x)
	width              = .8 * in2mm;   //width of whole module (y)
	height             = .5 * in2mm;   //height of whole module (z)
	leg_rad            = 1/8 * in2mm;  //radius of leg
	leg_height         = .1 * in2mm;   //height of round leg part
	leg_support_height = .1 * in2mm;   //height of square leg part
	space_between_legs = .5 * in2mm;   //space between legs
	tab_depth          = 2;            //depth of mating tab (x)
	tab_width          = 1/8 * in2mm;  //width of mating tab (y)
	tab_height         = .05 * in2mm;  //height of mating tab (z)

	translate([-depth/2, 0, -leg_height])
	{
		difference()
		{
			union()
			{
				//leg 1
				translate([0, -(space_between_legs/2), 0])
					cylinder(r=leg_rad, h=leg_height, $fn=25);
				//leg 2
				translate([0, (space_between_legs/2), 0])
					cylinder(r=leg_rad, h=leg_height, $fn=25);
				//leg support
				translate([leg_rad/2, 0, (height - leg_height)/2 + leg_support_height])
					cube([depth, width, height - leg_height], center=true);
			}

			//Take out the hole for the matching tab
			if(tab)
				translate([tab_depth/2, -tab_width/2, tab_height/2 + leg_height + leg_support_height + board_thickness])
					cube([tab_depth, tab_width, tab_height], center=true);

			//Take off half of legs in plane of magnets
			translate([-depth/2, 0, 0])
				cube([depth, width, height*4], center=true);

			//Take off other quarter of legs, and interior of plastic part, in
			// direction of board
			translate([0, 0, (leg_height + leg_support_height)/2])
				cube([depth*2, space_between_legs, leg_height + leg_support_height], center=true);
		}

		//tab
		if(tab)
			translate([-tab_depth/2, tab_width/2, tab_height/2 + leg_height + leg_support_height + board_thickness])
				cube([tab_depth, tab_width, tab_height], center=true);
	}
}

//Generate a little bits module n holes long (legs count as half holes;
// e.g., the standard module such as the i3 button is 4 holes long).
module lb_module(name="x00", length=4, tabs=false)
{

	difference()
	{
		union()
		{
			translate([-(length * .25 * in2mm)/2, 0, 0])
				mag_end(tabs);
			translate([(length * .25 * in2mm)/2, 0, 0])
				rotate(180)
					mag_end(tabs);
			translate([0, 0, leg_support_height + board_thickness/2])
				cube([length * .25 * in2mm, width, board_thickness], center=true);
		}
		translate([0, 0, leg_support_height + board_thickness])
			write(name, font="letters.dxf", center=true, t=board_thickness/2, h=5);
	}
}

lb_module(tabs=true);


//Modules that I know or can guess the size for
module lb_i2()  { lb_module("i2",   4); }   //i2 toggle switch
module lb_i3()  { lb_module("i3",   4); }   //i3 button
module lb_i7()  { lb_module("i7",   3); }   //i7 remote trigger
module lb_i17() { lb_module("i17",  4); }   //i17 timeout
module lb_i20() { lb_module("i20",  4); }   //i20 sound trigger
module lb_i34() { lb_module("i34",  4); }   //i34 random
module lb_w20() { lb_module("w20", 10); }  //w20 cloud
module lb_o3()  { lb_module("o3",   4); }   //o3 rgb led
