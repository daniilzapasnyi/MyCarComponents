# Lecture 3 — brakes and ABS

## What I built

I connected a pedal, booster, tandem master cylinder, front/rear brake lines and hydraulic calipers to a braked wheel and my existing body model. I added slip ABS, a wheel-speed estimator and three-phase wheel-speed ABS, plus the optional brake/engine TCS cases. The equations and wiring follow the official [brake and ABS guide](https://dr14-make.github.io/16ESPD/lecture/lecture-03/).

## How I tested it

I started at 25 m/s, applied the pedal at 0.5 s, and tested pedal settings 0.3 and 0.6. I compared locked wheels and both ABS controllers on road multipliers 1.0, 0.5 and 0.3. The course helper counts distance from pedal application until speed reaches 0.5 m/s. Low-friction runs have longer horizons to finish the stop.

## What results I obtained

| Road multiplier | Locked, pedal 0.6 | Slip ABS | Wheel-speed ABS |
|---:|---:|---:|---:|
| 1.0 | 43.705 m | 34.213 m | 38.517 m |
| 0.5 | 85.057 m | 64.603 m | 78.009 m |
| 0.3 | 136.745 m | 106.053 m | 130.560 m |

These agree with the guide's rounded values within 0.1 m. Pedal 0.3 stops the dry-road car in 35.954 m, shorter than locking the wheel with a harder push. Without look-ahead the slip controller takes 53.351 m, longer than the locked case.

The library's 5 ms wheel-speed ECU stopped in 38.70 m on dry road, 83.19 m on wet road and 141.27 m on snow, against 38.7, 83.2 and 141.3 m in the guide. Reducing `a_ref` to 2.4 m/s² reduced the library ECU's snow stop to 128.44 m. My wheel-speed controller stopped in 130.95 m on snow and 106.32 m on dry road at the same setting. The low estimate barely changes the snow stop and causes premature release on dry road. See [check results](abs_reference_results.toml) and [reproduction script](../../scripts/check_abs_reference.jl).

Analytical constant-friction bounds are about 31.9 m at peak dry grip and 45.5 m sliding; at multiplier 0.3 they are 106.2 and 151.7 m. These are estimates, excluding aerodynamic and rolling assistance.

## What the graphs show

[Locked wheel](graphs/locked_mu1.0.svg), [slip ABS](graphs/slip_ABS_mu1.0.svg) and [wheel-speed ABS](graphs/wheel_ABS_mu1.0.svg) show speed, slip and hydraulic pressure. ABS releases and rebuilds pressure instead of keeping the wheel locked. The estimator-based controller has less information and gives longer stops. The TCS traces and all checks are in [TEST_RESULTS.md](TEST_RESULTS.md).

## What I learned

More brake demand does not always mean a shorter stop. Pressure lag matters: reacting only to current slip can release too late. Estimating car speed from a slipping wheel introduces another error, especially when road friction changes.

## Known limitations

This is a lumped longitudinal model with idealized booster and tire behavior. It does not predict real-car handling on split friction. Pressure signals are in pascals; dividing by 100000 gives bar.

The first wheel-speed ABS attempt used Rodas5P and hit MaxIters. The reference analysis specifies Tsit5 with a 1 ms maximum step. With those settings all three stops complete and pass. The failed attempt remains in the journal. Screenshots and submission are deferred.
