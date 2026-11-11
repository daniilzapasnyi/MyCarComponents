# Lecture 3 test evidence

These are local simulations, not vehicle measurements. Parameters, solver settings, timestamps and check tolerances are in [results.toml](results.toml). Status combines solver completion and the checks actually present; see each report for the coverage limits.

| Experiment | Solver | Checks | Evidence |
|---|---|---|---|
| `TCS_both` | Success | passed | [CSV](TCS_both.csv) · [graph](graphs/TCS_both.svg) |
| `TCS_brake` | Success | passed | [CSV](TCS_brake.csv) · [graph](graphs/TCS_brake.svg) |
| `TCS_engine` | Success | passed | [CSV](TCS_engine.csv) · [graph](graphs/TCS_engine.svg) |
| `TCS_off` | Success | passed | [CSV](TCS_off.csv) · [graph](graphs/TCS_off.svg) |
| `gentle_pedal` | Success | passed | [CSV](gentle_pedal.csv) · [graph](graphs/gentle_pedal.svg) |
| `locked_mu0.3` | Success | passed | [CSV](locked_mu0.3.csv) · [graph](graphs/locked_mu0.3.svg) |
| `locked_mu0.5` | Success | passed | [CSV](locked_mu0.5.csv) · [graph](graphs/locked_mu0.5.svg) |
| `locked_mu1.0` | Success | passed | [CSV](locked_mu1.0.csv) · [graph](graphs/locked_mu1.0.svg) |
| `no_lookahead` | Success | passed | [CSV](no_lookahead.csv) · [graph](graphs/no_lookahead.svg) |
| `slip_ABS_mu0.3` | Success | passed | [CSV](slip_ABS_mu0.3.csv) · [graph](graphs/slip_ABS_mu0.3.svg) |
| `slip_ABS_mu0.5` | Success | passed | [CSV](slip_ABS_mu0.5.csv) · [graph](graphs/slip_ABS_mu0.5.svg) |
| `slip_ABS_mu1.0` | Success | passed | [CSV](slip_ABS_mu1.0.csv) · [graph](graphs/slip_ABS_mu1.0.svg) |
| `wheel_ABS_mu0.3` | Success | passed | [CSV](wheel_ABS_mu0.3.csv) · [graph](graphs/wheel_ABS_mu0.3.svg) |
| `wheel_ABS_mu0.5` | Success | passed | [CSV](wheel_ABS_mu0.5.csv) · [graph](graphs/wheel_ABS_mu0.5.svg) |
| `wheel_ABS_mu1.0` | Success | passed | [CSV](wheel_ABS_mu1.0.csv) · [graph](graphs/wheel_ABS_mu1.0.svg) |

## Recorded numerical results

| Experiment | Quantity (unit in name) | Actual value |
|---|---|---:|
| `gentle_pedal` | `braking_distance_m` | 35.954 |
| `locked_mu0.3` | `braking_distance_m` | 136.74 |
| `locked_mu0.5` | `braking_distance_m` | 85.057 |
| `locked_mu1.0` | `braking_distance_m` | 43.705 |
| `no_lookahead` | `braking_distance_m` | 53.351 |
| `slip_ABS_mu0.3` | `braking_distance_m` | 106.05 |
| `slip_ABS_mu0.5` | `braking_distance_m` | 64.603 |
| `slip_ABS_mu1.0` | `braking_distance_m` | 34.213 |
| `wheel_ABS_mu0.3` | `braking_distance_m` | 130.56 |
| `wheel_ABS_mu0.5` | `braking_distance_m` | 78.009 |
| `wheel_ABS_mu1.0` | `braking_distance_m` | 38.517 |
