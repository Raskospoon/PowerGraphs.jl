using LightGraphs

abstract type PowerGraphBase end

mutable struct RadialPowerGraph <: PowerGraphBase
    G::DiGraph # graph containing the power network 
    mpc::Case
    ref_bus::Int # The id of the reference bus
    radial::DiGraph # The graph directed from the transmission node
end

mutable struct PowerGraph <: PowerGraphBase
    G::DiGraph
    mpc::Case
    ref_bus::Int
end

function RadialPowerGraph()
    G = DiGraph()
    mpc = Case()
    ref_bus = 0
    radial = DiGraph()
    RadialPowerGraph(G, mpc, ref_bus, radial)
end

function RadialPowerGraph(case_file::String)
    mpc = Case(case_file::String)
    G, ref_bus = read_case(mpc)
    radial = directed_from_feeder(G, ref_bus)
    RadialPowerGraph(G, mpc, ref_bus, radial)
end

function PowerGraph(mpc::Case)
    G, ref_bus = read_case(mpc)
    PowerGraph(G, mpc, ref_bus)
end

function PowerGraph(case_file::String)
    PowerGraph(Case(case_file::String))
end

function read_case(mpc::Case; ignore_id::Bool=false)
    G = DiGraph(nrow(mpc.bus))
	
	for branch in eachrow(mpc.branch)
		if ignore_id
			edge = Edge(branch[:f_bus], branch[:t_bus])
		else
		edge = Edge(get_bus_row(mpc, branch[:f_bus]),
					get_bus_row(mpc, branch[:t_bus]))
		end
		add_edge!(G, edge)
	end
    ref_bus = NaN
	for (index, bus) in enumerate(eachrow(mpc.bus))
        if bus[:type] == 3
            ref_bus = index
        end
    end
    return G, ref_bus
end


