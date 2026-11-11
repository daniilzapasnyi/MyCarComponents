# Run with Julia +dyad-3.5.0 --project=. --startup-file=no --pkgimages=no.
# ARGS are lecture numbers (default: all); --case=ID restricts to one experiment.
using MyCarComponents, VehicleSystemsComponents, DyadInterface, TOML, Dates, GR
using DyadInterface: TransientAnalysisSpec, run_analysis, symbolic_container, ODEAlg, OptimizationLevel
const ROOT = normpath(joinpath(@__DIR__, ".."))
const SELECTED = Set(parse.(Int, filter(x -> all(isdigit, x), ARGS)))
const CASE = something(findfirst(startswith("--case="), ARGS), 0)
const CASE_ID = CASE == 0 ? "" : split(ARGS[CASE], "="; limit=2)[2]
const CASES_ARG = findfirst(startswith("--cases="),ARGS)
const CASES = CASES_ARG === nothing ? Set{String}() : Set(split(split(ARGS[CASES_ARG],"=";limit=2)[2],','))
const L4 = MyCarComponents.Lecture4
const JOURNAL = joinpath(ROOT, "coursework", "validation.log")
function logline(s)
    println(s); flush(stdout)
    open(JOURNAL, "a") do io; println(io, Dates.now(Dates.UTC), " UTC | ", s); end
end
lookup(m, path) = foldl(getproperty, Symbol.(split(path, '.')); init=m)
at(r, x, ts) = Float64.(r.sol(ts; idxs=x).u)
lastval(r, m, path) = Float64(r.sol(r.sol.t[end]; idxs=lookup(m,path)))
function compare!(d, name, actual, expected, tolerance)
    d[name] = actual
    d[name * "_reference"] = expected
    d[name * "_tolerance"] = tolerance
    d[name * "_pass"] = abs(actual - expected) <= tolerance
end
function require!(d, name, condition)
    d[name * "_pass"] = Bool(condition)
end
function savecsv(file, ts, values)
    labels = collect(keys(values))
    open(file, "w") do io
        println(io, join(["time_s"; labels], ','))
        for i in eachindex(ts)
            println(io, join([ts[i]; [values[k][i] for k in labels]], ','))
        end
    end
end
include("plot_helpers.jl")
function sim(lecture, id, constructor; stop, kwargs=(;), overrides=Dict{String,Any}(),
             paths=Pair{String,String}[], evaluate=(r,m,t,v,d)->nothing, dt=0.05,
             alg=ODEAlg.Rodas5P(), dtmax=0.05, abstol=1e-7, reltol=1e-7)
    @nospecialize constructor
    (!isempty(SELECTED) && !(lecture in SELECTED)) && return
    (!isempty(CASE_ID) && CASE_ID != id) && return
    (!isempty(CASES) && !(id in CASES)) && return
    dir=joinpath(ROOT,"coursework","Lecture$lecture")
    file=joinpath(dir,"results.toml")
    results=isfile(file) ? TOML.parsefile(file) : Dict{String,Any}()
    d=Dict{String,Any}("timestamp_utc"=>string(Dates.now(Dates.UTC)), "stop_requested_s"=>stop,
        "solver"=>string(alg), "abstol"=>abstol,"reltol"=>reltol,"dtmax_s"=>dtmax,
        "parameters"=>Dict(string(k)=>string(v) for (k,v) in pairs(kwargs)),
        "nested_overrides"=>Dict(k=>string(v) for (k,v) in overrides))
    logline("START L$lecture $id")
    try
        model=constructor(;name=:model, __overrides=overrides, kwargs...)
        elapsed=@elapsed r=run_analysis(TransientAnalysisSpec(;name=Symbol(id), model,
            stop, alg, dtmax, abstol, reltol, optimize=OptimizationLevel.None(), progress=false))
        d["runtime_s"]=elapsed; d["retcode"]=string(r.sol.retcode); d["stop_actual_s"]=r.sol.t[end]
        d["simulation_pass"]=string(r.sol.retcode)=="Success" && abs(r.sol.t[end]-stop)<1e-6
        d["simulation_pass"] || error("Incomplete solve: $(r.sol.retcode), t=$(r.sol.t[end])")
        m=symbolic_container(r); ts=collect(range(0,stop;length=ceil(Int,stop/dt)+1))
        values=Dict(label=>at(r,lookup(m,path),ts) for (label,path) in paths)
        # Clocked analyses can have duplicate t=0 solver entries, for which dense interpolation
        # returns NaN. Evaluate the right-hand limit, not an estimated/copied value.
        for (label,path) in paths
            y=values[label]
            if !isfinite(y[1]) && all(isfinite,y[2:end])
                y[1]=Float64(r.sol(1e-9;idxs=lookup(m,path)))
                d["initial_dense_output_note"]="Exact t=0 dense output was nonfinite; initial plotted sample is solver output at t=1e-9 s."
            end
        end
        require!(d,"finite_signals",all(all(isfinite,y) for y in Base.values(values)))
        evaluate(r,m,ts,values,d)
        savecsv(joinpath(dir,"$(id).csv"),ts,values)
        if !isempty(values)
            try
                saveplot(joinpath(dir,"graphs","$(id).svg"), "Lecture $lecture: "*replace(id,"_"=>" "), ts,values)
                d["plot_status"]="exported"
            catch e
                d["plot_status"]="failed: "*sprint(showerror,e)
            end
        end
        d["status"]=all(v for (k,v) in d if endswith(k,"_pass")) ? "passed" : "reference_or_physics_check_failed"
        logline("DONE L$lecture $id: $(d["status"]) in $(round(elapsed;digits=2)) s")
    catch e
        d["status"]="failed"; d["error"]=sprint(showerror,e)
        trace=sprint(showerror,e,catch_backtrace())
        d["error_trace"]=first(trace,min(length(trace),6000))
        logline("FAIL L$lecture $id: "*first(d["error"],min(length(d["error"]),500)))
    end
    # Read again after the solve so separate lecture jobs cannot overwrite newer entries.
    results=isfile(file) ? TOML.parsefile(file) : Dict{String,Any}()
    results[id]=d
    open(file,"w") do io; TOML.print(io,results; sorted=true); end
    GC.gc()
