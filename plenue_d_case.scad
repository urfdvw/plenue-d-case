// Cowon Plenue D case, two shells (back + front) held by 4x M2 screws,
// with separate captured button caps. Designed for PLA FDM printing.
//
// The outer frame is rotated against the player (early Astell&Kern style)
// and its four edges bulge outward as arcs. Cable openings run straight along
// the player's axes; button guides run perpendicular to the outer frame.
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
// Frame coordinates (x', y') are the same axes rotated by `tilt` about the
// device center.
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
power_x = ((dev.x - 6.2) + 41.8) / 2;   // 44.45
power_z = ((dev.z - 5.1) + 5.2) / 2;    // 7.55

// 3.5 mm headphone jack, top edge. MEASURED.
jack_x = ((dev.x - 39.5) + 8.2) / 2;    // 11.0
jack_z = ((dev.z - 2.7) + 6.7) / 2;     // 9.5

// Micro USB, bottom edge. VERIFY position.
usb_x = dev.x / 2;
usb_z = dev.z / 2;

// Side keys on the right edge, one guide each: [y center, width]. VERIFY.
// At 9 mm spacing the guides sit 9 * cos(tilt) apart, which limits the width.
side_keys = [
    [62.0, 6.0],   // vol +
    [53.0, 6.0],   // vol -
    [37.0, 6.0],   // prev
    [28.0, 6.0],   // play / pause
    [19.0, 6.0],   // next
];
side_key_z = dev.z / 2;     // VERIFY
side_key_h = 5.0;           // cap height along z

// ---------------------------------------------------------------- case
fit     = 0.3;    // clearance between device and cavity, per side
plate   = 1.6;    // front / back plate
split_z = 7.5;    // seam height in device z; every edge opening straddles it

// Outer frame
tilt      = 20;    // frame rotation against the player, counter-clockwise from the front
frame_off = -1.0;  // frame chords relative to the rectangle that touches the cavity corners
bulge     = 4.5;   // how far each edge arcs out past its chord
corner_r  = 1.5;   // rounding of the four frame corners

// Screen window: insets from the device edges [left, right, bottom, top]. VERIFY.
window_inset = [3.0, 3.0, 3.0, 3.0];
window_r     = 2.0;

jack_open_d = 8.5;          // fits slim straight and L-shaped plugs
usb_open    = [12.0, 7.5];  // x, z; room for the plug overmold
usb_open_r  = 1.5;

// M2 screws: inserted from the back, threading into the front shell.
screw_inset    = 4.5;   // from the frame corners, along both frame axes
screw_tr_x     = 19.0;  // top-right screw moved left (x') to clear the power key guide
screw_clear_d  = 2.4;
screw_pilot_d  = 1.7;   // self-tapping into PLA
screw_head_d   = 4.2;
screw_head_h   = 1.6;
screw_len      = 12;    // M2 x 12

// Button caps: plungers sliding in guides perpendicular to the frame.
btn_clr     = 0.25;   // plunger to guide, per side
flange      = 0.7;    // flange overhang on each side of the plunger (in plane)
flange_t    = 0.9;    // minimum flange thickness along the guide
btn_travel  = 0.5;    // free play the pocket allows outward
btn_proud   = 1.0;    // plunger sticking out past the frame
power_cap_w = 11.0;
power_cap_h = 6.0;
power_nub   = [5.0, 4.2];   // width, height; reaches into the recessed ring
power_nub_l = 1.0;          // VERIFY: depth of the recess around the power key

// ---------------------------------------------------------------- derived
cav_min = [-fit, -fit, -fit];
cav_max = dev + [fit, fit, fit];
cav_size = cav_max - cav_min;
out_z0 = cav_min.z - plate;
out_z1 = cav_max.z + plate;
cen = [dev.x / 2, dev.y / 2];

