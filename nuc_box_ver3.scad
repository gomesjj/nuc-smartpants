/////////////////////////////////
//
// A Base for a 3rd Generation Intel NUC base.
// 
// It uses a parameteric lipped
// box model, plugs in the nuc
// dimensions and adds base slits
// and vesa mounting holes
//
// Units: mm
//
// David Johnston. dj@deadhat.com
//
// V1 : Uploaded to Thingiverse Sept 4th, 2015
//
// V2 : Fixes screw channels to hang on to the screw
//    : that comes with the NUC rather than needing
//    : a longer screw.
//
////////////////////////////////

module lipped_box(height, depth, width, thickness, corner_radius, lip_height, lip_thickness, floor_thickness) {
    $fn=100;
    difference() {
        union() {
            // The main box with rounded corners
            translate([corner_radius,corner_radius,0]) {
                minkowski() {
                    cube([width-(corner_radius*2),depth-(corner_radius*2),height-1]);
                    cylinder(r=corner_radius,h=1);
                };
            };
            
            // The lip - an interior box that is skinnier and higher.
            translate([corner_radius,corner_radius,0]) {
                minkowski() {
                    cube([width-(corner_radius*2),depth-(corner_radius*2),height+lip_height-1]);
                    cylinder(r=corner_radius-(thickness-lip_thickness),h=1);
                };
            };
        };
        
        // The hole in the middle
        translate([corner_radius,corner_radius,floor_thickness]) {
            minkowski() {
                cube([(width-(corner_radius*2)),  (depth-(corner_radius*2))  , height]);
                cylinder(r=corner_radius-thickness,h=1);
            };
        };
    };
};

module arrow(arrow_thickness) {
    //  The triangle
    translate([0,0,1]) {
        rotate([180,0,0]) {
            linear_extrude(height = arrow_thickness, center = true, convexity = 10, twist = 0) {
                polygon(points=[[-3,0],[3,0],[0,3]]);
            };
            translate ([-0.5,-9,-1]) {
                cube([1,10,arrow_thickness]);
            };
        };
    };
};
       
module nuc_box(height,model) {
    //if (model==3) { 
        depth=112;
        width=116;
        thickness=4;
        corner_radius=8;
        lip_height=2;
        lip_thickness=1.5;
        floor_thickness=4;
        slit_width=4;
        RJ45_space_from_floor=2;
        RJ45_xpos=30;
        vesa_hole_spacing=85;
        vesa_hole_internal_radius=1.1;
        dimple_spacing=25.6;
        front_dimple_spacing=18;
        front_dimple_start=47.15;
        front_dimple_width=1.5;
        
        screw_post_x_inset=10.1;       // Measured
        screw_post_y_inset=10.25;      // Measured
        screw_post_width_spacing=95;   // From the board spec from intel
        screw_post_depth_spacing=90.5; // From the board spec from intel
    
        screw_post_lower_wall_thickness=1.5;
        screw_post_upper_wall_thickness=1.5;
        screw_post_lower_height=height+4;
        screw_post_extra_height=2; // More tube above the base of the disc.
        screw_post_head_depth=height; // The bottom of the disc the holds the screw head down.
        screw_post_upper_hole_diameter = 5.5; // The hole through which the screw shaft goes. Shaft diameter=5.1mm measured
        screw_post_lower_hole_diameter = 7.7; // The hole into which the screw head drops. Head diameter=6.7mm measured
        
        show_ethernet_port=1;
        show_vesa_holes=0;
        show_slits=1;
        show_screw_posts=1;
    //};
    
