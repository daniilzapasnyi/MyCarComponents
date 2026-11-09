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