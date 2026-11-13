using MyCarComponents, DyadInterface, TOML

const Mapped = MyCarComponents.Lecture2

function check(run, stop, path, expected, tolerance)
    @assert string(run.sol.retcode) == "Success"
    @assert isapprox(run.sol.t[end], stop; atol=1e-6)
    signal = foldl(getproperty, Symbol.(split(path, '.')); init=symbolic_container(run))
    value = Float64(run.sol(stop; idxs=signal))
    @assert isapprox(value, expected; atol=tolerance) "Unexpected $path = $value"
    println(path, " = ", value); flush(stdout)
    return value
end

results = Dict{String,Float64}()
wot = Mapped.MapEngineDynoTransient(rpm=3000, pedal_initial=0, pedal_final=1, p_m0=13482.4, progress=false)
results["wot_manifold_Pa"] = check(wot, 3.0, "engine.air.manifold.p", 99890.0, 400)
fuel_cut = Mapped.MapEngineFuelCutDynoTransient(rpm=3000, pedal_initial=1, pedal_final=0, p_m0=99889.9, stop=7, dtmax=0.05, progress=false)
results["fuel_cut_final_manifold_Pa"] = check(fuel_cut, 7.0, "engine.air.manifold.p", 32956.0, 400)
cruise = Mapped.MappedCarCruiseTransient(speed_kmh=50, pedal_cmd=0.04878, rpm0=1992, p_m0=40100, progress=false)
results["cruise_50_final_kmh"] = check(cruise, 60.0, "car.v_kmh", 50.0, 0.5)

open(only(ARGS), "w") do io
    TOML.print(io, results; sorted=true)
end
