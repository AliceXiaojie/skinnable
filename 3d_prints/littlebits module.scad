use <write.scad>;

//Convert inches to mm
function mm(in) = in * 25.4;

board_thickness    = 1.75;     //thickness of circuit board
module_width       = mm(.8);   //width of whole module (y)
leg_support_height = mm(.1);   //height of square leg part
module_depth       = mm(3/16); //depth of plastic end (x)
module_height      = mm(.5);   //height of whole module (z)
wire_depth         = 13;       //depth of entire wire module (x)


//Generate one magnetic end, translated so that the feet sink below
// the x/y plane
module mag_end(tab=false)
{
	leg_rad            = mm(1/8);  //radius of leg
	leg_height         = mm(.1);   //height of round leg part
	leg_support_height = mm(.1);   //height of square leg part
	space_between_legs = mm(.5);   //space between legs
	tab_depth          = 2;        //depth of mating tab (x)
	tab_width          = mm(1/8);  //width of mating tab (y)
	tab_height         = mm(.05);  //height of mating tab (z)

	translate([-module_depth/2, 0, -leg_height])
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
				translate([leg_rad/2, 0, (module_height - leg_height)/2 + leg_support_height])
					cube([module_depth, module_width, module_height - leg_height], center=true);
			}

			//Take out the hole for the matching tab
			if(tab)
				translate([tab_depth/2, -tab_width/2, tab_height/2 + leg_height + leg_support_height + board_thickness])
					cube([tab_depth, tab_width, tab_height], center=true);

			//Take off half of legs in plane of magnets
			translate([-module_depth/2, 0, 0])
				cube([module_depth, module_width, module_height*4], center=true);

			//Take off other quarter of legs, and interior of plastic part, in
			// direction of board
			translate([0, 0, (leg_height + leg_support_height)/2])
				cube([module_depth*2, space_between_legs, leg_height + leg_support_height], center=true);
		}

		//tab
		if(tab)
			translate([-tab_depth/2, tab_width/2, tab_height/2 + leg_height + leg_support_height + board_thickness])
				cube([tab_depth, tab_width, tab_height], center=true);
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
			cube([wire_depth, module_width, board_thickness], center=true);
	}
}

module wire_out(tabs=false)
{
	translate([wire_depth/2 + module_depth/2 - .25, 0, 0])
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
		translate([wire_depth + module_depth/2 - .25, 0, 0])
			children(0);
}


//Input module: ["name", length, [top1, top2...], [bottom1, bottom2...]]
// where topX and bottomX are the hole position of the center of the top
// and bottom magnetic connectors. For example, a button would be:
// ["button", 4]
// a branch would be:
// ["branch", 7, [4], [4]]
// and a sequencer would be:
// ["sequencer", 18, [3, 7, 11, 15], [3, 7, 11, 15]]
module mod(mod_type)
{
	name   = mod_type[0];
	length = mod_type[1];
	top    = mod_type[2];
	bot    = mod_type[3];
		
	translate([(length * mm(.25))/2 + module_depth/2, 0, 0])
	{
		//Main body
		difference()
		{
			union()
			{
				translate([-(length * mm(.25))/2, 0, 0])
					mag_end(true);
				translate([(length * mm(.25))/2, 0, 0])
					rotate(180)
						mag_end(true);
				translate([0, 0, leg_support_height + board_thickness/2])
					cube([length * mm(.25), module_width, board_thickness], center=true);
			}
			translate([0, 0, leg_support_height + board_thickness])
				write(name, font="letters.dxf", center=true, t=board_thickness/2, h=5);
		}

		//Top connectors
		for(i = top)
			translate([-length/2 * mm(.25) - module_depth/2 + i*mm(.25), module_width/2, 0])
				rotate(-90)
					mag_end(true);

		//Bottom connectors
		for(i = bot)
			translate([-length/2 * mm(.25) - module_depth/2 + i*mm(.25), -module_width/2, 0])
				rotate(90)
					mag_end(true);
	}

	if($children)
		translate([(length * mm(.25)) + module_depth, 0, 0])
			children(0);
}

b = ["branch", 6, [4], [4]];
//mod(b);

s = ["sequencer", 17, [3, 7, 11, 15], [3, 7, 11, 15]];
mod(s)
mod(i2);

//Modules that I know or can guess the size for
i2  = ["i2",   4];  //i2 toggle switch
i3  = ["i3",   4];  //i3 button
i7  = ["i7",   3];  //i7 remote trigger
i17 = ["i17",  4];  //i17 timeout
i20 = ["i20",  4];  //i20 sound trigger
i22 = ["i22", 17, [3, 7, 11, 15], [3, 7, 11, 15]];  //i22 sequencer
i34 = ["i34",  4];  //i34 random
w2  = ["w2", 6, [4], [4]]; //w2 branch
w20 = ["w20", 10];  //w20 cloud
o3  = ["o3",   4];  //o3 rgb led
