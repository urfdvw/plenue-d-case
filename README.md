# Plenue D case

OpenSCAD case for the Cowon Plenue D (53.3 x 77.3 x 15.0 mm), printable in PLA on an FDM printer.

The outer frame is rotated 10 degrees against the player, in the style of early Astell&Kern players, and its four edges arc outward. Each corner of the player sits close to one frame edge. The four M2 screws sit in the gaps between the player and the frame corners. The headphone and USB openings run straight along the player's axes. The button plungers slide in guides perpendicular to the frame.

- `plenue_d_case.scad`: parametric model. Set `part` to `back`, `front`, `buttons` or `assembly`.
- `stl/`: exported parts (`back.stl`, `front.stl`, `buttons.stl`).

## Parts and printing

- Back shell: print back face down, no supports.
- Front shell: print screen face down, no supports.
- Buttons: one power plunger and five side plungers. They print lying flat, no supports.
- 0.2 mm layers, 3 perimeters, 20 % infill.

## Assembly

1. Drop the plungers, flange inward, into the guides of the back shell.
2. Put the player in, screen up, top edge (jack + power key) toward the jack opening.
3. Put the front shell on top.
4. Drive 4x M2 x 12 screws from the back. They self-tap into the front shell (1.7 mm pilot).

The microSD slot is covered on purpose. Open the case to swap cards.

## Main shape parameters

- `tilt`: frame rotation
- `bulge`: how far each edge arcs out
- `frame_off`: grows or shrinks the frame
- `corner_r`: corner rounding
- `screw_inset`, `screw_tr`, `screw_bl`: screw positions. The top-right and bottom-left screws are placed by hand and need retuning when `tilt` changes.

## Check before printing

The body size, power key and jack positions are caliper measurements. The following are estimates. Measure them on the player and update the parameters if needed:

- `side_keys`, `side_key_z`: positions of the five side keys on the right edge
- `usb_x`, `usb_z`: micro USB position
- `window_inset`: screen window border
- `dev_r`: body corner radius
- `power_nub_l`: depth of the recess around the power key
- z direction: `z = 0` is the back face and `z = 15` is the screen face. If the jack and power measurements were taken from the screen side, swap them with `dev.z - value`.
