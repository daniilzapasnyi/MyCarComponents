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
if isempty(SELECTED) || 4 in SELECTED
for (id,rpm,ref) in [("converter_held_base",3283.0,320.0),("converter_held_10000",10000.0,103.8)]
    sim(4,id,L4.ConverterDyno;stop=2,dt=0.01,kwargs=(rpm_start=rpm,rpm_end=rpm),
        paths=["torque_Nm"=>"machine.tau","field_fraction"=>"converter.field","shaft_W"=>"machine.P_mech"],
        evaluate=(r,m,t,v,d)->compare!(d,"final_torque_Nm",last(v["torque_Nm"]),ref,0.3))
end
end
