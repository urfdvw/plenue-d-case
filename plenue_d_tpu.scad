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

jack_x = 11.0;               // top edge
jack_z = dev.z - 5.4;        // 5.4 mm from the screen face

// Micro USB, bottom edge: estimated by eye from a photo of the bottom end. Roughly
// centered across the width, closer to the back than to the screen. VERIFY.
usb_x = dev.x / 2;
usb_z = 6.0;

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
lip_blend_h  = 3.0;          // outer side curves in over this height below the lip top
lip_blend_in = 1.2;          // ... and ends this far in, tangent to the lip top
lip_ri = 0.6;                // rounding of the inner lip edge
cav_r  = 1.0;                // rounding inside the back edges

jack_open = 8.0;             // diameter, original hole is ~4.9
usb_open  = [12.0, 9.0];     // x, z; tall to cover the uncertain port height
usb_open_r = 2.0;

// Integrated keys. Along each key band the wall folds into an S: on both sides of
// the band (screen up: above and below) an outer groove and an inner groove,
// offset from each other, leave a 1 mm wall that steps out and back in with
// smooth ramps. Slits perpendicular to the screen separate the keys.
groove_d   = 1.0;            // groove depth; wall in the fold = wall - groove_d
slit_w     = 0.6;
key_nub    = 0.3;            // VERIFY: inner bump over each side key

// [ramp, flat] of the grooves
side_groove  = [1.0, 0.7];

// Power key: same band and fold as the side keys, between two slits. The whole
// pad is raised outward to clear the knob, which stands 1.2 mm proud.
power_pad_w = 14.0;          // slit to slit
power_raise = 1.3;           // knob height + 0.1

// Front cover over the metal top cap (3.4 mm band at the top of the front face).
cap_len = 3.4;

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
// quarter round on the back edge, straight side, smooth curve into the lip top.
outer_prof = concat(
    arc([back_r, -wall + back_r], back_r, 270, 180),
    // quarter ellipse: leaves the side vertically, meets the lip top horizontally
    [for (i = [0 : 16]) let (t = 90 * i / 16)
        [lip_blend_in * (1 - cos(t)), top_z - lip_blend_h + lip_blend_h * sin(t)]]
);

// Cavity profile, inset measured from the cavity outline (negative grows).
// Below the glass it follows the player; above, the opening (front_plan) leaves
// the metal top cap covered.
cav_prof = concat(
    arc([cav_r, cav_r], cav_r, 270, 180),
    [[0, dev.z + fit]]
);
lip_prof = concat(
    [[0, dev.z + fit - eps]],
    [[lip_in, top_z - lip_ri]],
    arc([lip_in - lip_ri, top_z - lip_ri], lip_ri, 0, 90),
    [[lip_in - lip_ri - 1.5, top_z + 1]]
);

module outer() {
    sweep(outer_prof) offset(r = wall) cav_plan();
}

module front_plan() { rrect(cav0, [cav1.x, dev.y - cap_len], dev_r + fit); }

module cavity() {
    sweep(cav_prof) cav_plan();
    sweep(lip_prof) front_plan();
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

module slit(face, u, v0, v1, extra = 0) {
    key_frame(face) translate([u - slit_w / 2, v0, -1 - extra]) cube([slit_w, v1 - v0, wall + 2 + extra]);
}

// The raised pad ends where the outer groove floor starts; its ramp back to the
// normal wall then replaces the outer groove's own ramp, so no ridge forms.
function raise_half() = key_h / 2 + 2 * side_groove[0] + side_groove[1];
raise_ramp = side_groove[0];

function power_box(hs) = [power_x - power_pad_w / 2, power_x + power_pad_w / 2,
                          power_z - hs, power_z + hs];

// Raised power pad: the wall between the slits moves outward by power_raise.
module power_raise_add(hs) {
    b = power_box(hs);
    key_frame("top") plateau(b[0], b[1], b[2], b[3], raise_ramp, power_raise, 0, -1, 0.5);
}

module power_raise_cut(hs) {
    b = power_box(hs);
    key_frame("top") plateau(b[0], b[1], b[2], b[3], raise_ramp, power_raise, wall, -1, 1);
}

module key_cuts() {
    // right side
    u0 = from_top(key_track[1]);
    u1 = from_top(key_track[0]);
    key_frame("right") s_fold(u0, u1, key_z, key_h / 2, side_groove);
    hs = fold_half(key_h / 2, side_groove);
    for (d = key_split) slit("right", from_top(d), key_z - hs - 0.2, key_z + hs + 0.2);
    // power key on the top edge: a side key on the raised pad
    b = power_box(hs);
    power_raise_cut(raise_half());
    key_frame("top") translate([0, 0, -power_raise])
        s_fold(b[0], b[1], power_z, key_h / 2, side_groove);
    for (u = [b[0], b[1]]) slit("top", u, b[2] - 0.2, b[3] + 0.2, power_raise);
}

module key_nubs() {
    if (key_nub > 0) for (d = key_ctr)
        translate([cav1.x, from_top(d), key_z]) resize([2 * key_nub, 3.0, 2.0]) sphere(1);
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
        union() { outer(); power_raise_add(raise_half()); }
        cavity();
        key_cuts();
        openings();
    }
    key_nubs();
}

// prints back down
translate([0, 0, wall]) case();