end
function cruise_eval(r,m,t,v,d)
    y=v["speed_kmh"]; d["final_speed_kmh"]=y[end]; d["peak_speed_kmh"]=maximum(y)
    d["command_min_Nm"],d["command_max_Nm"]=extrema(v["torque_Nm"])
end
function fuel_eval(r,m,t,v,d)
    distance=lastval(r,m,"car.body.mass.s")
    fuel=sum(diff(t).*(v["fuel_kgps"][1:end-1]+v["fuel_kgps"][2:end])./2)
    d["distance_m"]=distance; d["fuel_kg"]=fuel
    d["fuel_L100km"]=fuel/0.745/distance*1e5
    d["CO2_gpkm"]=fuel*3.09*1e6/distance
    d["final_speed_kmh"]=v["speed_kmh"][end]
    require!(d,"fuel_nonnegative",minimum(v["fuel_kgps"])>=-1e-9)
end

logline("Julia $(VERSION); project $(Base.active_project()); Dyad 3.5 coursework validation")
if isempty(SELECTED) || 4 in SELECTED
for (id,kw) in [("machine_350V",(;)),("machine_200V",(V=200.0,rpm_start=1500.0,rpm_end=2100.0))]
    sim(4,id,L4.DCMachineDyno;stop=12,kwargs=kw,dt=0.02,
        paths=["current_A"=>"machine.i","shaft_torque_Nm"=>"machine.tau","speed_radps"=>"machine.w","copper_loss_W"=>"machine.P_cu"])
end
for (id,kw) in [("converter_350V",(;)),("converter_300V",(V=300.0,)),("converter_150A",(I_ref=150.0,)),("converter_braking",(I_ref=-500.0,))]
    sim(4,id,L4.ConverterDyno;stop=102,kwargs=kw,dt=0.1,
        paths=["current_A"=>"converter.i_out","field_fraction"=>"converter.field","duty_fraction"=>"converter.d","shaft_torque_Nm"=>"machine.tau","input_W"=>"converter.P_in","output_W"=>"converter.P_out","loss_W"=>"converter.P_loss"],
        evaluate=(r,m,t,v,d)->begin require!(d,"converter_energy",maximum(abs.(v["input_W"].-v["output_W"].-v["loss_W"]))<0.1);d["current_max_A"]=maximum(v["current_A"]);end)
end
for (id,current,soc) in [("battery_100A",100.0,0.4625),("battery_charge",-20.0,0.9875),("battery_330A",330.0,-0.54375)]
    sim(4,id,L4.BatteryDischarge;stop=1860,kwargs=(I_load=current,),dt=1.0,dtmax=1.0,
        paths=["voltage_V"=>"battery.v","current_A"=>"battery.i","SoC_fraction"=>"battery.SoC"],
        evaluate=(r,m,t,v,d)->compare!(d,"final_SoC",v["SoC_fraction"][end],soc,0.002))
