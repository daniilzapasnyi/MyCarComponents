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
const L1 = MyCarComponents.Lecture1
const L2 = MyCarComponents.Lecture2
const L3 = MyCarComponents.Lecture3
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
if isempty(SELECTED) || 1 in SELECTED
sim(1,"existing_car",MyCarComponents.CarFullThrottle;stop=300,dt=0.25,
    paths=["speed_kmh"=>"car.v_kmh"], evaluate=(r,m,t,v,d)->compare!(d,"final_speed_kmh",v["speed_kmh"][end],246.39,0.1))
sim(1,"engine_step",L1.EngineStep;stop=3,dt=0.002,
    paths=["torque_Nm"=>"engine.limiter.y","speed_radps"=>"load.w"],
    evaluate=(r,m,t,v,d)->begin compare!(d,"final_torque_Nm",v["torque_Nm"][end],150,0.01);compare!(d,"final_load_speed_radps",v["speed_radps"][end],306,0.5);end)
for (id,ctor,stop,paths) in [
    ("ideal_driveline",L1.TestDriveline,2,["speed_mps"=>"mass.v"]),
    ("body",L1.TestBody,500,["speed_mps"=>"body.mass.v"]),
    ("ideal_full_throttle",L1.CarFullThrottle,300,["speed_kmh"=>"car.v_kmh"]),
    ("inertial_full_throttle",L1.WheeledCarFullThrottle,300,["speed_kmh"=>"car.v_kmh"]),
    ("grade_force",L1.TestGradeForce,2,["force_N"=>"gf.f","speed_mps"=>"mass.v"]),
    ("grade_body",L1.TestGradeBody,10,["speed_mps"=>"body.mass.v"]),
    ("tire_curve",L1.TestTireFrictionCurve,2,["slip_ratio"=>"curve.kappa","friction_coefficient"=>"curve.mu"])]
    sim(1,id,ctor;stop,paths,evaluate=(r,m,t,v,d)->begin
        if id=="ideal_driveline"
            compare!(d,"acceleration_mps2",v["speed_mps"][end]/stop,100*4/0.31/1400,0.001)
        elseif id=="body"
            compare!(d,"final_speed_mps",v["speed_mps"][end],29.78,0.05)
        elseif id in ["ideal_full_throttle","inertial_full_throttle"]
            compare!(d,"final_speed_kmh",v["speed_kmh"][end],246.39,0.1)
        elseif id=="grade_force"
            compare!(d,"grade_force_N",v["force_N"][end],1366.1,0.5)
        elseif id=="grade_body"
            compare!(d,"final_speed_mps",v["speed_mps"][end],10.16,0.03)
        elseif id=="tire_curve"
            for (slip,ref) in [(-1.0,-0.7),(-0.08,-0.85),(0.04,1.0),(1.0,0.7)]
                compare!(d,"mu_at_$slip",Float64(r.sol(slip+1;idxs=m.curve.mu)),ref,0.002)
            end
        end
    end)
end
sim(1,"car_step",L1.CarStepTest;stop=500,dt=0.25,paths=["speed_kmh"=>"plant.v_kmh"],
    evaluate=(r,m,t,v,d)->compare!(d,"final_speed_kmh",v["speed_kmh"][end],110,0.05))
for (id,I,D,expected) in [("cruise_P",false,false,109.3),("cruise_PI",true,false,110),("cruise_PID",true,true,110)]
    sim(1,id,L1.CruiseExperiment;stop=100,kwargs=(with_I=I,with_D=D),
        paths=["speed_kmh"=>"plant.v_kmh","torque_Nm"=>"controller.y"],
        evaluate=(r,m,t,v,d)->begin cruise_eval(r,m,t,v,d);compare!(d,"final_speed_kmh",v["speed_kmh"][end],expected,0.15);end)
