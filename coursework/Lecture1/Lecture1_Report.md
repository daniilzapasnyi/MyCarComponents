# Lecture 1 — vehicle model and cruise control

## What I built

I kept my original Engine, Car, Body and Driveline. My original driveline has 2 kg m² of wheel inertia, so I added a separate ideal driveline and the guide's 1 kg m² comparison. I also added road grade, a tire friction curve and a slipping wheel.

My controller has selectable P, PI and filtered PID branches, with speed error in km/h and output in N m. Clamping freezes the integral when the output is limited and the error pushes it further into the limit. It can still unwind when the error changes sign.

I followed the official [car build](https://dr14-make.github.io/16ESPD/handson/lecture-01/) and [controller build](https://dr14-make.github.io/16ESPD/lecture/lecture-01/). The teaching examples are credited in [SOURCES.md](../SOURCES.md).

## How I tested it

I used Julia for Dyad 3.5 in the project environment. I ran component benches, acceleration, a torque step, P/PI/PID, the 10% hill, measurement noise, extra payload, doubled engine delay, dry/slippery launches and the 4–12 s ice patch. The additional runner covers the sampled-controller demo. [TEST_RESULTS.md](TEST_RESULTS.md) links every recorded experiment to its solver status, CSV and graph.

## What results I obtained

These are simulations, not real-car measurements. The original car reaches 246.387 km/h after 300 s. On the 90 to 110 km/h step, P settles at 109.290 km/h. PI removes the error but peaks at 115.482 km/h. PID settles at 110 km/h with a lower peak of 113.977 km/h. These agree with the guide.

The hill test peaks at 179.80 km/h with windup and 130.174 km/h with clamping. Both eventually return to 130 km/h, but their overshoots are very different. After 5 s the dry standing start reaches 21.076 km/h; friction 0.2 gives only 10.116 km/h.

The open-loop torque-step trace gives a static gain of about 2.211 km/h per N m. Reading its 63.2% crossing gives about 65 s, including the engine response, compared with the guide's fitted time constant of 63 s. Those are different estimation methods on a nonlinear response. The separate engine has a specified 0.3 s transport delay and 0.3 s lag; the 0.25 s vehicle trace does not independently resolve both of them accurately.

## What the graphs show

[PID step](graphs/cruise_PID.svg), [hill with clamping](graphs/hill_clamping.svg) and [hill without it](graphs/hill_windup.svg) show how integral action and output limits change the response. [Noise with Nd = 100](graphs/noise_Nd100.svg) shows the derivative amplifying a small measurement disturbance. [Ice patch](graphs/ice_patch.svg) separates wheel speed from car speed when grip is lost.

## What I learned

Integral action removes a steady error, but needs anti-windup. Derivative action can reduce overshoot, but needs filtering and the correct initial state. Extra engine delay can make a tuned controller ring. A cruise controller alone cannot control wheel slip.

## Known limitations

The simple engine has no rev limiter, so wheel speeds on ice become unrealistic. The noise and tuning experiments intentionally lift torque limits to show controller behavior.

The installed discrete PID starts derivative memory at zero. The sampled demo uses its supported InitialOutput initialization with the expected first proportional step, preventing an unrelated derivative spike from the initial 90 km/h measurement. This adjustment is recorded per run. Some sampled analyses return NaN for dense interpolation exactly at the initial clock tick; the first plotted sample then uses the solver's right-hand output at 1 ns, with an explicit note in results.toml.

The code/diagram round trip was checked in Studio 3.5.1 during the diagram repair. Conditional I/D selection and anti-windup are equations in the source, so their full logic must be read in code. Personal screenshots still need to be taken. No submission has been made.
