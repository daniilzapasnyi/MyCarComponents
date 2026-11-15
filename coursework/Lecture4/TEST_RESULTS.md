# Lecture 4 test evidence

These are local simulations, not vehicle measurements. Parameters, solver settings, timestamps and check tolerances are in [results.toml](results.toml). Status combines solver completion and the checks actually present; see each report for the coverage limits.

| Experiment | Solver | Checks | Evidence |
|---|---|---|---|
| `BEV_WLTC` | Success | passed | [CSV](BEV_WLTC.csv) · [graph](graphs/BEV_WLTC.svg) |
| `battery_100A` | Success | passed | [CSV](battery_100A.csv) · [graph](graphs/battery_100A.svg) |
| `battery_330A` | Success | passed | [CSV](battery_330A.csv) · [graph](graphs/battery_330A.svg) |
| `battery_charge` | Success | passed | [CSV](battery_charge.csv) · [graph](graphs/battery_charge.svg) |
| `converter_150A` | Success | passed | [CSV](converter_150A.csv) · [graph](graphs/converter_150A.svg) |
| `converter_300V` | Success | passed | [CSV](converter_300V.csv) · [graph](graphs/converter_300V.svg) |
| `converter_350V` | Success | passed | [CSV](converter_350V.csv) · [graph](graphs/converter_350V.svg) |
| `converter_braking` | Success | passed | [CSV](converter_braking.csv) · [graph](graphs/converter_braking.svg) |
| `converter_held_10000` | Success | passed | [CSV](converter_held_10000.csv) · [graph](graphs/converter_held_10000.svg) |
| `converter_held_base` | Success | passed | [CSV](converter_held_base.csv) · [graph](graphs/converter_held_base.svg) |
| `energy_aux500W` | Success | passed | [CSV](energy_aux500W.csv) · [graph](graphs/energy_aux500W.svg) |
| `energy_bill` | Success | passed | [CSV](energy_bill.csv) · [graph](graphs/energy_bill.svg) |
| `hard_stop_friction` | Success | passed | [CSV](hard_stop_friction.csv) · [graph](graphs/hard_stop_friction.svg) |
| `hard_stop_regen` | Success | passed | [CSV](hard_stop_regen.csv) · [graph](graphs/hard_stop_regen.svg) |
| `lowgrip_regen` | Success | passed | [CSV](lowgrip_regen.csv) · [graph](graphs/lowgrip_regen.svg) |
| `machine_200V` | Success | passed | [CSV](machine_200V.csv) · [graph](graphs/machine_200V.svg) |
| `machine_350V` | Success | passed | [CSV](machine_350V.csv) · [graph](graphs/machine_350V.svg) |
| `regen_15kW` | Success | passed | [CSV](regen_15kW.csv) · [graph](graphs/regen_15kW.svg) |
| `regen_WLTC` | Success | passed | [CSV](regen_WLTC.csv) · [graph](graphs/regen_WLTC.svg) |

## Recorded numerical results

| Experiment | Quantity (unit in name) | Actual value |
|---|---|---:|
| `BEV_WLTC` | `Wh_per_km` | 131.26 |
| `BEV_WLTC` | `max_speed_error_kmh` | 1.6337 |
| `BEV_WLTC` | `final_SoC` | 0.82186 |
| `battery_100A` | `final_SoC` | 0.4625 |
| `battery_330A` | `final_SoC` | -0.54375 |
| `battery_charge` | `final_SoC` | 0.9875 |
| `converter_held_10000` | `final_torque_Nm` | 103.79 |
| `converter_held_base` | `final_torque_Nm` | 320.02 |
| `energy_aux500W` | `Wh_per_km` | 135.56 |
| `energy_aux500W` | `terminal_consumption_Whpkm` | 135.54 |
| `energy_aux500W` | `energy_residual_Whpkm` | -2.8421e-08 |
| `energy_aux500W` | `max_speed_error_kmh` | 1.6337 |
| `energy_aux500W` | `final_SoC` | 0.81933 |
| `energy_aux500W` | `recovery_percent` | 23.157 |
| `energy_bill` | `Wh_per_km` | 131.26 |
| `energy_bill` | `terminal_consumption_Whpkm` | 131.24 |
| `energy_bill` | `energy_residual_Whpkm` | -2.6761e-08 |
| `energy_bill` | `max_speed_error_kmh` | 1.6337 |
| `energy_bill` | `final_SoC` | 0.82186 |
| `energy_bill` | `recovery_percent` | 23.796 |
| `hard_stop_friction` | `braking_distance_m` | 26.932 |
| `hard_stop_friction` | `minimum_front_slip_above3mps` | -0.12446 |
| `hard_stop_friction` | `recovered_shaft_kJ` | 0.31491 |
| `hard_stop_friction` | `friction_brake_kJ` | 352.71 |
| `hard_stop_friction` | `battery_recovery_kJ` | 0 |
| `hard_stop_friction` | `gross_motor_braking_percent` | 0.089204 |
| `hard_stop_regen` | `braking_distance_m` | 27.1 |
| `hard_stop_regen` | `minimum_front_slip_above3mps` | -0.1257 |
| `hard_stop_regen` | `recovered_shaft_kJ` | 2.4117 |
| `hard_stop_regen` | `friction_brake_kJ` | 348.85 |
| `hard_stop_regen` | `battery_recovery_kJ` | 2.9569 |
| `hard_stop_regen` | `gross_motor_braking_percent` | 0.68658 |
| `lowgrip_regen` | `braking_distance_m` | 87.604 |
| `lowgrip_regen` | `minimum_front_slip_above3mps` | -0.18712 |
| `regen_15kW` | `Wh_per_km` | 134.69 |
| `regen_15kW` | `max_speed_error_kmh` | 1.6309 |
| `regen_15kW` | `final_SoC` | 0.81992 |
| `regen_15kW` | `recovery_percent` | 21.398 |
| `regen_WLTC` | `Wh_per_km` | 131.17 |
| `regen_WLTC` | `max_speed_error_kmh` | 1.6337 |
| `regen_WLTC` | `final_SoC` | 0.82191 |
| `regen_WLTC` | `recovery_percent` | 23.853 |

`hard_stop_friction`: Exact t=0 dense output was nonfinite; initial plotted sample is solver output at t=1e-9 s.


`hard_stop_regen`: Exact t=0 dense output was nonfinite; initial plotted sample is solver output at t=1e-9 s.


`lowgrip_regen`: Exact t=0 dense output was nonfinite; initial plotted sample is solver output at t=1e-9 s.
