// Cowon Plenue D soft case, one piece, printed in TPU.
// Wraps every face except the screen; the front lip stands 1 mm proud of the
// glass and leans 0.5 mm inward. Keys are part of the case, separated by slits.
//
//   openscad -o plenue_d_tpu.stl plenue_d_tpu.scad
//
// Device coordinate system:
//   x: width,     0 = left edge,   53.1 = right edge (keys)   seen from the screen side
//   y: length,    0 = bottom edge, 77.2 = top edge (jack + power)
//   z: thickness, 0 = back face,   14.9 = screen face
//
// All device features come from the three-view reverse-engineered from photos
// (about +-0.5..1 mm). USB position was not visible in the photos: VERIFY.

$fn = 64;
eps = 0.01;

// ---------------------------------------------------------------- device
dev   = [53.1, 77.2, 14.9];
dev_r = 1.0;                 // plan-view corner radius

power_x     = 44.5;          // top edge
power_z     = dev.z / 2;
power_knob  = 6.0;           // knob diameter
power_proud = 1.2;           // knob height above the top face
power_ring  = 13.0;

jack_x = 11.0;               // top edge
jack_z = dev.z - 5.4;        // 5.4 mm from the screen face

usb_x = dev.x / 2;           // bottom edge, VERIFY
usb_z = dev.z / 2;

// Right edge, measured from the top edge.
key_track = [14.3, 67.1];    // whole key group
key_split = [13.8, 24.2, 35.25, 46.7, 57.4, 67.6];   // slit positions, from the top
// press points: vol +, vol -, play, next, prev (rocker halves and play)
key_ctr   = [19.25, 29.2, 41.05, 52.55, 62.25];
key_z     = dev.z / 2;
key_h     = 3.2;

// ---------------------------------------------------------------- case
fit   = 0.1;                 // per side; TPU stretches over the player
wall  = 2.0;
lip_h = 1.0;                 // lip height above the screen
lip_in = 0.5;                // how far the lip leans over the screen edge
back_r = 2.0;                // rounding of the back edges
lip_r  = 0.8;                // rounding of the outer lip edge
lip_ri = 0.6;                // rounding of the inner lip edge
cav_r  = 1.0;                // rounding inside the back edges

jack_open = 8.0;             // diameter, original hole is ~4.9
usb_open  = [12.0, 7.5];     // x, z
usb_open_r = 2.0;

// Integrated keys on the right side: above and below the key band (screen up)
// the wall thins to 1 mm, recessed from the outside with smooth ramps.
thin_wall  = 1.0;
ramp       = 1.2;            // length of each smooth transition
thin_w     = 1.0;            // flat 1 mm stretch on each side of the key band
slit_w     = 0.6;
slit_z     = [2.0, 12.9];    // slit extent in z (perpendicular to the screen)
key_nub    = 0.3;            // VERIFY: inner bump over each key

// Power key: integrated pad between two slits, with a pocket for the knob.
power_pad_w = 15.0;          // slit to slit
power_bump  = [10.0, 1.0];   // outer bump: diameter, height

// ---------------------------------------------------------------- derived
cav0 = [-fit, -fit];
cav1 = [dev.x + fit, dev.y + fit];
top_z = dev.z + lip_h;
outer_x1 = cav1.x + wall;
outer_y1 = cav1.y + wall;

module rrect(p0, p1, r) {
    hull() for (x = [p0.x + r, p1.x - r], y = [p0.y + r, p1.y - r])
        translate([x, y]) circle(r = r);
}

module cav_plan()   { rrect(cav0, cav1, dev_r + fit); }

// Stack of thin slabs following a profile [[inset, z], ...]; each pair of
// neighbouring slabs is hulled, so the profile may be non-convex.
module sweep(profile) {
    for (i = [0 : len(profile) - 2]) hull() for (p = [profile[i], profile[i + 1]])
        translate([0, 0, p[1]]) linear_extrude(eps) offset(r = -p[0]) children();
}

function arc(c, r, a0, a1, n = 8) = [for (i = [0 : n]) let (a = a0 + (a1 - a0) * i / n)
    [c[0] + r * cos(a), c[1] + r * sin(a)]];

