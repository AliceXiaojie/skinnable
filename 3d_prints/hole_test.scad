start = 1;
inc   = .25;
end   = 5;

pad   = 1;
depth = 4.5;
ttt = 0;

difference()
{
/*
	translate([0,-3.5,-depth/2-2])
		cube([18, 7, depth+2]);
		*/

	for(i = [start : end])
	{
		translate([i*(i+1)/2,0,0])
			cylinder(d=i, h=depth, center=true, $fn=25);
	}

}
