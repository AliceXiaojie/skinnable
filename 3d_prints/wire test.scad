

union() {
	translate(v = [0, 0, 0]) {
		difference() {
			cube(center = true, size = [11, 15, 6]);
			translate(v = [0, 0, 2.5000000000]) {
				cube(center = true, size = [1, 20, 5]);
			}
		}
	}
	translate(v = [7, 0, 0]) {
		difference() {
			cube(center = true, size = [12, 15, 13]);
			translate(v = [0, 0, 2.5000000000]) {
				cube(center = true, size = [2, 20, 10]);
			}
		}
	}
	translate(v = [16, 0, 0]) {
		difference() {
			cube(center = true, size = [13, 15, 13]);
			translate(v = [0, 0, 2.5000000000]) {
				cube(center = true, size = [3, 20, 10]);
			}
		}
	}
	translate(v = [27, 0, 0]) {
		difference() {
			cube(center = true, size = [14, 15, 13]);
			translate(v = [0, 0, 2.5000000000]) {
				cube(center = true, size = [4, 20, 10]);
			}
		}
	}
	translate(v = [40, 0, 0]) {
		difference() {
			cube(center = true, size = [15, 15, 13]);
			translate(v = [0, 0, 2.5000000000]) {
				cube(center = true, size = [5, 20, 10]);
			}
		}
	}
}
