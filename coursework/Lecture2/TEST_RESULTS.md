# Lecture 2 test evidence

These are local simulations, not vehicle measurements. Parameters, solver settings, timestamps and check tolerances are in [results.toml](results.toml). Status combines solver completion and the checks actually present; see each report for the coverage limits.

| Experiment | Solver | Checks | Evidence |
|---|---|---|---|
| `air_3000` | Success | passed | [CSV](air_3000.csv) · [graph](graphs/air_3000.svg) |
| `air_idle` | Success | passed | [CSV](air_idle.csv) · [graph](graphs/air_idle.svg) |
| `brake_stop` | Success | passed | [CSV](brake_stop.csv) · [graph](graphs/brake_stop.svg) |
| `coast_down` | Success | passed | [CSV](coast_down.csv) · [graph](graphs/coast_down.svg) |
| `dyno_WOT` | Success | passed | [CSV](dyno_WOT.csv) · [graph](graphs/dyno_WOT.svg) |
| `dyno_fuel_cut` | Success | passed | [CSV](dyno_fuel_cut.csv) · [graph](graphs/dyno_fuel_cut.svg) |
| `dyno_step` | Success | passed | [CSV](dyno_step.csv) · [graph](graphs/dyno_step.svg) |
| `existing_manifold` | Success | passed | [CSV](existing_manifold.csv) · [graph](graphs/existing_manifold.svg) |
| `mapped_WLTC` | Success | passed | [CSV](mapped_WLTC.csv) · [graph](graphs/mapped_WLTC.svg) |
| `mapped_WOT` | Success | passed | [CSV](mapped_WOT.csv) · [graph](graphs/mapped_WOT.svg) |
| `student_cruise_130` | Success | passed | [CSV](student_cruise_130.csv) · [graph](graphs/student_cruise_130.svg) |
| `student_cruise_50` | Success | passed | [CSV](student_cruise_50.csv) · [graph](graphs/student_cruise_50.svg) |
| `student_cruise_90` | Success | passed | [CSV](student_cruise_90.csv) · [graph](graphs/student_cruise_90.svg) |

## Recorded numerical results

| Experiment | Quantity (unit in name) | Actual value |
|---|---|---:|
| `brake_stop` | `final_speed_kmh` | 3.1027e-05 |
| `brake_stop` | `fuel_L100km` | 2.6793 |
| `brake_stop` | `CO2_gpkm` | 61.678 |
| `brake_stop` | `time_below_half_kmh_s` | 12.95 |
| `coast_down` | `final_speed_kmh` | 6.116e-05 |
| `coast_down` | `fuel_L100km` | 0.88631 |
| `coast_down` | `CO2_gpkm` | 20.403 |
| `coast_down` | `time_below_half_kmh_s` | 90.55 |
| `dyno_WOT` | `final_torque_Nm` | 148.38 |
| `dyno_WOT` | `final_fuel_gps` | 3.7467 |
| `dyno_WOT` | `final_pressure_kPa` | 99.89 |
| `dyno_fuel_cut` | `final_torque_Nm` | -0.58064 |
| `dyno_fuel_cut` | `final_fuel_gps` | 0.096357 |
| `dyno_fuel_cut` | `final_pressure_kPa` | 32.956 |
| `dyno_step` | `final_torque_Nm` | 41.372 |
| `dyno_step` | `final_fuel_gps` | 1.0227 |
| `dyno_step` | `final_pressure_kPa` | 52.944 |
| `mapped_WLTC` | `fuel_L100km` | 5.218 |
| `mapped_WLTC` | `CO2_gpkm` | 120.12 |
| `mapped_WLTC` | `tracking_band_percent` | 98.317 |
| `mapped_WOT` | `final_speed_kmh` | 205.33 |
| `mapped_WOT` | `time_100kmh_s` | 10.45 |
| `mapped_WOT` | `fuel_L100km` | 17.787 |
| `mapped_WOT` | `CO2_gpkm` | 409.46 |
| `student_cruise_130` | `final_speed_kmh` | 130.18 |
| `student_cruise_130` | `fuel_L100km` | 6.0003 |
| `student_cruise_130` | `CO2_gpkm` | 138.13 |
| `student_cruise_50` | `final_speed_kmh` | 49.987 |
| `student_cruise_50` | `fuel_L100km` | 3.671 |
| `student_cruise_50` | `CO2_gpkm` | 84.508 |
| `student_cruise_90` | `final_speed_kmh` | 89.991 |
| `student_cruise_90` | `fuel_L100km` | 3.9474 |
| `student_cruise_90` | `CO2_gpkm` | 90.87 |
