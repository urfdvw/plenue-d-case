// Cowon Plenue D case, two shells (back + front) held by 4x M2 screws,
// with separate captured button caps. Designed for PLA FDM printing.
//
// Render one part at a time:
//   openscad -D 'part="back"'    -o back.stl    plenue_d_case.scad
//   openscad -D 'part="front"'   -o front.stl   plenue_d_case.scad
//   openscad -D 'part="buttons"' -o buttons.stl plenue_d_case.scad
// part="assembly" shows everything in place (preview only).
//
// Device coordinate system (all positions below are in this frame):
//   x: width,     0 = left edge,   53.3 = right edge   (seen from the screen side)
//   y: height,    0 = bottom edge, 77.3 = top edge     (top = jack + power key)
//   z: thickness, 0 = back face,   15.0 = screen face
//
// Values marked MEASURED come from a caliper on the real unit.
// Values marked VERIFY are estimates; check them on the player before printing.

part = "assembly"; // [assembly, back, front, buttons]

$fn = 48;
eps = 0.01;

// ---------------------------------------------------------------- device
dev = [53.3, 77.3, 15.0];   // MEASURED (matches Cowon spec 53.3 x 77.3 x 15)
dev_r = 4.0;                // VERIFY: corner radius of the body seen from the front

// Power key, top edge. MEASURED distances from the body edges.
power_d       = 5.5;
power_ring_d  = 12.9;       // recessed ring around the key (along x)
power_x = ((dev.x - 6.2) + 41.8) / 2;   // 44.45
power_z = ((dev.z - 5.1) + 5.2) / 2;    // 7.55

// 3.5 mm headphone jack, top edge. MEASURED.
jack_x = ((dev.x - 39.5) + 8.2) / 2;    // 11.0
jack_z = ((dev.z - 2.7) + 6.7) / 2;     // 9.5

// Micro USB, bottom edge. VERIFY position.
usb_x = dev.x / 2;
usb_z = dev.z / 2;

// Side keys on the right edge: [y center, length along y]. VERIFY all.
side_keys = [
    [62.0, 7.0],   // vol +
    [53.0, 7.0],   // vol -
    [37.0, 7.0],   // prev
    [28.0, 7.0],   // play / pause
    [19.0, 7.0],   // next
];
side_key_z = dev.z / 2;     // VERIFY
side_key_h = 5.0;           // cap height along z

// ---------------------------------------------------------------- case
fit     = 0.3;    // clearance between device and cavity, per side
wall    = 2.4;    // side wall
plate   = 1.6;    // front / back plate
split_z = 7.5;    // seam height in device z; every edge opening straddles it

// Screen window: insets from the device edges [left, right, bottom, top]. VERIFY.
window_inset = [3.0, 3.0, 3.0, 3.0];
window_r     = 2.0;

jack_open_d = 8.5;          // fits most straight and L-shaped plugs
usb_open    = [12.0, 7.5];  // x, z; room for the plug overmold
usb_open_r  = 1.5;

// M2 screws: inserted from the back, threading into the front shell.
screw_off      = 1.8;   // screw axis offset outward from each cavity corner (x and y)
lug_r          = 3.2;
lug_fillet     = 4.0;   // concave blend between the corner lugs and the walls
screw_clear_d  = 2.4;
screw_pilot_d  = 1.7;   // self-tapping into PLA
screw_head_d   = 4.2;
screw_head_h   = 1.6;
screw_len      = 12;    // M2 x 12

// Button caps
btn_clr     = 0.25;   // stem to hole, per side
flange      = 0.9;    // flange overhang around the stem
flange_t    = 0.9;
btn_travel  = 0.5;    // free play the pocket allows outward
btn_proud   = 1.0;    // stem sticking out past the case surface
power_stem  = [11.0, 6.0];   // x, z
power_nub   = [5.0, 4.2];   // x, z; reaches into the recessed ring
power_nub_l = 1.0;          // VERIFY: depth of the recess around the power key

// ---------------------------------------------------------------- derived
cav_min = [-fit, -fit, -fit];
cav_max = dev + [fit, fit, fit];
cav_size = cav_max - cav_min;
out_min = cav_min - [wall, wall, plate];
out_max = cav_max + [wall, wall, plate];
pocket_d = flange_t + btn_travel;

screw_pos = [for (sx = [0, 1], sy = [0, 1])
    [sx ? cav_max.x + screw_off : cav_min.x - screw_off,
     sy ? cav_max.y + screw_off : cav_min.y - screw_off]];

echo(str("Outer size: ", out_max - out_min));
echo(str("Back shell height: ", split_z - out_min.z,
         ", front shell height: ", out_max.z - split_z));
echo(str("Screw thread engagement in front shell: ",
         screw_len - (split_z - out_min.z - screw_head_h)));

// ---------------------------------------------------------------- helpers
module rrect(p0, p1, r) {
    hull() for (x = [p0.x + r, p1.x - r], y = [p0.y + r, p1.y - r])
        translate([x, y]) circle(r = r);
}

// Rounded rectangle in a plane, centered, extruded along +z by h.
module rbox(size, r, h) {
    linear_extrude(h) rrect(-size / 2, size / 2, min(r, min(size.x, size.y) / 2 - eps));
}

