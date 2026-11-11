using GR

# Keep a min/max envelope in each bucket so narrow transients remain visible in compact SVGs.
function plot_indices(y)
    length(y)<=4000 && return collect(eachindex(y))
    stride=ceil(Int,length(y)/1800)
    indices=Int[1,length(y)]
    for a in 1:stride:length(y)
        b=min(a+stride-1,length(y)); segment=@view y[a:b]
        push!(indices,a+argmin(segment)-1,a+argmax(segment)-1)
    end
    sort!(unique!(indices))
end

"Export a labelled SVG with separate panels for quantities with different units."
function saveplot(file, title, ts, values)
    GR.beginprint(file)
    try
        GR.clearws()
        GR.setcolorrep(0,1,1,1);GR.setcolorrep(1,0,0,0)
        GR.selntran(0);GR.setfillintstyle(1);GR.setfillcolorind(0)
        GR.fillrect(0,1,0,1);GR.setlinecolorind(1);GR.settextcolorind(1)
        GR.selntran(1)
        panels=[(label,[label=>y]) for (label,y) in values]
        if haskey(values,"target_kmh") && haskey(values,"speed_kmh")
            panels=vcat([("speed_kmh",["actual"=>values["speed_kmh"],"target"=>values["target_kmh"]]),
                ("speed_error_kmh",["error"=>values["target_kmh"].-values["speed_kmh"]])],
                [(label,[label=>y]) for (label,y) in values if !(label in ["target_kmh","speed_kmh"])])
        end
        n=length(panels)
        for (j,(label,traces)) in enumerate(panels)
            y=reduce(vcat,last.(traces))
            valid=isfinite.(y);all(valid)||error("Cannot plot nonfinite $label; inspect the recorded run.")
            lo,hi=extrema(y); pad=max((hi-lo)*0.08,abs(hi)*0.005,1e-6)
            dx=GR.tick(first(ts),last(ts));dy=GR.tick(lo-pad,hi+pad)
            ylo=floor((lo-pad)/dy)*dy;yhi=ceil((hi+pad)/dy)*dy
            lo>=-1e-9 && hi>1e-4 && (ylo=max(0,ylo))
            bottom=0.08+(n-j)*0.84/n; top=bottom+0.67/n
            GR.setviewport(0.14,0.95,bottom,top)
            GR.setwindow(first(ts),last(ts),ylo,yhi)
            GR.setcharheight(0.012)
            GR.axes(dx,dy,first(ts),ylo,1,1,0.005)
            for (k,(name,trace)) in enumerate(traces)
                GR.setlinecolorind(k==1 ? 4 : 2);GR.setlinetype(k==1 ? 1 : 2)
                indices=plot_indices(trace)
                GR.polyline(ts[indices],trace[indices])
            end
            GR.setlinecolorind(1);GR.setlinetype(1)
            GR.selntran(0);GR.settextalign(2,3)
            if length(traces)>1
                for (k,(name,trace)) in enumerate(traces)
                    GR.settextcolorind(k==1 ? 4 : 2)
                    GR.text(0.86,top-0.018k,name)
                end
                GR.settextcolorind(1)
            end
            j==1 && GR.text(0.55,0.98,title)
            j==n && GR.text(0.55,0.035,"Time [s]")
            GR.setcharup(-1,0)
            axislabel=replace(label,r"_kmh$"=>" [km/h]",r"_mps$"=>" [m/s]",r"_radps$"=>" [rad/s]",
                r"_Nm$"=>" [N m]",r"_Pa$"=>" [Pa]",r"_kgps$"=>" [kg/s]",r"_fraction$"=>" [-]",r"_A$"=>" [A]",r"_V$"=>" [V]",r"_W$"=>" [W]",r"_rpm$"=>" [rpm]",r"_km$"=>" [km]",r"_L$"=>" [L]",r"_ratio$"=>" [-]")
            GR.text(0.025,(bottom+top)/2,replace(axislabel,"_"=>" "))
            GR.setcharup(0,1); GR.selntran(1)
        end
        GR.updatews()
    finally
        GR.endprint()
    end
end
