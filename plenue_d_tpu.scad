// Cowon Plenue D soft case, one piece, printed in TPU.
// Wraps every face except the screen. The front lip reaches over the glass edge
// with a 45 degree underside, a short vertical land and a flat top. Keys
// are part of the case, separated by slits. Openings have flat tops so they
// print as bridges, without support.
//
//   openscad -o plenue_d_tpu.stl plenue_d_tpu.scad
//
// Device coordinate system:
//   x: width,     0 = left edge,   53.3 = right edge (keys)   seen from the screen side
//   y: length,    0 = bottom edge, 77.0 = top edge (jack + power)
//   z: thickness, 0 = back face,   14.9 = screen face
//
// Body size and key / knob protrusion are caliper measurements. Feature positions
// come from the three-view reverse-engineered from photos (about +-0.5..1 mm),
// scaled from its 53.1 x 77.2 body to the measured one.

$fn = 64;
eps = 0.01;

// ---------------------------------------------------------------- device
dev   = [53.3, 77.0, 14.9];  // MEASURED width and length; thickness from the spec
dev_r = 1.0;                 // plan-view corner radius
knob_proud = 0.5;            // MEASURED: 77.5 with the power knob
key_proud  = 0.4;            // MEASURED: 53.7 across the side keys

// Positions read off the three-view are scaled by these to the measured body.
sx = dev.x / 53.1;
sy = dev.y / 77.2;

power_x     = 44.5 * sx;     // top edge
power_z     = dev.z / 2;

jack_x = 11.0 * sx;          // top edge
jack_z = dev.z - 5.4;        // 5.4 mm from the screen face

// Micro USB, bottom edge: centered across the width (photo), center 5 mm from
// the screen face (MEASURED).
usb_x = dev.x / 2;
usb_z = dev.z - 5.0;

// Right edge, measured from the top edge.
key_track = [14.3, 67.1] * sy;    // whole key group
key_split = [13.8, 24.2, 35.25, 46.7, 57.4, 67.6] * sy;   // slit positions, from the top
// press points: vol +, vol -, play, next, prev (rocker halves and play)
key_ctr   = [19.25, 29.2, 41.05, 52.55, 62.25] * sy;
key_z     = dev.z / 2;
key_h     = 3.2;

// ---------------------------------------------------------------- case
fit   = 0.1;                 // per side; TPU stretches over the player
wall  = 2.0;
// Lip cross-section: from the cavity wall at the glass, a 45 degree underside
// reaches lip_over over the screen edge, a vertical land of lip_land rises to
// the flat top, and the outer top edge is rounded with lip_round.
lip_over  = 1.0;
lip_land  = 0.5;
lip_round = 1.5;
back_r = 2.0;                // rounding of the back edges
cav_r  = 1.0;                // rounding inside the back edges

// Openings print as bridges: flat top (toward the screen), sides no steeper
// than 60 degrees from horizontal.
jack_open = 8.0;             // circle diameter, original hole is ~4.9
usb_open  = [12.0, 7.5];     // width at mid height, height; room for the plug overmold

// Integrated keys. Along each key band the wall folds into an S: on both sides of
// the band (screen up: above and below) an outer groove and an inner groove,
// offset from each other, leave a 1 mm wall that steps out and back in with
// smooth ramps. Slits perpendicular to the screen separate the keys.
groove_d   = 1.0;            // groove depth; wall in the fold = wall - groove_d
slit_w     = 0.6;
key_nub    = 0;              // inner bump over each side key (off: keys stand proud)
// Shallow pocket inside the key band so the proud keys are not pressed at rest.
key_relief = key_proud - fit;

// [ramp, flat] of the grooves
side_groove  = [1.0, 0.7];

// Power key: same band and fold as the side keys, between two slits. Seen from
// the front, the case outline steps up over the power block (from the block
// seam to the right edge) to clear the knob.
power_pad_w = 14.0;          // slit to slit
power_raise = knob_proud + 0.1;
raise_x0    = 35.2 * sx;     // power block seam, from the three-view