end
function ev_eval(r,m,t,v,d)
    d["max_speed_error_kmh"]=maximum(abs.(v["target_kmh"].-v["speed_kmh"]))
    require!(d,"tracking",d["max_speed_error_kmh"]<2)
    d["final_SoC"]=v["SoC_fraction"][end]
    d["distance_m"]=lastval(r,m,"car.bus.x")
    require!(d,"SoC_window",minimum(v["SoC_fraction"])>=0 && maximum(v["SoC_fraction"])<=1)
    voltage=at(r,m.drive.battery.v,t); power=voltage.*v["battery_A"]
    d["Wh_per_km"]=sum(diff(t).*(power[1:end-1].+power[2:end])./2)/d["distance_m"]/3.6
    if hasproperty(m,:E_cells)
        scale=d["distance_m"]*3.6
        for p in ["E_cells","E_dc","E_R0","E_aux","E_conv","E_motor","E_road","E_tire","E_brake"]
            d[p*"_Whpkm"]=lastval(r,m,p)/scale
        end
        initial_kinetic=Float64(r.sol(0;idxs=m.E_kin))
        residual=lastval(r,m,"E_cells")-sum(lastval(r,m,p) for p in ["E_R0","E_aux","E_conv","E_motor","E_road","E_tire","E_brake"])-(lastval(r,m,"E_kin")-initial_kinetic)
        d["energy_residual_Whpkm"]=residual/scale
        require!(d,"energy_balance",abs(residual/scale)<0.01)
        extra_aux=(Float64(r.sol.ps[m.P_aux])-300)*1800/d["distance_m"]/3.6
        compare!(d,"terminal_consumption_Whpkm",lastval(r,m,"E_dc")/scale,131.2+extra_aux,1.0)
    end
    if hasproperty(m,:E_shaft_out) && hasproperty(m,:E_dc_in)
        d["recovery_percent"]=100lastval(r,m,"E_dc_in")/lastval(r,m,"E_shaft_out")
    end
end
for (id,ctor,kw) in [("BEV_WLTC",L4.BEVWLTC,(;)),("regen_WLTC",L4.BEVRegenWLTC,(;)),("regen_15kW",L4.BEVRegenWLTC,(P_charge=15e3,)),("energy_bill",L4.BEVEnergyBill,(;)),("energy_aux500W",L4.BEVEnergyBill,(P_aux=500.0,))]
    sim(4,id,ctor;stop=1800,kwargs=kw,dt=0.1,dtmax=1.0,
        paths=["target_kmh"=>"trace.y","speed_kmh"=>"kmh.y","SoC_fraction"=>"drive.SoC","battery_A"=>"drive.battery.i"],
        evaluate=ev_eval)
end
for (id,ctor,kw,stop) in [("hard_stop_regen",L4.BEVHardStop,(;),6),("hard_stop_friction",L4.BEVHardStop,(P_charge=0.0,),6),("lowgrip_regen",L4.BEVLowGripStop,(;),12)]
    sim(4,id,ctor;stop,kwargs=kw,dt=0.002,dtmax=0.005,abstol=1e-6,reltol=1e-6,
        paths=["speed_mps"=>"motion.vx","front_slip"=>"slips.kappa_fl","rear_slip"=>"slips.kappa_rl"],
        evaluate=(r,m,t,v,d)->begin
            speed=v["speed_mps"];i=findfirst((t.>0.5).&(speed.<0.5));i===nothing && error("Stop threshold not reached")
            d["braking_distance_m"]=Float64(r.sol(t[i];idxs=m.car.bus.x)-r.sol(0.5;idxs=m.car.bus.x))
            d["stop_time_after_pedal_s"]=t[i]-0.5
            mask=speed.>3; d["minimum_front_slip_above3mps"]=minimum(v["front_slip"][mask]);require!(d,"no_reverse_wheel",d["minimum_front_slip_above3mps"]> -1)
            interval_energy(path)=Float64(r.sol(t[i];idxs=lookup(m,path))-r.sol(0.5;idxs=lookup(m,path)))/1000
            d["recovered_shaft_kJ"]=interval_energy("E_shaft_in")
            d["friction_brake_kJ"]=interval_energy("E_brake")
            d["battery_recovery_kJ"]=interval_energy("E_dc_in")
            d["gross_motor_braking_percent"]=100d["recovered_shaft_kJ"]/(d["recovered_shaft_kJ"]+d["friction_brake_kJ"])
        end)
end
end