end
for aw in (false,true)
    sim(1,aw ? "hill_clamping" : "hill_windup",L1.CruiseExperiment;stop=400,
        kwargs=(anti_windup=aw,speed0=130.0,step_height=0.0,hill=0.1,torque0=50.9693,y_max=150.0,y_min=0.0),dt=0.1,
        paths=["speed_kmh"=>"plant.v_kmh","torque_Nm"=>"controller.y","integrator_state"=>"controller.integrator.y"],
        evaluate=(r,m,t,v,d)->begin cruise_eval(r,m,t,v,d);aw && compare!(d,"final_speed_kmh",v["speed_kmh"][end],130,0.1);require!(d,"torque_limits",minimum(v["torque_Nm"])>=-1e-6&&maximum(v["torque_Nm"])<=150+1e-6);end)
end
for (id,wd,Nd) in [("noise_kick",1.0,10.0),("noise_measurement",0.0,10.0),("noise_Nd100",0.0,100.0),("noise_Nd2",0.0,2.0)]
    sim(1,id,L1.CruiseExperiment;stop=40,dt=0.002,dtmax=0.002,
        kwargs=(wd=wd,Nd=Nd,amplitude=0.2,T_max=1e6),
        paths=["speed_kmh"=>"plant.v_kmh","torque_Nm"=>"controller.y","measured_speed_kmh"=>"noise.y"],evaluate=cruise_eval)
end
for (id,mass,delay) in [("tuning_nominal",1400.0,0.3),("tuning_payload",1600.0,0.3),("tuning_delay",1400.0,0.6)]
    sim(1,id,L1.CruiseExperiment;stop=40,kwargs=(k=67.41,Ti=1.092,Td=0.273,m=mass,theta_e=delay,T_max=1e6),
        paths=["speed_kmh"=>"plant.v_kmh","torque_Nm"=>"controller.y"],evaluate=cruise_eval)
end
sim(1,"ice_patch",L1.SlipCruiseIcePatch;stop=45,dt=0.02,
    paths=["speed_kmh"=>"plant.v_kmh","wheel_speed_kmh"=>"plant.wheel_kmh","slip_ratio"=>"plant.wheel.kappa"])
for (id,mu) in [("standing_dry",1.0),("standing_slippery",0.2)]
    sim(1,id,L1.SlipCarStandingStart;stop=5,overrides=Dict{String,Any}("friction.k"=>mu),dt=0.01,
        paths=["speed_kmh"=>"car.v_kmh","wheel_speed_kmh"=>"car.wheel_kmh","slip_ratio"=>"car.wheel.kappa"],
        evaluate=(r,m,t,v,d)->compare!(d,"final_speed_kmh",v["speed_kmh"][end],mu==1 ? 21.08 : 10.12,0.1))
end

end
if isempty(SELECTED) || 2 in SELECTED
sim(2,"existing_manifold",MyCarComponents.ManifoldTest;stop=2,dt=0.01,
    paths=["pressure_Pa"=>"manifold.p"],evaluate=(r,m,t,v,d)->compare!(d,"final_pressure_Pa",v["pressure_Pa"][end],50000+287.05*298.15/0.001*0.0001,2.0))
for (id,ov) in [("air_idle",Dict{String,Any}()),("air_3000",Dict{String,Any}("speed.k"=>3000pi/30,"throttle_cmd.height"=>1.0))]
    sim(2,id,L2.AirPathStep;stop=2,overrides=ov,dt=0.002,
        paths=["pressure_Pa"=>"manifold.p","throttle_kgps"=>"throttle.mdot_thr","cylinder_kgps"=>"cylinders.mdot_cyl"],
        evaluate=(r,m,t,v,d)->compare!(d,"final_pressure_Pa",v["pressure_Pa"][end],id=="air_idle" ? 37300 : 99900,500))
