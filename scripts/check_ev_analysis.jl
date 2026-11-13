using MyCarComponents, DyadInterface, TOML

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
regen = EV.BEVRegenWLTCTransient(P_charge=15e3, progress=false)
results["limited_charge_recovered_energy_J"] = check(regen, 1800, "E_dc_in", x -> 1e6 < x < 4e6)
aux = EV.BEVEnergyBillTransient(P_aux=500.0, progress=false)
energy = check(aux, 1800, "E_dc", x -> 1e7 < x < 1.3e7)
distance = last_value(aux, "car.bus.x")
results["energy_bill_500W_Whpkm"] = energy / 3.6 / distance
@assert isapprox(results["energy_bill_500W_Whpkm"], 135.537; atol=0.15)

open(only(ARGS), "w") do io
    TOML.print(io, results; sorted=true)
end