    difference () {
        union() {
            lipped_box (height, depth, width, thickness, corner_radius, lip_height, lip_thickness, floor_thickness);
            
            // The solid part of the screw posts
            screw_post_lower_diameter = (screw_post_lower_wall_thickness*2)+screw_post_lower_hole_diameter;
            screw_post_upper_diameter = (screw_post_upper_wall_thickness*2)+screw_post_upper_hole_diameter;
            if (show_screw_posts==1) {
                translate([screw_post_x_inset,  screw_post_y_inset,  0]) {
                    cylinder(r=(screw_post_lower_diameter/2),h=screw_post_lower_height,$fn=100);
                    cylinder(r=(screw_post_upper_diameter/2),h=screw_post_lower_height+screw_post_extra_height,$fn=100);
                };
                translate([screw_post_x_inset+screw_post_width_spacing,  screw_post_y_inset,  0]) {
                    cylinder(r=(screw_post_lower_diameter/2),h=screw_post_lower_height,$fn=100);
                    cylinder(r=(screw_post_upper_diameter/2),h=screw_post_lower_height+screw_post_extra_height,$fn=100); 
                };
                translate([screw_post_x_inset,  screw_post_y_inset+screw_post_depth_spacing,  0]) {
                    cylinder(r=(screw_post_lower_diameter/2),h=screw_post_lower_height,$fn=100);
                    cylinder(r=(screw_post_upper_diameter/2),h=screw_post_lower_height+screw_post_extra_height,$fn=100);
                };
                translate([screw_post_x_inset+screw_post_width_spacing,  screw_post_y_inset+screw_post_depth_spacing,  0]) {
                    cylinder(r=(screw_post_lower_diameter/2),h=screw_post_lower_height,$fn=100);
                    cylinder(r=(screw_post_upper_diameter/2),h=screw_post_lower_height+screw_post_extra_height,$fn=100);
                };
            };
            
            // The solid part of the vesa holes. Made quite thick to hold the mounting screws well
            if (show_vesa_holes==1) {
                // vesa plate mounting hole surround
                translate([((width-vesa_hole_spacing)/2),depth/2,0]) {
                    cylinder (h=12,r=3.5,$fn=100);
                };
                translate([((width+vesa_hole_spacing)/2),depth/2,0]) {
                    cylinder (h=12,r=3.5,$fn=100);
                };
            };
        };
        
        // Everything from here on are subtractions from the solid shapes so far.

        if (show_vesa_holes==1) {
            // vesa plate mounting holes
            translate([((width-vesa_hole_spacing)/2),depth/2,-1]) {
                cylinder (h=12+2+floor_thickness,r=vesa_hole_internal_radius,$fn=100);
            };
            translate([((width+vesa_hole_spacing)/2),depth/2,-1]) {
                cylinder (h=12+2+floor_thickness,r=vesa_hole_internal_radius,$fn=100);
            };
        };
        
        // Slits along the bottom
        if (show_slits==1) {
            for (i=[1:3]) {
                // A slit north of the middle. iterated 8 times
                translate([-1,(depth/2)+(10*i)-(slit_width/2),-1]) {
                    cube([width+2,slit_width,floor_thickness+1.2]);
                };
                // A slit south of the middle. iterated 8 times
                translate([-1,(depth/2)-(10*i)-(slit_width/2),-1]) {
                    cube([width+2,slit_width,floor_thickness+1.2]);
                };
            };
        };
        
        // An arrow on the bottom pointing to the front.
        translate ([width/2,10,-1]) arrow(arrow_thickness=2);
        
        if (show_ethernet_port==1) {
            // Holes for an ethernet connector
            // The RJ45 Hole
            translate([RJ45_xpos,depth-10,floor_thickness+RJ45_space_from_floor]) {
                cube([16.76,20,14.22]);
            };

        };

        // the holes in the screw posts.
        // A wider one for the screw to go down into to
        // be able to reach the nut and a narrower one all
        // the way through for the screw to go through.
        if (show_screw_posts==1) {
            translate([screw_post_x_inset,screw_post_y_inset,-1]) {
                cylinder(r=(screw_post_upper_hole_diameter/2),h=height+screw_post_extra_height+10,$fn=100);
                cylinder(r=(screw_post_lower_hole_diameter/2),h=screw_post_lower_height,$fn=100);
            };
            translate([screw_post_x_inset+screw_post_width_spacing,screw_post_y_inset,-1]) {
                cylinder(r=(screw_post_upper_hole_diameter/2),h=height+screw_post_extra_height+10,$fn=100);
                cylinder(r=(screw_post_lower_hole_diameter/2),h=screw_post_lower_height,$fn=100);
            };
            translate([screw_post_x_inset,screw_post_y_inset+screw_post_depth_spacing,-1]) {
                cylinder(r=(screw_post_upper_hole_diameter/2),h=height+screw_post_extra_height+10,$fn=100);
                cylinder(r=(screw_post_lower_hole_diameter/2),h=screw_post_lower_height,$fn=100);
            };
            translate([screw_post_x_inset+screw_post_width_spacing,screw_post_y_inset+screw_post_depth_spacing,-1]) {
                cylinder(r=(screw_post_upper_hole_diameter/2),h=height+screw_post_extra_height+10,$fn=100);
                cylinder(r=(screw_post_lower_hole_diameter/2),h=screw_post_lower_height,$fn=100);
            };
        };
        
    };
    
};

nuc_box(height=30, model=3);