// ---------------------------------------------------------------- derived
cav0 = [-fit, -fit];
cav1 = [dev.x + fit, dev.y + fit];
glass_z = dev.z + fit;       // underside of the lip
lip_top = glass_z + lip_over + lip_land;
outer_x1 = cav1.x + wall;
outer_y1 = cav1.y + wall + power_raise;   // top wall over the power block

module rrect(p0, p1, r) {
    hull() for (x = [p0.x + r, p1.x - r], y = [p0.y + r, p1.y - r])
        translate([x, y]) circle(r = r);
}

// Plan outline of the cavity, stepped up over the power block, inner corner rounded.
module cav_plan() {
    offset(r = -1) offset(r = 1) union() {
        rrect(cav0, cav1, dev_r + fit);
        rrect([raise_x0 - fit, cav0.y], [cav1.x, cav1.y + power_raise], dev_r + fit);
    }
}

module outer_plan() { offset(r = -wall) offset(r = wall) offset(r = wall) cav_plan(); }

// Follows a profile [[inset, z], ...] with a stack of offset slabs no taller than
// sweep_dz, so the plan outline may be non-convex (the power step).
sweep_dz = 0.1;
module sweep(profile) {
    for (i = [0 : len(profile) - 2]) let (a = profile[i], b = profile[i + 1],
            n = a[0] == b[0] ? 1 : max(1, ceil(abs(b[1] - a[1]) / sweep_dz)))
        for (j = [0 : n - 1]) let (z0 = a[1] + (b[1] - a[1]) * j / n,
                                   z1 = a[1] + (b[1] - a[1]) * (j + 1) / n,
                                   ins = a[0] + (b[0] - a[0]) * (j + 0.5) / n)
            if (z1 > z0) translate([0, 0, z0 - eps]) linear_extrude(z1 - z0 + 2 * eps)
                offset(r = -ins) children();
}

function arc(c, r, a0, a1, n = 8) = [for (i = [0 : n]) let (a = a0 + (a1 - a0) * i / n)
    [c[0] + r * cos(a), c[1] + r * sin(a)]];

// Outer profile, inset measured from the cavity outline grown by `wall`:
// quarter round on the back edge, straight side, rounded edge into the lip top.
outer_prof = concat(
    arc([back_r, -wall + back_r], back_r, 270, 180),
    arc([lip_round, lip_top - lip_round], lip_round, 180, 90)
);

// Cavity profile below the glass, inset measured from the cavity outline.
cav_prof = concat(
    arc([cav_r, cav_r], cav_r, 270, 180),
    [[0, glass_z]]
);

// Lip opening, inset measured from the cavity outline: 45 degree underside,
// vertical land, then clear above the flat top.
lip_prof = [
    [0, glass_z - eps],
    [lip_over, glass_z + lip_over],
    [lip_over, lip_top],
    [-wall - 1, lip_top + 1]
];

module outer() {
    sweep(outer_prof) outer_plan();
}

module cavity() {
    sweep(cav_prof) cav_plan();
    sweep(lip_prof) cav_plan();
}

// ---------------------------------------------------------------- integrated keys
function from_top(d) = dev.y - d;

// Local key frame: u along the edge, v = z, w = depth inward from the outer surface.
module key_frame(face) {
    m = face == "right"
        ? [[0, 0, -1, outer_x1], [1, 0, 0, 0], [0, 1, 0, 0]]
        : [[1, 0, 0, 0], [0, 0, -1, outer_y1], [0, 1, 0, 0]];
    multmatrix(m) children();
}

// Smooth plateau in the key frame: flat over [u0, u1] x [v0, v1] at `depth`
// from the surface w = w0 (dir = +1 goes inward, -1 outward), blending back to
// the surface with a cosine ramp of length `r` on every side. `back` extends
// the solid past the surface so it unions/cuts cleanly.
module plateau(u0, u1, v0, v1, r, depth, w0, dir, back) {
    n = 8;
    lv = [for (i = [0 : n]) let (t = i / n) [depth * (1 - cos(180 * t)) / 2, r * (1 - t)]];
    module level(l, dw = 0) translate([0, 0, w0 + dir * l[0] + dw]) linear_extrude(eps)
        rrect([u0 - l[1], v0 - l[1]], [u1 + l[1], v1 + l[1]], 0.3 + l[1] / 2);
    hull() { level(lv[0]); level(lv[0], back); }
    for (i = [0 : n - 1]) hull() { level(lv[i]); level(lv[i + 1]); }
}

