# Additional coursework tasks and a targeted recheck of the repaired grade-body bench.
# Reuse the same solver/CSV/plot/result writer without rerunning the main matrix.
additional_selection=parse.(Int,filter(x->all(isdigit,x),ARGS))
additional_options=filter(x->startswith(x,"--"),ARGS)
empty!(ARGS);push!(ARGS,"0")
append!(ARGS,additional_options)
include("run_coursework.jl")
using DiscreteComponents
empty!(SELECTED)
union!(SELECTED,additional_selection)
if isempty(SELECTED) || 1 in SELECTED
sim(1,"grade_body",L1.TestGradeBody;stop=10,paths=["speed_mps"=>"body.mass.v"],
    evaluate=(r,m,t,v,d)->compare!(d,"final_speed_mps",v["speed_mps"][end],10.16,0.03))
for (id,Ts,k,Ti,Td) in [("sampled_001",0.01,67.41,1.092,0.273),("sampled_01",0.1,67.41,1.092,0.273),("sampled_04",0.4,67.41,1.092,0.273),("sampled_1",1.0,67.41,1.092,0.273),("sampled_fast_fix",0.05,67.41,1.092,0.273),("sampled_retuned",1.0,20.0,3.0,0.5)]
    sim(1,id,VehicleSystemsComponents.Lecture1.SampledCruiseStep;stop=30,dt=0.01,dtmax=0.01,
        overrides=Dict{String,Any}("loop.controller.initialization"=>DiscreteComponents.InitialCondition.InitialOutput(y0=20k)),
        kwargs=(with_I=true,with_D=true,Ts=Ts,k=k,Ti=Ti,Td=Td,wd=0.0,T_max=1e6,y_max=1e6,y_min=-1e6),
        paths=["speed_kmh"=>"loop.plant.v_kmh","held_torque_Nm"=>"loop.hold.y"],
        evaluate=(r,m,t,v,d)->begin d["peak_speed_kmh"]=maximum(v["speed_kmh"]);d["final_speed_kmh"]=last(v["speed_kmh"]);end)
end
for (id,mu,ref) in [("wheel_unit_dry",1.0,6.86),("wheel_unit_slippery",0.2,3.43)]
    sim(1,id,L1.TestSlipWheel1D;stop=5,dt=0.01,overrides=Dict{String,Any}("mu_src.k"=>mu),
        paths=["speed_mps"=>"mass.v","slip_ratio"=>"wheel.kappa"],
        evaluate=(r,m,t,v,d)->compare!(d,"final_speed_mps",last(v["speed_mps"]),ref,0.03))
end
for (id,grade) in [("grade_car_flat",0.0),("grade_car_climb",0.1)]
    sim(1,id,L1.GradeCarFullThrottle;stop=300,dt=0.25,overrides=Dict{String,Any}("road.k"=>grade),
        paths=["speed_kmh"=>"car.v_kmh"],
        evaluate=(r,m,t,v,d)->begin d["final_speed_kmh"]=last(v["speed_kmh"]);grade==0&&compare!(d,"final_speed_kmh",d["final_speed_kmh"],246.388,0.05);end)
end
sim(1,"limited_cruise_step",L1.CruiseExperiment;stop=100,kwargs=(y_max=150.0,y_min=0.0,),
    paths=["speed_kmh"=>"plant.v_kmh","torque_Nm"=>"controller.y"],
    evaluate=(r,m,t,v,d)->begin require!(d,"torque_limits",minimum(v["torque_Nm"])>=0&&maximum(v["torque_Nm"])<=150);compare!(d,"final_speed_kmh",last(v["speed_kmh"]),110,0.1);end)
end
if isempty(SELECTED) || 2 in SELECTED
sim(2,"mapped_WLTC",L2.MappedCarWLTC;stop=1800,dt=0.1,dtmax=0.1,
    paths=["target_kmh"=>"trace.y","speed_kmh"=>"car.v_kmh","fuel_L"=>"fuel_L.y","distance_km"=>"dist_km.y","effort_fraction"=>"driver.y"],
    evaluate=(r,m,t,v,d)->begin
        L,km=last(v["fuel_L"]),last(v["distance_km"])
        d["fuel_L"]=L;d["distance_km"]=km
        compare!(d,"fuel_L100km",100L/km,5.22,0.25)
        d["CO2_gpkm"]=2302L/km
        target=v["target_kmh"];actual=v["speed_kmh"]
        inside=[minimum(target[max(1,i-10):min(length(t),i+10)])-2<=actual[i]<=maximum(target[max(1,i-10):min(length(t),i+10)])+2 for i in eachindex(t)]
        d["tracking_band_percent"]=100count(inside)/length(t)
        require!(d,"tracking_band",d["tracking_band_percent"]>=95)
        for (name,a,b) in [("Low",0,589),("Medium",589,1022),("High",1022,1477),("ExtraHigh",1477,1800)]
            fuel=Float64(r.sol(b;idxs=m.fuel_L.y)-r.sol(a;idxs=m.fuel_L.y));distance=Float64(r.sol(b;idxs=m.dist_km.y)-r.sol(a;idxs=m.dist_km.y))
            d["phase_$(name)_L100km"]=100fuel/distance
        end
    end)
end
