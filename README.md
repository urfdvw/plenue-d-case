# Plenue D TPU case

One-piece soft case for the Cowon Plenue D (53.1 x 77.2 x 14.9 mm), printed in TPU.

- `plenue_d_tpu.scad`: parametric model
- `stl/plenue_d_tpu.stl`: exported case
- `plenue_d_three_view.png`: player dimensions reverse-engineered from photos, used for the model

## Design

- 2 mm wall on every face except the screen.
- Front lip stands 1 mm above the glass and leans 0.5 mm inward to hold the player.
- Keys are part of the case. On the right side, the wall thins to 1 mm above and below the key band, recessed from the outside with smooth ramps. Slits perpendicular to the screen split the band into five keys: vol +, vol -, play, next, prev. A small bump inside presses each key.
- The power key is a pad between two slits, with a pocket for the knob and a raised dome outside.
- Headphone and USB openings are larger than the ports. The microSD slot is covered.
- Every edge is rounded, except the openings and slits.

## Printing

Print back face down. No supports needed. Use 0.2 mm layers and a slow speed suitable for TPU.

## Check before printing

Positions come from photos (about +-0.5 to 1 mm). The USB port was not visible in the photos; it is assumed centered on the bottom edge (`usb_x`, `usb_z`). If the keys feel pressed all the time, reduce `key_nub`.