end
for (id,ctor,kw,stop) in [("dyno_step",L2.MapEngineDyno,(;),3),("dyno_WOT",L2.MapEngineDyno,(rpm=3000.0,pedal_initial=0.0,pedal_final=1.0,p_m0=13500.0),2),("dyno_fuel_cut",L2.MapEngineFuelCutDyno,(rpm=3000.0,pedal_initial=1.0,pedal_final=0.0,p_m0=99900.0),7)]
    sim(2,id,ctor;stop,kwargs=kw,dt=0.002,paths=["torque_Nm"=>"engine.torque_map.y","fuel_kgps"=>"engine.mdot_fuel","pressure_Pa"=>"engine.p_m"])
end
for (speed,pedal,rpm,pressure,ref) in [(50.0,0.0486,1992.0,40100.0,3.7),(90.0,0.0916,2182.0,54420.0,3.9),(130.0,0.1742,3118.0,67200.0,6.0)]
    sim(2,"student_cruise_$(Int(speed))",L2.MappedCarCruise;stop=60,dt=0.1,
        kwargs=(speed_kmh=speed,pedal_cmd=pedal,rpm0=rpm,p_m0=pressure),
        paths=["speed_kmh"=>"car.v_kmh","fuel_kgps"=>"car.engine.mdot_fuel","pressure_Pa"=>"car.engine.p_m"],
        evaluate=(r,m,t,v,d)->begin fuel_eval(r,m,t,v,d);compare!(d,"fuel_L100km",d["fuel_L100km"],ref,0.15);require!(d,"cruise_speed",maximum(abs.(v["speed_kmh"].-speed))<0.3);end)
end
for (id,ctor,stop) in [("mapped_WOT",L2.MappedCarWOT,300),("coast_down",L2.MappedCarCoast,100),("brake_stop",L2.MappedCarBrakeStop,20)]
    sim(2,id,ctor;stop,dt=0.05,paths=["speed_kmh"=>"car.v_kmh","fuel_kgps"=>"car.engine.mdot_fuel","pressure_Pa"=>"car.engine.p_m"],evaluate=fuel_eval)
end

end
if isempty(SELECTED) || 3 in SELECTED
for (name,ctor,refs) in [("locked",L3.PedalStop,[43.7,85.1,136.7]),("slip_ABS",L3.ABSStop,[34.2,64.6,106.1]),("wheel_ABS",L3.ABSStopWheelOnly,[38.5,78.0,130.6])]
    for (j,mu) in enumerate([1.0,0.5,0.3])
        sim(3,"$(name)_mu$(mu)",ctor;stop=0.5+1.5*25/(0.7mu*9.80665)+1,kwargs=(road_mu=mu,),dt=0.002,
            alg=name=="wheel_ABS" ? ODEAlg.Tsit5() : ODEAlg.Rodas5P(),dtmax=name=="wheel_ABS" ? 0.001 : 0.003,abstol=1e-6,reltol=1e-6,
            paths=["speed_mps"=>"body.mass.v","slip_ratio"=>"wheel.kappa","master_pressure_Pa"=>"master.p_mc","front_pressure_Pa"=>"wheel.caliper_f.p"],
            evaluate=(r,m,t,v,d)->begin dist=VehicleSystemsComponents.Vehicle.braking_distance(r);compare!(d,"braking_distance_m",dist,refs[j],0.3);d["peak_master_pressure_bar"]=maximum(v["master_pressure_Pa"])/1e5;end)
    end
end
for (id,ctor,kw,ref) in [("gentle_pedal",L3.PedalStop,(pedal=0.3,),36.0),("no_lookahead",L3.ABSStop,(T_p=0.0,),53.4)]
    sim(3,id,ctor;stop=10,kwargs=kw,dt=0.002,dtmax=0.003,
        paths=["speed_mps"=>"body.mass.v","slip_ratio"=>"wheel.kappa","front_pressure_Pa"=>"wheel.caliper_f.p"],
        evaluate=(r,m,t,v,d)->compare!(d,"braking_distance_m",VehicleSystemsComponents.Vehicle.braking_distance(r),ref,0.3))
end

end
