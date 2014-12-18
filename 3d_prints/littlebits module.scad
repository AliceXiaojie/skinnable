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


function modlen(mod_type)    = mod_type[1] * mm(.25);
function modwidth(mod_type)  = module_width;
function modheight(mod_type) = module_height;


//Input module: ["name", length, [top1, top2...], [bottom1, bottom2...], [l,r]]
// where topX and bottomX are the hole position of the center of the top
// and bottom magnetic connectors. For example, a button would be:
//   ["button", 4]
// a branch would be:
//   ["branch", 7, [4], [4]]
// and a sequencer would be:
//   ["sequencer", 18, [3, 7, 11, 15], [3, 7, 11, 15]]
// Use optional [l, r] to specify whether to place left and right magnetic
// end pieces; e.g., power modules have only right connections.
module lbmod(mod_type)
{
	name   = mod_type[0];
	length = modlen(mod_type);
	top    = mod_type[2];
	bot    = mod_type[3];
	lr     = mod_type[4] ? mod_type[4] : [true, true];
		
	translate([length/2 + module_depth/2, 0, 0])
	{
		//Main body
		difference()
		{
			union()
			{
				if(lr[0])
					translate([-length/2, 0, 0])
						mag_end(true);
				if(lr[1])
					translate([length/2, 0, 0])
						rotate(180)
							mag_end(true);
				translate([0, 0, leg_support_height + board_thickness/2])
					cube([length, module_width, board_thickness], center=true);
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

	//Special cases -------

		if(name == "p3")  //Power; add block for subtracting usb power
		{
			//usb block: 15x10x5
			translate([-length/2 - 2.5, 0, board_thickness+5])
				cube([15 ,10, 5], center=true);
		}

	}

	if($children)
		translate([length + module_depth, 0, 0])
			children(0);
}

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
w1l = ["w1", 2, [], [], [false, true]];  //w1 wire right connector
w1r = ["w1", 2, [], [], [true, false]];  //w1 wire right connector
p1  = ["p1", 5, [], [], [false, true]];  //p1 barrel power
p3  = ["p3", 4, [], [], [false, true]];  //p3 usb power