// Outer profile, inset measured from the cavity outline grown by `wall`:
// quarter round on the back edge, straight side, lip leaning in with a round top.
outer_prof = concat(
    arc([back_r, -wall + back_r], back_r, 270, 180),
    [[0, dev.z]],
    arc([lip_in + lip_r - 0.3, top_z - lip_r], lip_r, 180, 90)
);

// Cavity profile, inset measured from the cavity outline (negative grows).
cav_prof = concat(
    arc([cav_r, cav_r], cav_r, 270, 180),
    [[0, dev.z + fit]],
    [[lip_in, top_z - lip_ri]],
    arc([lip_in - lip_ri, top_z - lip_ri], lip_ri, 0, 90),
    [[lip_in - lip_ri - 1.5, top_z + 1]]
);

module outer() {
    sweep(outer_prof) offset(r = wall) cav_plan();
}

module cavity() {
    sweep(cav_prof) cav_plan();
}

// ---------------------------------------------------------------- right-side keys
// 2D drawing in the (y, z) plane placed on a plane x = const, extruded +x.
module on_yz(x, h = eps) {
    translate([x, 0, 0]) rotate([90, 0, 90]) linear_extrude(h) children();
}

function from_top(d) = dev.y - d;

// One recessed band: flat floor `wall - thin_wall` deep over [z0, z1],
// rising with a cosine ramp to the surface over `ramp` on every side.
module recess_band(z0, z1) {
    y0 = from_top(key_track[1]);
    y1 = from_top(key_track[0]);
    depth = wall - thin_wall;
    n = 8;
    lv = [for (i = [0 : n]) let (u = i / n) [depth * (1 - cos(180 * u)) / 2, ramp * (1 - u)]];
    module level(l, dx) on_yz(outer_x1 - l[0] + dx)
        rrect([y0 - l[1], z0 - l[1]], [y1 + l[1], z1 + l[1]], 0.5 + l[1] / 2);
    level(lv[0], 0);
    hull() { level(lv[0], 0); level(lv[0], 1); }
    for (i = [0 : n - 1]) hull() { level(lv[i], 0); level(lv[i + 1], 0); }
}

module key_cuts() {
    half = key_h / 2;
    recess_band(key_z - half - ramp - thin_w, key_z - half - ramp);
    recess_band(key_z + half + ramp, key_z + half + ramp + thin_w);
    for (d = key_split)
        translate([cav1.x - 1, from_top(d) - slit_w / 2, slit_z[0]])
            cube([wall + 3, slit_w, slit_z[1] - slit_z[0]]);
}

module key_nubs() {
    if (key_nub > 0) for (d = key_ctr)
        translate([cav1.x, from_top(d), key_z]) resize([2 * key_nub, 3.0, 2.0]) sphere(1);
}

// ---------------------------------------------------------------- power key
module power_cuts() {
    // knob pocket
    translate([power_x, cav1.y - eps, power_z]) rotate([-90, 0, 0])
        cylinder(d = power_knob + 0.8, h = power_proud + 0.1);
    for (s = [-1, 1])
        translate([power_x + s * power_pad_w / 2 - slit_w / 2, cav1.y - 1, slit_z[0]])
            cube([slit_w, wall + power_bump[1] + 3, slit_z[1] - slit_z[0]]);
}

module power_bump() {
    r = power_bump[0] / 2; h = power_bump[1];
    translate([power_x, outer_y1 - eps, power_z]) rotate([-90, 0, 0]) hull() {
        cylinder(r = r, h = eps);
        rotate_extrude() translate([r - h, 0]) circle(r = h - eps);
        cylinder(r = r - h, h = h);
    }
}

// ---------------------------------------------------------------- openings
module openings() {
    translate([jack_x, cav1.y - 1, jack_z]) rotate([-90, 0, 0])
        cylinder(d = jack_open, h = wall + 3);
    translate([usb_x, cav0.y + 1, usb_z]) rotate([90, 0, 0]) linear_extrude(wall + 3)
        rrect(-usb_open / 2, usb_open / 2, usb_open_r);
}

// ---------------------------------------------------------------- case
module case() {
    difference() {
        union() { outer(); power_bump(); }
        cavity();
        key_cuts();
        power_cuts();
        openings();
    }
    key_nubs();
}

// prints back down
translate([0, 0, wall]) case();