module outline() {
    f = lug_fillet;
    offset(r = -f) offset(r = f) union() {
        rrect(out_min, out_max, dev_r + wall);
        for (p = screw_pos) translate(p) circle(r = lug_r);
    }
}

module cavity() {
    translate([0, 0, cav_min.z]) linear_extrude(cav_size.z)
        rrect(cav_min, cav_max, dev_r + fit);
}

module screen_window() {
    p0 = [window_inset[0], window_inset[2]];
    p1 = [dev.x - window_inset[1], dev.y - window_inset[3]];
    // 45 degree chamfer opening toward the outside
    hull() {
        translate([0, 0, cav_max.z - eps]) linear_extrude(eps) rrect(p0, p1, window_r);
        translate([0, 0, out_max.z]) linear_extrude(eps)
            rrect(p0 - [plate, plate], p1 + [plate, plate], window_r + plate);
    }
}

// Openings through a side wall. `at` is a point on the cavity wall, `dir` the
// outward axis: "+x", "+y", "-y".
module through_wall(at, dir) {
    translate(at)
        rotate(dir == "+x" ? [0, 90, 0] : dir == "+y" ? [-90, 0, 0] : [90, 0, 0])
            rotate(dir == "+x" ? [0, 0, 90] : [0, 0, 0])
                children();
}

// Hole plus inner pocket for a flanged button cap; local frame: x/y in the wall
// plane, z pointing outward, z=0 at the cavity wall.
module key_cut(stem) {
    translate([0, 0, -1]) rbox(stem + 2 * [btn_clr, btn_clr], 1.0, wall + 2);
    translate([0, 0, -1]) rbox(stem + 2 * [flange + btn_clr, flange + btn_clr], 1.0, 1 + pocket_d);
}

module edge_cuts() {
    // headphone jack
    translate([jack_x, cav_max.y - 1, jack_z]) rotate([-90, 0, 0])
        cylinder(d = jack_open_d, h = wall + 2);
    // micro USB
    through_wall([usb_x, cav_min.y, usb_z], "-y")
        translate([0, 0, -1]) rbox(usb_open, usb_open_r, wall + 2);
    // power key
    through_wall([power_x, cav_max.y, power_z], "+y") key_cut(power_stem);
    // side keys
    for (k = side_keys)
        through_wall([cav_max.x, k[0], side_key_z], "+x") key_cut([k[1], side_key_h]);
}

module screw_cuts() {
    for (p = screw_pos) translate(p) {
        // clearance + head counterbore in the back shell
        translate([0, 0, out_min.z - 1]) cylinder(d = screw_clear_d, h = split_z - out_min.z + 1);
        translate([0, 0, out_min.z - 1]) cylinder(d = screw_head_d, h = screw_head_h + 1);
        // pilot in the front shell, stops 0.8 mm short of the front face
        translate([0, 0, split_z - eps]) cylinder(d = screw_pilot_d, h = out_max.z - 0.8 - split_z);
    }
}

module shell() {
    difference() {
        translate([0, 0, out_min.z]) linear_extrude(out_max.z - out_min.z) outline();
        cavity();
        screen_window();
        edge_cuts();
        screw_cuts();
    }
}

module back_shell() {
    intersection() {
        shell();
        translate([-50, -50, out_min.z - 1]) cube([200, 200, split_z - out_min.z + 1]);
    }
}

module front_shell() {
    intersection() {
        shell();
        translate([-50, -50, split_z]) cube([200, 200, out_max.z - split_z + 1]);
    }
}

// Button cap in its local frame: z=0 at the cavity wall, +z outward.
module key_cap(stem, nub = undef, nub_l = 0) {
    rbox(stem + 2 * [flange, flange], 1.0, flange_t);
    rbox(stem, 1.0, wall + btn_proud);
    if (nub != undef) translate([0, 0, -nub_l]) rbox(nub, 1.0, nub_l + eps);
}

module power_cap() { key_cap(power_stem, power_nub, power_nub_l); }
module side_cap(k) { key_cap([k[1], side_key_h]); }

// ---------------------------------------------------------------- output
module device_ghost() {
    %linear_extrude(dev.z) rrect([0, 0], [dev.x, dev.y], dev_r);
}

if (part == "assembly") {
    device_ghost();
    color("SteelBlue") back_shell();
    color("LightSteelBlue", 0.6) front_shell();
    color("Orange") {
        through_wall([power_x, cav_max.y, power_z], "+y") power_cap();
        for (k = side_keys)
            through_wall([cav_max.x, k[0], side_key_z], "+x") side_cap(k);
    }
} else if (part == "back") {
    // prints back face down
    translate([0, 0, -out_min.z]) back_shell();
} else if (part == "front") {
    // prints screen face down
    translate([0, 0, out_max.z]) rotate([180, 0, 0]) front_shell();
} else if (part == "buttons") {
    // side caps print flange down; the power cap prints stem down so its nub
    // ends up on top (the 0.9 mm flange ledge prints without support)
    translate([0, 0, wall + btn_proud])
        rotate([180, 0, 0]) power_cap();
    for (i = [0 : len(side_keys) - 1])
        translate([14 + i * (side_keys[i][1] + 2 * flange + 3), 0, 0]) side_cap(side_keys[i]);
}
