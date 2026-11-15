using MyCarComponents, DyadInterface, TOML
include("plot_helpers.jl")

const EV = MyCarComponents.Lecture4

function last_value(run, path)
    symbol = foldl(getproperty, Symbol.(split(path, '.')); init=symbolic_container(run))
    return Float64(run.sol(run.sol.t[end]; idxs=symbol))
end

function check(run, stop, signal, predicate)
    @assert string(run.sol.retcode) == "Success"
    @assert isapprox(run.sol.t[end], stop; atol=1e-6)
    value = last_value(run, signal)
    @assert predicate(value) "Unexpected value for $signal: $value"
    println(signal, " = ", value); flush(stdout)
    return value
end

results = Dict{String,Float64}()
results["machine_final_voltage_V"] = check(EV.DCMachineDynoTransient(V=200.0, rpm_start=1500.0, rpm_end=2200.0, progress=false), 12, "machine.v", x -> isapprox(x, 200; atol=1e-6))
results["converter_final_supply_V"] = check(EV.ConverterDynoTransient(V=300.0, I_ref=150.0, stop=2, progress=false), 2, "voltage.y", x -> isapprox(x, 300; atol=1e-6))
results["battery_charging_final_soc"] = check(EV.BatteryDischargeTransient(I_load=-20.0, progress=false), 1860, "battery.SoC", x -> isapprox(x, 0.9875; atol=0.001))

friction = EV.BEVHardStopTransient(P_charge=0.0, dtmax=0.005, abstol=1e-6, reltol=1e-6, progress=false)
results["friction_recovered_battery_J"] = check(friction, 6, "E_dc_in", x -> abs(x) < 0.1)

function hard_stop_signals(run)
    @assert string(run.sol.retcode) == "Success" && isapprox(run.sol.t[end], 6; atol=1e-6)
    model = symbolic_container(run)
    pedal_time = 0.5
    times = collect(pedal_time:0.002:run.sol.t[end])
    speed = Float64.(run.sol(times; idxs=model.motion.vx).u)
    stopped = findfirst(<(0.5), speed)
    isnothing(stopped) && error("The car did not reach the stopping threshold")
    times = times[1:stopped]
    speed = speed[1:stopped]
    trace(signal) = Float64.(run.sol(times; idxs=signal).u)
    distance = run.sol(last(times); idxs=model.car.bus.x) - run.sol(pedal_time; idxs=model.car.bus.x)
    energy(signal) = run.sol(last(times); idxs=signal) - run.sol(pedal_time; idxs=signal)
    return (; distance, times, speed, trace, energy, model)
end

hard_stop = EV.BEVHardStopTransient(dtmax=0.005, abstol=1e-6, reltol=1e-6, progress=false)
stop = hard_stop_signals(hard_stop)
model = stop.model
results["regen_dry_stop_m"] = stop.distance
results["friction_dry_stop_m"] = hard_stop_signals(friction).distance
results["regen_dry_front_min_slip"] = minimum(stop.trace(model.slips.kappa_fl)[stop.speed .> 3])
results["regen_dry_rear_min_slip"] = minimum(stop.trace(model.slips.kappa_rl)[stop.speed .> 3])
shaft_in = stop.energy(model.E_shaft_in)
results["regen_dry_gross_motor_percent"] = 100shaft_in / (shaft_in + stop.energy(model.E_brake))
results["regen_dry_battery_recovery_J"] = stop.energy(model.E_dc_in)
@assert stop.distance <= 1.01 * results["friction_dry_stop_m"]
@assert min(results["regen_dry_front_min_slip"], results["regen_dry_rear_min_slip"]) > -0.2
@assert results["regen_dry_battery_recovery_J"] > 0

if length(ARGS) == 2
    graph_dir = ARGS[2]
    mkpath(graph_dir)
    speed_kmh = 3.6 .* stop.speed
    braking = ["speed_kmh"=>speed_kmh,
               "front_brake_Nm"=>stop.trace(model.car.fl.brake.tau_friction),
               "rear_brake_Nm"=>stop.trace(model.car.rl.brake.tau_friction)]
    brake_panels = [(label, [label=>samples]) for (label, samples) in braking]
    saveplot(joinpath(graph_dir, "dry_hard_stop_brakes.svg"), "Dry hard stop with ABS withdrawal",
             stop.times .- first(stop.times), braking; xlabel="Time after pedal [s]", panels=brake_panels)
    order = sortperm(speed_kmh)
    envelope = ["ABS-limited ceiling"=>stop.trace(model.blend.tau_regen_max)[order],
                "Machine request"=>stop.trace(model.blend.tau_regen)[order]]
    saveplot(joinpath(graph_dir, "dry_hard_stop_envelope.svg"), "Dry hard stop regeneration",
             speed_kmh[order], envelope; xlabel="Vehicle speed [km/h]", panels=[("torque_Nm", envelope)])
end

regen = EV.BEVRegenWLTCTransient(P_charge=15e3, progress=false)
results["limited_charge_recovered_energy_J"] = check(regen, 1800, "E_dc_in", x -> 1e6 < x < 4e6)
aux = EV.BEVEnergyBillTransient(P_aux=500.0, progress=false)
energy = check(aux, 1800, "E_dc", x -> 1e7 < x < 1.3e7)
distance = last_value(aux, "car.bus.x")
results["energy_bill_500W_Whpkm"] = energy / 3.6 / distance
@assert isapprox(results["energy_bill_500W_Whpkm"], 135.537; atol=0.15)

open(first(ARGS), "w") do io
    TOML.print(io, results; sorted=true)
end