frame_w = cav_size.x * cos(tilt) + cav_size.y * sin(tilt) + 2 * frame_off;
frame_h = cav_size.x * sin(tilt) + cav_size.y * cos(tilt) + 2 * frame_off;

function rot(a, p) = [p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a)];
function to_dev(p) = cen + rot(tilt, p);   // frame coordinates -> device coordinates

u_top   = rot(tilt, [0, 1]);
u_right = rot(tilt, [1, 0]);

screw_frame = [
    [-(frame_w / 2 - screw_inset),  frame_h / 2 - screw_inset],
    [screw_tr_x,                    frame_h / 2 - screw_inset],
    [ frame_w / 2 - screw_inset,  -(frame_h / 2 - screw_inset)],
    [-(frame_w / 2 - screw_inset), -(frame_h / 2 - screw_inset)],
];
screw_pos = [for (p = screw_frame) to_dev(p)];

// Keys: [anchor on the cavity wall, guide axis, device outward normal,
//        plunger width, plunger height, z center, nub [w, h], nub length]
keys = concat(
    [[[power_x, cav_max.y], u_top, [0, 1], power_cap_w, power_cap_h, power_z,
      power_nub, power_nub_l]],
    [for (k = side_keys)
        [[cav_max.x, k[0]], u_right, [1, 0], k[1], side_key_h, side_key_z, undef, 0]]
);

echo(str("Frame chords: ", frame_w, " x ", frame_h, " mm, rotated ", tilt, " deg"));
echo(str("Shell heights: ", split_z - out_z0, " / ", out_z1 - split_z));
echo(str("Screw thread engagement in front shell: ",
         screw_len - (split_z - out_z0 - screw_head_h)));

// ---------------------------------------------------------------- helpers
module rrect(p0, p1, r) {
    hull() for (x = [p0.x + r, p1.x - r], y = [p0.y + r, p1.y - r])
        translate([x, y]) circle(r = r);
}

module centered_rrect(size, r) {
    rrect(-size / 2, size / 2, min(r, min(size.x, size.y) / 2 - eps));
}

// Frame outline in frame coordinates: intersection of four large disks, one per arc.
module frame_shape() {
    function arc_r(l) = (l * l / 4 + bulge * bulge) / (2 * bulge);
    rw = arc_r(frame_w);
    rh = arc_r(frame_h);
    offset(r = corner_r) offset(r = -corner_r) intersection() {
        translate([0,  frame_h / 2 + bulge - rw]) circle(r = rw, $fn = 720);
        translate([0, -frame_h / 2 - bulge + rw]) circle(r = rw, $fn = 720);
        translate([ frame_w / 2 + bulge - rh, 0]) circle(r = rh, $fn = 720);
        translate([-frame_w / 2 - bulge + rh, 0]) circle(r = rh, $fn = 720);
    }
}

module outline() {
    translate(cen) rotate(tilt) frame_shape();
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
        translate([0, 0, out_z1]) linear_extrude(eps)
            rrect(p0 - [plate, plate], p1 + [plate, plate], window_r + plate);
    }
}

// ---------------------------------------------------------------- keys
// Local 2D frame of a key: origin at the anchor, +x along the guide axis.
function k_anchor(k) = k[0];
function k_axis(k)   = k[1];
function k_phi(k)    = atan2(k[2].y, k[2].x) - atan2(k[1].y, k[1].x);
function k_flange_w(k) = k[3] + 2 * flange;
// Flange outer face, measured along the axis, so its thinnest part is flange_t.
function k_flange_end(k) = flange_t + k_flange_w(k) / 2 * abs(tan(k_phi(k)));

module key_local(k) {
    translate(k_anchor(k)) rotate(atan2(k_axis(k).y, k_axis(k).x)) children();
}

// Everything outside the player's side, shifted outward by `d`.
module outside_side(k, d = 0) {
    rotate(k_phi(k)) translate([d, -100]) square(200);
}

