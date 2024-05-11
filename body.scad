
// body
body_len_x = 53.3;
body_len_y = 77.3;
body_len_z = 15.0;

// power button
power_ring_len_d = 12.9;
power_ring_len_r = power_ring_len_d / 2;
power_len_d = 5.5;
power_len_r = power_len_d / 2;
power_pos_from_body_z_min = 5.2;
power_pos_from_body_z_max = 5.1;
power_pos_from_body_x_max = 6.2;
power_pos_from_body_x_min = 41.8;

power_center_pos_from_body_x_min = ((body_len_x - power_pos_from_body_x_max) + power_pos_from_body_x_min)/2;
echo("power_center_pos_from_body_x_min");
echo(power_center_pos_from_body_x_min);

power_center_pos_from_body_z_min = ((body_len_z - power_pos_from_body_z_max) + power_pos_from_body_z_min)/2;
echo("power_center_pos_from_body_z_min");
echo(power_center_pos_from_body_z_min);

// 3.5mm jack
jack_pos_from_body_z_max = 2.7;
jack_pos_from_body_z_min = 6.7;
jack_pos_from_body_x_min = 8.2;
jack_pos_from_body_x_max = 39.5;

jack_center_pos_from_body_x_min = ((body_len_x - jack_pos_from_body_x_max) + jack_pos_from_body_x_min)/2;
echo("jack_center_pos_from_body_x_min");
echo(jack_center_pos_from_body_x_min);

jack_center_pos_from_body_z_min = ((body_len_z - jack_pos_from_body_z_max) + jack_pos_from_body_z_min)/2;
echo("jack_center_pos_from_body_z_min");
echo(jack_center_pos_from_body_z_min);

// USB
