use <write.scad>;

//Convert inches to mm
function mm(in) = in * 25.4;

board_thickness    = 1.75;     //thickness of circuit board
width              = mm(.8);   //width of whole module (y)
leg_support_height = mm(.1);   //height of square leg part
depth              = mm(3/16); //depth of plastic end (x)
height             = mm(.5);   //height of whole module (z)
wire_depth         = 13;       //depth of entire wire module (x)


//Generate one magnetic end, translated so that the feet sink below
// the x/y plane
module mag_end(tab=false)
{
	leg_rad            = mm(1/8);  //radius of leg
	leg_height         = mm(.1);   //height of round leg part
	leg_support_height = mm(.1);   //height of square leg part
	space_between_legs = mm(.5);   //space between legs
	tab_depth          = 2;            //depth of mating tab (x)
	tab_width          = mm(1/8);  //width of mating tab (y)
	tab_height         = mm(.05);  //height of mating tab (z)

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
module _lb_module(name="x00", length=4, tabs=false)
{
	translate([(length * mm(.25))/2 + depth/2, 0, 0])
	difference()
	{
		union()
		{
			translate([-(length * mm(.25))/2, 0, 0])
				mag_end(tabs);
			translate([(length * mm(.25))/2, 0, 0])
				rotate(180)
					mag_end(tabs);
			translate([0, 0, leg_support_height + board_thickness/2])
				cube([length * mm(.25), width, board_thickness], center=true);
		}
		translate([0, 0, leg_support_height + board_thickness])
			write(name, font="letters.dxf", center=true, t=board_thickness/2, h=5);
	}
}


module _wire(tabs=false)
{
	length = 2;
	union()
	{
		translate([-(length * mm(.25))/2, 0, 0])
			mag_end(tabs);
		//board
		translate([0, 0, leg_support_height + board_thickness/2])
			cube([wire_depth, width, board_thickness], center=true);
	}
}

module wire_out(tabs=false)
{
	translate([wire_depth/2 + depth/2 - .25, 0, 0])
		difference()
		{
			_wire(tabs);
			translate([0, 0, leg_support_height + board_thickness])
				write("w1", font="letters.dxf", center=true, t=board_thickness/2, h=5);
		}
}


module wire_in(tabs=false)
{
	translate([wire_depth/2, 0, 0])
		difference()
		{
			rotate(180)
				_wire(tabs);
			translate([0, 0, leg_support_height + board_thickness])
				write("w1", font="letters.dxf", center=true, t=board_thickness/2, h=5);
		}
	if($children)
		translate([wire_depth + depth/2 - .25, 0, 0])
			children(0);
}

wire_in()
lb_module(i3)
lb_module(i20)
lb_module(w20)
lb_module(i7)
wire_out()
;

//Extract properties from the module list at bottom
function lb_mod_name(mod_type) = mod_type[0];
function lb_mod_size(mod_type) = mod_type[1];

module lb_module(mod_type, tabs=false)
{
	name = lb_mod_name(mod_type);
	size = lb_mod_size(mod_type);
	_lb_module(name, size, tabs);
	if($children)
		translate([(size + .5) * mm(.25) + 1.5, 0, 0])
			children(0);
}

//Modules that I know or can guess the size for
i2  = ["i2",   4];  //i2 toggle switch
i3  = ["i3",   4];  //i3 button
i7  = ["i7",   3];  //i7 remote trigger
i17 = ["i17",  4];  //i17 timeout
i20 = ["i20",  4];  //i20 sound trigger
i34 = ["i34",  4];  //i34 random
w20 = ["w20", 10];  //w20 cloud
o3  = ["o3",   4];  //o3 rgb led


/*
wire_in()
lb_module(i2)
lb_module(i3)
lb_module(i7)
lb_module(i3)
lb_module(i17)
lb_module(w20)
lb_module(i3)
;
*/
