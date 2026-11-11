# Lecture 2 – Engine Maps and Fuel Consumption

## What we did

In this lecture, we worked with an engine model in Julia and Dyad Studio. The main goal was to understand how the engine works at different RPMs and loads, and how this affects fuel consumption.

First, we looked at four engine maps:

- **Torque map** – shows how much torque the engine produces.
- **Fuel flow map** – shows how much fuel the engine uses per second.
- **BSFC map** – helps us find where the engine uses fuel most efficiently.
- **Lambda map** – shows how the air and fuel mixture changes depending on the engine conditions.

We plotted these maps to see the differences between low and high engine loads.

## Testing different speeds

After looking at the engine maps, we used the `MappedCarCruise` model to test fuel consumption at three speeds: **50, 90 and 130 km/h**.

For each test, we ran the simulation for 60 seconds.

At first, the car did not keep the speed we wanted. For example, when we started at 50 km/h using the pedal setting from the 90 km/h test, the car accelerated to almost 82 km/h.

We then changed the accelerator pedal value and ran the simulation again. We repeated this until the car stayed close to the target speed.

We did the same thing for 130 km/h, where the car initially slowed down because the engine was not producing enough power.

## Our results

| Speed | Pedal value | Fuel consumption |
|---|---:|---:|
| 50 km/h | 0.0486 | 3.668 L/100 km |
| 90 km/h | 0.0916 | 3.947 L/100 km |
| 130 km/h | 0.1742 | 6.001 L/100 km |

We calculated fuel consumption using the engine fuel map and the distance travelled during each simulation. We assumed a gasoline density of 0.745 kg/L.

The results are estimates from the model, not measurements from a real car.

## What we noticed

The difference between 50 and 90 km/h was quite small. Fuel consumption increased by only about 8%.

However, at 130 km/h, the car used much more fuel. Compared with 90 km/h, consumption increased by about 52%.

This makes sense because air resistance becomes much stronger as speed increases. The engine needs to produce more power to keep the car moving at higher speeds.

We also noticed that the engine operated at different RPMs and manifold pressures depending on the speed.

## Conclusion

This exercise helped me understand how engine maps can be used to estimate fuel consumption.

I also learned that changing the initial vehicle speed does not automatically mean the car will maintain that speed. The accelerator pedal must be adjusted to balance the forces acting on the car.

Our results show that driving faster, especially at highway speeds, can noticeably increase fuel consumption.

The simulations were not perfectly steady from the beginning because we kept some initial engine settings from the 90 km/h model. However, the final speeds were close to the targets, and the results were useful for comparing the three driving conditions.

All graphs are saved in the `graphs` folder, including the engine maps, individual cruise simulations and the final fuel consumption comparison.

## Validation supplement — 10 November 2026

The text and results above are my earlier work. They have been kept. I have now added the missing student components and tested them against the official [mapped-engine build guide](https://dr14-make.github.io/16ESPD/handson/lecture-02/).

### What I built

I connected my existing `MyManifold` to the supplied throttle and cylinder-airflow models. My map engine uses this air path, the torque/fuel tables, fuel-cut logic and a CO₂ gain of 3.09 kg per kg of fuel. I added the dynamometer, mapped car with CVT and launch clutch, road brake, and a WLTC bench using my Lecture 1 controller. The original simple Engine and cruise analyses stay unchanged. [SOURCES.md](../SOURCES.md) credits the supplied build examples.

### How I tested it

I ran the synthetic manifold test, real air-path tests at idle and 3000 rpm, a small pedal step, full throttle, fuel cut and recovery, full-throttle acceleration, the three cruise speeds, coast-down, braking and the full 1800 s WLTC. I also checked the map tables numerically. All results use the project environment and the installed Dyad 3.5 runtime. The exact solver settings and outcomes are in [TEST_RESULTS.md](TEST_RESULTS.md).

### Results I obtained

| Cruise speed | Earlier estimate | New student-car simulation | Calculated CO₂ |
|---:|---:|---:|---:|
| 50 km/h | 3.668 L/100 km | 3.671 L/100 km | 84.51 g/km |
| 90 km/h | 3.947 L/100 km | 3.947 L/100 km | 90.87 g/km |
| 130 km/h | 6.001 L/100 km | 6.000 L/100 km | 138.13 g/km |

The new cruise tests use speed-consistent initial engine rpm and manifold pressure. The small changes from the earlier estimates are expected from the changed starting conditions. They agree with the guide's rounded CVT values, 3.7, 3.9 and 6.0 L/100 km. Fuel is integrated in kg and divided by simulated distance, using 0.745 kg/L. CO₂ is calculated from fuel mass using the course factor; it is not measured emissions.

The idle manifold settles at 37.27 kPa after the small throttle step, against 37.3 kPa in the guide. At wide-open throttle and 3000 rpm it reaches 99.89 kPa. The original synthetic manifold test also passes its analytical pressure-rise check.

The full WLTC uses 5.218 L/100 km and gives 120.12 g CO₂/km. It is inside the specified ±2 km/h, ±1 s band for 98.32% of the run, above the required 95%. The phase consumptions are 6.297, 5.135, 4.589 and 5.406 L/100 km. These match the guide's rounded values. The guide quotes about 98.5% band coverage; sampling and the exact tested controller implementation give a small difference here.

### What the new graphs show

[Air path](graphs/air_idle.svg) shows the manifold filling. [Fuel-cut dyno](graphs/dyno_fuel_cut.svg) shows fuel disappearing after pedal release and returning near idle. [Coast-down](graphs/coast_down.svg) and [brake stop](graphs/brake_stop.svg) show different rates of speed loss while the engine returns to idle. [WLTC](graphs/mapped_WLTC.svg) shows the complete target, actual speed, control effort, fuel and distance totals. The original PNG maps and cruise plots are still in the folder.

### What I learned and limitations

The same road speed can use different fuel with different transmission ratios. The fixed-gear map estimates are about 3.3, 4.6 and 7.0 L/100 km; they should not be confused with the CVT results. Manifold pressure links the throttle to torque and fuel, and the brake stop should not stall the engine once the clutch opens.

These are warm-engine simulations with a lossless CVT and simplified road load. They are not a cold-start certification test. Similarity to the Mazda2's quoted 5.3 L/100 km is useful context, but does not validate a real car: the map data and test conditions differ. The original simple manifold bench alone was not a complete air-path validation; the integrated tests above provide that missing check. No screenshots or real-car measurements have been invented.
