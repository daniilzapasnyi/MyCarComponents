# Numerical table audit in the project environment. No simulation results are generated here.
using TOML
root=normpath(joinpath(@__DIR__,".."))
library=dirname(dirname(Base.find_package("VehicleSystemsComponents")))
data=joinpath(library,"data","engine")
function readmap(name)
    rows=split.(readlines(joinpath(data,name)),',')
    pressures=parse.(Float64,rows[1][2:end])
    rpm=[parse(Float64,r[1]) for r in rows[2:end]]
    z=reduce(vcat,[permutedims(parse.(Float64,r[2:end])) for r in rows[2:end]])
    (rpm=rpm,p=pressures,z=z)
end
function interp(m,n,p)
    i=clamp(searchsortedlast(m.rpm,n),1,length(m.rpm)-1)
    j=clamp(searchsortedlast(m.p,p),1,length(m.p)-1)
    a=(n-m.rpm[i])/(m.rpm[i+1]-m.rpm[i]);b=(p-m.p[j])/(m.p[j+1]-m.p[j])
    (1-a)*((1-b)*m.z[i,j]+b*m.z[i,j+1])+a*((1-b)*m.z[i+1,j]+b*m.z[i+1,j+1])
end
torque,fuel,lambda=readmap.( ["torque_Nm.csv","fuel_gps.csv","lambda.csv"] )
d=Dict{String,Any}("source"=>"VehicleSystemsComponents lecture-05-dyad-3.5 data/engine", "kind"=>"interpolated map estimates; not dynamic simulations")
d["torque_4000rpm_100kPa_Nm"]=interp(torque,4000,100)
d["torque_4000rpm_100kPa_pass"]=abs(d["torque_4000rpm_100kPa_Nm"]-160.3)<0.1
d["map_max_torque_Nm"]=maximum(torque.z)
d["lambda_3000rpm_100kPa"]=interp(lambda,3000,100)
d["lambda_rich_pass"]=abs(d["lambda_3000rpm_100kPa"]-0.87)<0.01
for speed in (50,90,130)
    v=speed/3.6;rpm=v/0.31*4*30/pi
    tau=(0.5*1.2*0.63*v^2+1400*9.80665*0.012)*0.31/4
    low,high=0.0,105.0
    for _ in 1:70
        mid=(low+high)/2
        if interp(torque,rpm,mid)<tau;low=mid;else;high=mid;end
    end
    p=(low+high)/2;f=interp(fuel,rpm,p)
    d["fixed_gear_$speed"]=Dict("speed_kmh"=>speed,"rpm"=>rpm,"torque_Nm"=>tau,"pressure_kPa"=>p,
        "fuel_gps"=>f,"fuel_L100km"=>f/745*3600/speed*100,"CO2_gpkm"=>3.09*f/v*1000,
        "BSFC_gpkWh"=>3600f/(tau*rpm*pi/30/1000),"lambda"=>interp(lambda,rpm,p))
end
out=joinpath(root,"coursework","Lecture2","map_audit.toml")
open(out,"w") do io;TOML.print(io,d;sorted=true);end
println("Map audit: ",out)
