# Plenue D TPU case

One-piece soft case for the Cowon Plenue D (53.1 x 77.2 x 14.9 mm), printed in TPU.

- `plenue_d_tpu.scad`: parametric model
- `stl/plenue_d_tpu.stl`: exported case
- `plenue_d_three_view.png`: player dimensions reverse-engineered from photos, used for the model

## Design

- 2 mm wall on every face except the screen.
- Front lip stands 1 mm above the glass and leans 0.5 mm inward to hold the player. The outer side curves smoothly into the lip.
- Keys are part of the case. Above and below each key band (screen up), an inner groove next to the key and an outer groove beyond it, offset from each other, fold the wall into an S with an even 1 mm thickness and smooth ramps. Slits perpendicular to the screen split the right side into five keys: vol +, vol -, play, next, prev. A small bump inside presses each key.
- The power key uses the same design as a side key: S fold between two slits.
- Headphone and USB openings are larger than the ports. The microSD slot is covered.
- Every edge is rounded, except the openings and slits.

## Printing

Print back face down. No supports needed. Use 0.2 mm layers and a slow speed suitable for TPU.

## Check before printing

Positions come from photos (about +-0.5 to 1 mm). The USB position was estimated by eye from a photo of the bottom end: centered across the width, about 6 mm from the back (`usb_x`, `usb_z`). The opening is made tall to cover the uncertainty. If the keys feel pressed all the time, reduce `key_nub`.
