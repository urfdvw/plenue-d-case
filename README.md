# Plenue D TPU case

One-piece soft case for the Cowon Plenue D (53.3 x 77.0 x 14.9 mm; 77.5 with the power knob, 53.7 across the side keys), printed in TPU.

- `plenue_d_tpu.scad`: parametric model
- `stl/plenue_d_tpu.stl`: exported case
- `plenue_d_three_view.png`: player dimensions reverse-engineered from photos, used for the model

## Design

- 2 mm wall on every face except the screen.
- Front lip: the inner face leaves the glass at 45 degrees and reaches 2 mm over the screen edge; the top is a half round of radius 2, so the lip stands 4 mm above the glass. Triangular guards with 5 mm legs cover the four screen corners.
- Keys are part of the case. Above and below each key band (screen up), an inner groove next to the key and an outer groove beyond it, offset from each other, fold the wall into an S with an even 1 mm thickness and smooth ramps. Slits perpendicular to the screen split the right side into five keys: vol +, vol -, play, next, prev. A shallow pocket inside the key band leaves room for the keys, which stand 0.4 mm proud.
- The power key uses the same design as a side key: S fold between two slits. Seen from the front, the case outline steps up 0.6 mm over the power block to clear the knob (0.5 mm proud).
- Headphone and USB openings are larger than the ports and have flat tops with 60 degree sides, so they print as bridges without support. The microSD slot is covered.
- Every edge is rounded, except the openings and slits.

## Printing

Print back face down. No supports needed. Use 0.2 mm layers and a slow speed suitable for TPU.

## Check before printing

Body size and key / knob protrusion are caliper measurements. Feature positions come from photos (about +-0.5 to 1 mm), scaled to the measured body. The USB port is centered across the width (from a photo) with its center 5 mm from the screen face (measured). If the keys feel loose, set `key_nub` to add a small bump inside each key.
