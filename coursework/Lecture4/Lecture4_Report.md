# Lecture 4 — battery-electric vehicle

## What I built

I built a DC-equivalent machine with electrical dynamics, rotor inertia and losses, then connected a converter, field weakening, battery, auxiliaries and reduction gear. I used the supplied planar vehicle for WLTC and braking. My original torque-only ElectricMotor stays unchanged. The components follow the official [EV guide](https://dr14-make.github.io/16ESPD/lecture/lecture-04/), with provenance in [SOURCES.md](../SOURCES.md).

## How I tested it

I tested 350/200 V machine dynos, converter voltage/current limits and generation, battery currents of 100, -20 and 330 A, and full 1800 s WLTC runs. I compared basic regen, a 15 kW charge limit, and 300/500 W auxiliaries. Hard stops check wheel slip as well as distance.

## What results I obtained

The basic EV uses about 131.26 Wh/km at the battery terminals, with maximum speed error 1.634 km/h. SoC falls from 0.9 to about 0.822. The regen blend uses about 131.17 Wh/km; reducing charge power to 15 kW raises this to 134.69 Wh/km.

The integrated energy bill gives 131.239 Wh/km at the terminals and 134.342 Wh/km out of the cells:

| Contribution | Wh/km |
|---|---:|
| Road load | 103.144 |
| Machine losses | 17.607 |
| Auxiliaries | 6.447 |
| Battery resistance | 3.103 |
| Converter | 2.117 |
| Tire slip | 1.802 |
| Friction brakes | 0.121 |

The balance residual is about -0.000000027 Wh/km, numerical error. Increasing auxiliaries to 500 W gives 135.537 Wh/km at the terminals. These match the guide's rounded results.

The battery-terminal figure is 47.25 MJ/100 km. My Lecture 2 WLTC fuel result corresponds to 168.71 MJ/100 km, using 0.745 kg/L and 43.4 MJ/kg. The EV uses about 3.57 times less energy on this cycle. The EV is 1500 kg and that engine car is 1400 kg; this is the guide's comparison, not an identical-mass test. Fuel energy and electricity delivered to the battery also have different upstream production losses, which this model does not include.

Battery SoC ends at 0.4625 for 100 A and 0.9875 when charging at -20 A. At 330 A it goes below zero: the expected demonstration that this simple battery has no empty-pack protection.

The dry stop is 27.0999 m with regeneration and 26.9319 m with zero charge power, a difference of about 0.62%. The low-grip stop is 87.6037 m. Minimum front slip above 3 m/s is -0.126 dry and -0.187 on low grip, so these runs do not reverse the wheels while the car is moving at those speeds.

From pedal application at 0.5 s until the car reaches 0.5 m/s, the regen case absorbs 2.412 kJ at the machine shaft and dissipates 348.850 kJ in friction brakes: only 0.687% gross motor-side share. The battery recovers 2.957 kJ, or 0.821 Wh. These boundary energies also involve stored rotor and electrical energy, so their ratio is not a converter efficiency. The guide's larger shaft total includes the pre-braking part of the test; my stated energy window excludes it. Zero charge power gives zero battery recovery. Useful hard-stop motor participation remains limited, as the guide reports.

## What the graphs show

[Converter envelope](graphs/converter_350V.svg) shows current limiting and field weakening. [Battery discharge](graphs/battery_100A.svg) shows voltage sag and falling SoC. [Energy-bill WLTC](graphs/energy_bill.svg) shows speed and battery current over the full cycle. Hard-stop graphs in [TEST_RESULTS.md](TEST_RESULTS.md) include slip, since distance alone can hide wheel reversal.

## What I learned

Battery energy pays for useful motion and losses. Regeneration helps, but charge limits and low-speed fading send energy to friction brakes. Converter power balance is a useful sign check. Auxiliary loads matter even while stopped.

## Known limitations

This is a DC-equivalent machine and an averaged converter. The battery has fixed open-circuit voltage and no temperature, aging or protection model. The hard-stop regen share is small because ABS withdrawal removes most regeneration; a short stop does not prove useful blending. The current guide documents that limitation too.

Exact braking results, slip checks and any initial-clock interpolation workaround are in [TEST_RESULTS.md](TEST_RESULTS.md). The pinned library is retained. These are simulations, not physical measurements. Personal screenshots remain manual.

The Dyad analyses accept the worksheet overrides directly. A separate check reran the 200 V machine, a 300 V converter case, charging at −20 A, the zero-charge-power hard stop, the 15 kW WLTC and the 500 W auxiliary case through the analysis entry points. The 500 W case gave 135.537 Wh/km. See [analysis results](analysis_results.toml) and the [check script](../../scripts/check_ev_analysis.jl).
