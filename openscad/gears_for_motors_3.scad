use <MCAD\involute_gears.scad>;
use <utilities.scad>;

//pi=3.14159;
//$fn=32;
strut_t=3;
depth = 40;
ratio = 2;
teeth_smallgear = 12;
teeth_biggear = teeth_smallgear * ratio;
c2c_distance = 20; //see output from motor_lugs
pitch = c2c_distance * 360 / (teeth_smallgear + teeth_biggear);
d=0.05;

//pitch radius = Nteeth * circular_pitch / 360
//pitch radius is centre of gear to meshing point
//outer radius = pitch radius * (1 + 2*pi/Nteeth)
//our c2c distance is 10+12.5mm=22.5mm, 
module large_gear(){
	assign($fn=32, pi=3.14159, pitch_r=c2c_distance*(ratio/(ratio+1)))
	difference(){
		intersection(){
			gear(number_of_teeth=teeth_biggear,
				circular_pitch=pitch,
				circles=0,
				gear_thickness=6,
				hub_thickness=6,
				hub_diameter=20,
				rim_thickness=6,
				bore_diameter=1);	
			cylinder(r1=pitch_r-2,r2=pitch_r+18,h=20); //stop bottoms of teeth being funny
		}
		translate([0,0,1.5]) nut(3,shaft=true,fudge=1.2,h=999);
//		for(i=[0:5]) rotate(i*60) translate([pitch_r*0.55,0,0.5]) cylinder(r=pitch_r*0.2,h=999);
	}
}

module small_gear(){	
	$fn=32;
    pi=3.14159;
    h=8;
    flat_h=h-3.5;
    shaft_r=5/2*1.1;
    pitch_r=c2c_distance*1/(ratio+1);
	difference(){
		union(){
			gear(number_of_teeth=teeth_smallgear,
					circular_pitch=pitch,
					circles=0,
					gear_thickness=h,
					hub_thickness=h,
					hub_diameter=1,
					rim_thickness=h,
					bore_diameter=1);
				
			cylinder(r=pitch_r+pi*pitch_r/teeth_smallgear,h=0.5); //help adhesion
		}
        //cut-out for motor shaft
		intersection(){
			cylinder(r=shaft_r, h=999, center=true);
			sequential_hull(){
                translate([0,0,-d]) cube([999,3,d]*1.1,center=true);
                translate([0,0,flat_h]) cube([999,3,d]*1.1,center=true);
                translate([0,0,flat_h+2]) cube([999,7,d]*1.1,center=true);
                translate([0,0,999]) cube([999,7,d]*1.1,center=true);
            }
		}
        //chamfer the top/bottom for better fit
        translate([0,0,h]) cylinder(r1=shaft_r,r2=shaft_r+2,h=2,center=true);
        translate([0,0,0]) cylinder(r2=shaft_r,r1=shaft_r+2,h=2,center=true);
	}
}


rotate(360/teeth_biggear/2) large_gear();
//translate([c2c_distance*2,00]) small_gear();

module thumbwheel(r=10,h=5,knobble_r=1,knobble_angle=45,chamfer=0.5){
    knobble_length=knobble_r * sin(knobble_angle) * 2;
    n_knobbles = floor(2*3.141*r/knobble_length);
    difference(){
        intersection(){
            union(){
                for(i=[1:n_knobbles]) rotate(i/n_knobbles*360){
                    translate([0,r-knobble_r,0]) cylinder(r=knobble_r,h=h,$fn=16);
                }
                cylinder(r=r-knobble_r,h=h,$fn=n_knobbles);
            }
            cylinder(r1=r-knobble_r-chamfer, r2=r-knobble_r-chamfer+999,h=999,$fn=n_knobbles);
            translate([0,0,h-999])cylinder(r2=r-knobble_r, r1=r-knobble_r+999,h=999,$fn=n_knobbles);
        }
        translate([0,0,1.5]) nut(3,shaft=true,fudge=1.2,h=999);
    }
}
//thumbwheel();