// One groove, `groove_d` deep, cut from the outside or from the cavity side.
module groove(u0, u1, v0, v1, r, from_inner) {
    if (from_inner) plateau(u0, u1, v0, v1, r, groove_d, wall, -1, 1);
    else            plateau(u0, u1, v0, v1, r, groove_d, 0, 1, -1);
}

// S fold on both sides of a key band [vc - h, vc + h], along [u0, u1].
// Going away from the band: inner groove, then the outer groove, whose
// ramp down shares the inner groove's ramp up, so the 1 mm wall stays even.
module s_fold(u0, u1, vc, h, g) {
    r = g[0]; f = g[1];
    for (s = [-1, 1]) {
        i = [vc + s * (h + r), vc + s * (h + r + f)];
        o = [vc + s * (h + 2 * r + f), vc + s * (h + 2 * r + 2 * f)];
        groove(u0, u1, min(o), max(o), r, false);
        groove(u0, u1, min(i), max(i), r, true);
    }
}

function fold_half(h, g) = h + 3 * g[0] + 2 * g[1];

module slit(face, u, v0, v1) {
    key_frame(face) translate([u - slit_w / 2, v0, -1]) cube([slit_w, v1 - v0, wall + 2]);
}

function power_box(hs) = [power_x - power_pad_w / 2, power_x + power_pad_w / 2,
                          power_z - hs, power_z + hs];

module key_cuts() {
    // right side
    u0 = from_top(key_track[1]);
    u1 = from_top(key_track[0]);
    key_frame("right") s_fold(u0, u1, key_z, key_h / 2, side_groove);
    if (key_relief > 0) key_frame("right")
        plateau(u0, u1, key_z - key_h / 2, key_z + key_h / 2, side_groove[0],
                key_relief, wall, -1, 1);
    hs = fold_half(key_h / 2, side_groove);
    for (d = key_split) slit("right", from_top(d), key_z - hs - 0.2, key_z + hs + 0.2);
    // power key on the stepped-up top wall, same as a side key
    b = power_box(hs);
    key_frame("top") s_fold(b[0], b[1], power_z, key_h / 2, side_groove);
    for (u = [b[0], b[1]]) slit("top", u, b[2] - 0.2, b[3] + 0.2);
}

module key_nubs() {
    if (key_nub > 0) for (d = key_ctr)
        translate([cav1.x, from_top(d), key_z]) resize([2 * key_nub, 3.0, 2.0]) sphere(1);
}

// ---------------------------------------------------------------- openings
// Round hole with a flat top: 60 degree tangents from the circle up to a flat
// at the top of the circle.
module jack_shape(d) {
    r = d / 2;
    circle(r = r);
    polygon([[-r * cos(30), r / 2], [r * cos(30), r / 2],
             [r * tan(30), r], [-r * tan(30), r]]);
}

// Flat top and bottom; sides are arcs meeting them at 60 degrees.
module usb_shape(size) {
    w = size[0]; h = size[1];
    R = h;                   // arc radius that meets the flats at 60 degrees
    intersection() {
        square([w + 2, h], center = true);
        translate([w / 2 - R, 0]) circle(r = R, $fn = 128);
        translate([-w / 2 + R, 0]) circle(r = R, $fn = 128);
    }
}

// 2D (a, b) drawn in the end wall: a along x, b along z (toward the screen).
module openings() {
    translate([jack_x, outer_y1 + 1, jack_z]) rotate([90, 0, 0])
        linear_extrude(outer_y1 - cav1.y + 3) jack_shape(jack_open);
    translate([usb_x, cav0.y + 1, usb_z]) rotate([90, 0, 0])
        linear_extrude(wall + 3) usb_shape(usb_open);
}

// ---------------------------------------------------------------- case
module case() {
    difference() {
        outer();
        cavity();
        key_cuts();
        openings();
    }
    key_nubs();
}

// prints back down
translate([0, 0, wall]) case();
