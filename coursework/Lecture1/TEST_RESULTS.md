# Lecture 1 test evidence

These are local simulations, not vehicle measurements. Parameters, solver settings, timestamps and check tolerances are in [results.toml](results.toml). Status combines solver completion and the checks actually present; see each report for the coverage limits.

| Experiment | Solver | Checks | Evidence |
|---|---|---|---|
| `body` | Success | passed | [CSV](body.csv) · [graph](graphs/body.svg) |
| `car_step` | Success | passed | [CSV](car_step.csv) · [graph](graphs/car_step.svg) |
| `cruise_P` | Success | passed | [CSV](cruise_P.csv) · [graph](graphs/cruise_P.svg) |
| `cruise_PI` | Success | passed | [CSV](cruise_PI.csv) · [graph](graphs/cruise_PI.svg) |
| `cruise_PID` | Success | passed | [CSV](cruise_PID.csv) · [graph](graphs/cruise_PID.svg) |
| `engine_step` | Success | passed | [CSV](engine_step.csv) · [graph](graphs/engine_step.svg) |
| `existing_car` | Success | passed | [CSV](existing_car.csv) · [graph](graphs/existing_car.svg) |
| `grade_body` | Success | passed | [CSV](grade_body.csv) · [graph](graphs/grade_body.svg) |
| `grade_car_climb` | Success | passed | [CSV](grade_car_climb.csv) · [graph](graphs/grade_car_climb.svg) |
| `grade_car_flat` | Success | passed | [CSV](grade_car_flat.csv) · [graph](graphs/grade_car_flat.svg) |
| `grade_force` | Success | passed | [CSV](grade_force.csv) · [graph](graphs/grade_force.svg) |
| `hill_clamping` | Success | passed | [CSV](hill_clamping.csv) · [graph](graphs/hill_clamping.svg) |
| `hill_windup` | Success | passed | [CSV](hill_windup.csv) · [graph](graphs/hill_windup.svg) |
| `ice_patch` | Success | passed | [CSV](ice_patch.csv) · [graph](graphs/ice_patch.svg) |
| `ideal_driveline` | Success | passed | [CSV](ideal_driveline.csv) · [graph](graphs/ideal_driveline.svg) |
| `ideal_full_throttle` | Success | passed | [CSV](ideal_full_throttle.csv) · [graph](graphs/ideal_full_throttle.svg) |
| `inertial_full_throttle` | Success | passed | [CSV](inertial_full_throttle.csv) · [graph](graphs/inertial_full_throttle.svg) |
| `limited_cruise_step` | Success | passed | [CSV](limited_cruise_step.csv) · [graph](graphs/limited_cruise_step.svg) |
| `noise_Nd100` | Success | passed | [CSV](noise_Nd100.csv) · [graph](graphs/noise_Nd100.svg) |
| `noise_Nd2` | Success | passed | [CSV](noise_Nd2.csv) · [graph](graphs/noise_Nd2.svg) |
| `noise_kick` | Success | passed | [CSV](noise_kick.csv) · [graph](graphs/noise_kick.svg) |
| `noise_measurement` | Success | passed | [CSV](noise_measurement.csv) · [graph](graphs/noise_measurement.svg) |
| `sampled_001` | Success | passed | [CSV](sampled_001.csv) · [graph](graphs/sampled_001.svg) |
| `sampled_01` | Success | passed | [CSV](sampled_01.csv) · [graph](graphs/sampled_01.svg) |
| `sampled_04` | Success | passed | [CSV](sampled_04.csv) · [graph](graphs/sampled_04.svg) |
| `sampled_1` | Success | passed | [CSV](sampled_1.csv) · [graph](graphs/sampled_1.svg) |
| `sampled_fast_fix` | Success | passed | [CSV](sampled_fast_fix.csv) · [graph](graphs/sampled_fast_fix.svg) |
| `sampled_retuned` | Success | passed | [CSV](sampled_retuned.csv) · [graph](graphs/sampled_retuned.svg) |
| `standing_dry` | Success | passed | [CSV](standing_dry.csv) · [graph](graphs/standing_dry.svg) |
| `standing_slippery` | Success | passed | [CSV](standing_slippery.csv) · [graph](graphs/standing_slippery.svg) |
| `tire_curve` | Success | passed | [CSV](tire_curve.csv) · [graph](graphs/tire_curve.svg) |
| `tuning_delay` | Success | passed | [CSV](tuning_delay.csv) · [graph](graphs/tuning_delay.svg) |
| `tuning_nominal` | Success | passed | [CSV](tuning_nominal.csv) · [graph](graphs/tuning_nominal.svg) |
| `tuning_payload` | Success | passed | [CSV](tuning_payload.csv) · [graph](graphs/tuning_payload.svg) |
| `wheel_unit_dry` | Success | passed | [CSV](wheel_unit_dry.csv) · [graph](graphs/wheel_unit_dry.svg) |
| `wheel_unit_slippery` | Success | passed | [CSV](wheel_unit_slippery.csv) · [graph](graphs/wheel_unit_slippery.svg) |

