using MyCarComponents, VehicleSystemsComponents, DyadInterface, TOML

function finish(run, stop, reference, tolerance)
    string(run.sol.retcode) == "Success" || error("Solver returned $(run.sol.retcode) at $(run.sol.t[end]) s")
    isapprox(run.sol.t[end], stop; atol=1e-6) || error("Solver stopped at $(run.sol.t[end]) s, expected $stop s")
    distance = VehicleSystemsComponents.Vehicle.braking_distance(run)
    return Dict("distance_m" => distance, "reference_m" => reference,
                "tolerance_m" => tolerance, "pass" => abs(distance - reference) <= tolerance,
                "stop_s" => stop)
end

results = Dict{String,Any}()
student = MyCarComponents.Lecture3.ABSStopWheelOnlyTransient
library = VehicleSystemsComponents.Vehicle.ABSBrakeTransient
pedal = MyCarComponents.Lecture3.PedalStopTransient
slip = MyCarComponents.Lecture3.ABSStopTransient
results["student_pedal_api"] = finish(pedal(; road_mu=1.0, pedal=0.3, stop=10.0, progress=false), 10.0, 36.0, 0.3)
results["student_slip_api"] = finish(slip(; road_mu=1.0, T_p=0.0, stop=10.0, progress=false), 10.0, 53.4, 0.3)
println("Pedal and slip analysis keyword checks finished"); flush(stdout)
for (id, mu, stop, reference) in (("student_snow_low_estimate", 0.3, 25.0, 130.9),
                                   ("student_dry_low_estimate", 1.0, 15.0, 106.3))
    run = student(; road_mu=mu, a_ref=2.4, stop, alg=ODEAlg.Tsit5(), dtmax=0.001,
                  abstol=1e-6, reltol=1e-6, progress=false)
    results[id] = finish(run, stop, reference, 0.3)
    println(id, " ", results[id]); flush(stdout)
end

for (id, mu, a_ref, reference) in (("library_dry", 1.0, 8.0, 38.7),
                                    ("library_wet", 0.5, 8.0, 83.2),
                                    ("library_snow", 0.3, 8.0, 141.3),
                                    ("library_snow_low_estimate", 0.3, 2.4, 128.4))
    stop = 1.5 + 1.5 * 25 / min(0.7 * mu * 9.81, a_ref)
    run = library(; road_mu=mu, a_ref, stop, progress=false)
    results[id] = finish(run, stop, reference, 0.3)
    println(id, " ", results[id]); flush(stdout)
end

open(only(ARGS), "w") do io
    TOML.print(io, results; sorted=true)
end
all(row -> row["pass"], values(results)) || error("At least one ABS distance missed the guide checkpoint")