module key_cut(k) {
    w = k[3]; h = k[4]; zc = k[5];
    translate([0, 0, zc - h / 2 - btn_clr]) linear_extrude(h + 2 * btn_clr)
        key_local(k) {
            translate([-10, -(w / 2 + btn_clr)]) square([200, w + 2 * btn_clr]);
            translate([-10, -(k_flange_w(k) / 2 + btn_clr)])
                square([10 + k_flange_end(k) + btn_travel, k_flange_w(k) + 2 * btn_clr]);
        }
}

module key_cap(k) {
    w = k[3]; h = k[4]; zc = k[5]; nub = k[6]; nub_l = k[7];
    translate([0, 0, zc - h / 2]) linear_extrude(h) intersection() {
        offset(delta = btn_proud) outline();
        key_local(k) intersection() {
            outside_side(k);
            union() {
                translate([-10, -w / 2]) square([200, w]);
                translate([-10, -k_flange_w(k) / 2]) square([10 + k_flange_end(k), k_flange_w(k)]);
            }
        }
    }
    if (nub != undef)
        translate([0, 0, zc - nub[1] / 2]) linear_extrude(nub[1]) key_local(k) intersection() {
            outside_side(k, -nub_l);
            translate([-10, -nub[0] / 2]) square([10 + 1, nub[0]]);
        }
}

// ---------------------------------------------------------------- shells
module edge_cuts() {
    // headphone jack, straight out of the top of the player
    translate([jack_x, cav_max.y - 1, jack_z]) rotate([-90, 0, 0])
        cylinder(d = jack_open_d, h = 40);
    // micro USB, straight out of the bottom
    translate([usb_x, cav_min.y + 1, usb_z]) rotate([90, 0, 0])
        linear_extrude(40) centered_rrect(usb_open, usb_open_r);
    for (k = keys) key_cut(k);
}

module screw_cuts() {
    for (p = screw_pos) translate(p) {
        // clearance + head counterbore in the back shell
        translate([0, 0, out_z0 - 1]) cylinder(d = screw_clear_d, h = split_z - out_z0 + 1);
        translate([0, 0, out_z0 - 1]) cylinder(d = screw_head_d, h = screw_head_h + 1);
        // pilot in the front shell, stops 0.8 mm short of the front face
        translate([0, 0, split_z - eps]) cylinder(d = screw_pilot_d, h = out_z1 - 0.8 - split_z);
    }
}

module shell() {
    difference() {
        translate([0, 0, out_z0]) linear_extrude(out_z1 - out_z0) outline();
        cavity();
        screen_window();
        edge_cuts();
        screw_cuts();
    }
}

module back_shell() {
    intersection() {
        shell();
        translate([-100, -100, out_z0 - 1]) cube([300, 300, split_z - out_z0 + 1]);
    }
}

module front_shell() {
    intersection() {
        shell();
        translate([-100, -100, split_z]) cube([300, 300, out_z1 - split_z + 1]);
    }
}

// ---------------------------------------------------------------- output
module device_ghost() {
    %linear_extrude(dev.z) rrect([0, 0], [dev.x, dev.y], dev_r);
}

if (part == "assembly") {
    device_ghost();
    color("SteelBlue") back_shell();
    color("LightSteelBlue", 0.6) front_shell();
    color("Orange") for (k = keys) key_cap(k);
} else if (part == "back") {
    // prints back face down
    translate([0, 0, -out_z0]) back_shell();
} else if (part == "front") {
    // prints screen face down
    translate([0, 0, out_z1]) rotate([180, 0, 0]) front_shell();
} else if (part == "buttons") {
    // every cap prints lying flat, as it sits in the case
    for (i = [0 : len(keys) - 1]) let (k = keys[i], nub_h = k[6] == undef ? 0 : k[6][1])
        translate([0, i * 16, -(k[5] - max(k[4], nub_h) / 2)])
            rotate(-atan2(k_axis(k).y, k_axis(k).x))
                translate(-k_anchor(k)) key_cap(k);
}