## Recorded numerical results

| Experiment | Quantity (unit in name) | Actual value |
|---|---|---:|
| `car_step` | `final_speed_kmh` | 109.99 |
| `car_step` | `speed_max_kmh` | 109.99 |
| `cruise_P` | `final_speed_kmh` | 109.29 |
| `cruise_P` | `speed_max_kmh` | 110.5 |
| `cruise_P` | `peak_speed_kmh` | 110.5 |
| `cruise_PI` | `final_speed_kmh` | 110 |
| `cruise_PI` | `speed_max_kmh` | 115.48 |
| `cruise_PI` | `peak_speed_kmh` | 115.48 |
| `cruise_PID` | `final_speed_kmh` | 110 |
| `cruise_PID` | `speed_max_kmh` | 113.98 |
| `cruise_PID` | `peak_speed_kmh` | 113.98 |
| `engine_step` | `final_torque_Nm` | 150 |
| `existing_car` | `final_speed_kmh` | 246.39 |
| `existing_car` | `speed_max_kmh` | 246.39 |
| `grade_car_climb` | `final_speed_kmh` | 116.72 |
| `grade_car_climb` | `speed_max_kmh` | 116.72 |
| `grade_car_flat` | `final_speed_kmh` | 246.39 |
| `grade_car_flat` | `speed_max_kmh` | 246.39 |
| `hill_clamping` | `final_speed_kmh` | 130 |
| `hill_clamping` | `speed_max_kmh` | 130.17 |
| `hill_clamping` | `peak_speed_kmh` | 130.17 |
| `hill_windup` | `final_speed_kmh` | 130 |
| `hill_windup` | `speed_max_kmh` | 179.8 |
| `hill_windup` | `peak_speed_kmh` | 179.8 |
| `ice_patch` | `speed_max_kmh` | 111.85 |
| `ice_patch` | `maximum_wheel_kmh` | 3400.6 |
| `ice_patch` | `maximum_slip` | 38.131 |
| `ideal_full_throttle` | `final_speed_kmh` | 246.39 |
| `ideal_full_throttle` | `speed_max_kmh` | 246.39 |
| `ideal_full_throttle` | `time_100kmh_s` | 23.65 |
| `inertial_full_throttle` | `final_speed_kmh` | 246.39 |
| `inertial_full_throttle` | `speed_max_kmh` | 246.39 |
| `inertial_full_throttle` | `time_100kmh_s` | 23.85 |
| `limited_cruise_step` | `final_speed_kmh` | 110 |
| `limited_cruise_step` | `speed_max_kmh` | 114.43 |
| `noise_Nd100` | `final_speed_kmh` | 110.25 |
| `noise_Nd100` | `speed_max_kmh` | 111.68 |
| `noise_Nd100` | `peak_speed_kmh` | 111.68 |
| `noise_Nd100` | `torque_swing_20to30s_Nm` | 1746.8 |
| `noise_Nd2` | `final_speed_kmh` | 110.32 |
| `noise_Nd2` | `speed_max_kmh` | 111 |
| `noise_Nd2` | `peak_speed_kmh` | 111 |
| `noise_Nd2` | `torque_swing_20to30s_Nm` | 315.58 |
| `noise_kick` | `final_speed_kmh` | 108.94 |
| `noise_kick` | `speed_max_kmh` | 187.05 |
| `noise_kick` | `peak_speed_kmh` | 187.05 |
| `noise_kick` | `torque_swing_20to30s_Nm` | 909.45 |
| `noise_measurement` | `final_speed_kmh` | 110.22 |
| `noise_measurement` | `speed_max_kmh` | 111.04 |
| `noise_measurement` | `peak_speed_kmh` | 111.04 |
| `noise_measurement` | `torque_swing_20to30s_Nm` | 765.7 |
| `sampled_001` | `final_speed_kmh` | 109.97 |
| `sampled_001` | `speed_max_kmh` | 124.18 |
| `sampled_001` | `peak_speed_kmh` | 124.18 |
| `sampled_01` | `final_speed_kmh` | 110.12 |
| `sampled_01` | `speed_max_kmh` | 127.28 |
| `sampled_01` | `peak_speed_kmh` | 127.28 |
| `sampled_04` | `final_speed_kmh` | 98.081 |
| `sampled_04` | `speed_max_kmh` | 139.06 |
| `sampled_04` | `peak_speed_kmh` | 139.06 |
| `sampled_1` | `final_speed_kmh` | 109.4 |
| `sampled_1` | `speed_max_kmh` | 156.97 |
| `sampled_1` | `peak_speed_kmh` | 156.97 |
| `sampled_fast_fix` | `final_speed_kmh` | 110.41 |
| `sampled_fast_fix` | `speed_max_kmh` | 125.47 |
| `sampled_fast_fix` | `peak_speed_kmh` | 125.47 |
| `sampled_retuned` | `final_speed_kmh` | 109.86 |
| `sampled_retuned` | `speed_max_kmh` | 118.83 |
| `sampled_retuned` | `peak_speed_kmh` | 118.83 |
| `standing_dry` | `final_speed_kmh` | 21.076 |
| `standing_dry` | `speed_max_kmh` | 21.076 |
| `standing_slippery` | `final_speed_kmh` | 10.116 |
| `standing_slippery` | `speed_max_kmh` | 10.116 |
| `tuning_delay` | `final_speed_kmh` | 111 |
| `tuning_delay` | `speed_max_kmh` | 129.16 |
| `tuning_delay` | `peak_speed_kmh` | 129.16 |
| `tuning_nominal` | `final_speed_kmh` | 110 |
| `tuning_nominal` | `speed_max_kmh` | 118.46 |
| `tuning_nominal` | `peak_speed_kmh` | 118.46 |
| `tuning_payload` | `final_speed_kmh` | 110 |
| `tuning_payload` | `speed_max_kmh` | 118.67 |
| `tuning_payload` | `peak_speed_kmh` | 118.67 |

`sampled_001`: Exact t=0 dense output was nonfinite; initial plotted sample is solver output at t=1e-9 s.


`sampled_01`: Exact t=0 dense output was nonfinite; initial plotted sample is solver output at t=1e-9 s.


`sampled_04`: Exact t=0 dense output was nonfinite; initial plotted sample is solver output at t=1e-9 s.


`sampled_1`: Exact t=0 dense output was nonfinite; initial plotted sample is solver output at t=1e-9 s.


`sampled_fast_fix`: Exact t=0 dense output was nonfinite; initial plotted sample is solver output at t=1e-9 s.


`sampled_retuned`: Exact t=0 dense output was nonfinite; initial plotted sample is solver output at t=1e-9 s.
