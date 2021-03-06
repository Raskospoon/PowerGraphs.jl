using LightGraphs.LinAlg
using LinearAlgebra
""" 
    get_bus_data!(network::PowerGraphBase, bus_id::Int)

    Return a DataFrameRow with the bus data.
"""
function get_bus_data!(network::PowerGraphBase, bus_id::Int)::DataFrameRow
    return get_bus!(network.mpc, bus_id)
end

""" 
    get_bus_data(network::PowerGraphBase, bus_id::Int)

    Return a copy of the DataFrameRow with the bus data.
"""
function get_bus_data(network::PowerGraphBase, bus_id::Int)::DataFrameRow
    return get_bus(network.mpc, bus_id)
end

function get_gen_data!(network::PowerGraphBase, bus_id::Int)::DataFrame
    return get_gen!(network.mpc, bus_id)
end

function get_gen_data(network::PowerGraphBase, bus_id::Int)::DataFrame
    return get_gen(network.mpc, bus_id)
end

function get_loaddata(network::PowerGraphBase, bus_id::Int)::DataFrame
    return get_loaddata(network.mpc, bus_id)
end

function push_bus!(network::PowerGraphBase, data::DataFrameRow)
    add_vertex!(network.G)
    push_bus!(network.mpc, data)
end

function push_gen!(network::PowerGraphBase, data::DataFrame)
    for gen in eachrow(data)
        push_gen!(network, gen)
    end
end

function push_gen!(network::PowerGraphBase, data::DataFrame, bus::Int)
    for gen in eachrow(data)
        push_gen!(network, gen, bus)
    end
end

function push_gen!(network::PowerGraphBase, data::DataFrameRow)
    push_gen!(network.mpc, data)
end

function push_gen!(network::PowerGraphBase, data::DataFrameRow, bus::Int)
    data[:bus] = bus
    push_gen!(network, data)
end

function push_loaddata!(network::PowerGraphBase, data::DataFrameRow)
    push_loaddata!(network.mpc, data)
end

function push_loaddata!(network::PowerGraphBase, data::DataFrameRow, bus::Int)
    data[:bus] = bus
    push_loaddata!(network, data)
end

function push_loaddata!(network::PowerGraphBase, data::DataFrame, bus::Int)
    for load in eachrow(data)
        push_loaddata!(network, load, bus)
    end
end

function push_branch!(network::PowerGraphBase, f_bus::Int, t_bus::Int, data::DataFrameRow)
	push_branch!(network.mpc, f_bus, t_bus, data)
    add_edge!(network.G, f_bus, t_bus)
end

function push_switch!(network::PowerGraphBase, f_bus::Int, t_bus::Int, data::DataFrameRow)
	push_switch!(network.mpc, f_bus, t_bus, data)
end

function push_indicator!(network::PowerGraphBase, f_bus::Int, t_bus::Int, data::DataFrameRow)
	push_indicator!(network.mpc, f_bus, t_bus, data)
end

function push_transformer!(network::PowerGraphBase, f_bus::Int, t_bus::Int, data::DataFrameRow)
	push_transformer!(network.mpc, f_bus, t_bus, data)
end

function push_branch!(network::PowerGraphBase, f_bus::Int, t_bus::Int, data::DataFrame)
    for branch in eachrow(data)
        push_branch!(network, f_bus, t_bus, branch)
    end
end

function push_branch!(network::PowerGraphBase, type::Symbol, f_bus::Int, t_bus::Int, data::DataFrameRow)
	push_branch!(network.mpc, type, f_bus, t_bus, data)
end

""" 
    get_branch_data(network::PowerGraphBase, f_bus_id::Int, t_bus::Int)

    Return a dictionary containing the dictionary with the buse data.
"""
function get_branch_data(network::PowerGraphBase, f_bus::Int, t_bus::Int)::DataFrame
    if has_edge(network.G, f_bus, t_bus)
        return get_branch(network.mpc, f_bus, t_bus)
    else
        return get_branch(network.mpc, t_bus, f_bus)
    end
end

function get_branch_data(network::PowerGraphBase, type::Symbol, f_bus::Int,
						 t_bus::Int)::DataFrameRow
	get_branch_data(network.mpc, type, f_bus, t_bus)
end

function get_branch_data(network::PowerGraphBase, type::Symbol, column::Symbol, f_bus::Int,
						 t_bus::Int)
	get_branch_data(network.mpc, type, column, f_bus, t_bus)
end

function is_branch_type_in_graph(network::PowerGraphBase, type::Symbol, f_bus::Int,
								 t_bus::Int)
	is_branch_type_in_case(network.mpc, type, f_bus, t_bus)
end

function set_branch_data!(network::PowerGraphBase, type::Symbol, column::Symbol, f_bus::Int, t_bus::Int, data)
	set_branch_data!(network.mpc, type, column, f_bus, t_bus, data)
end

function get_switch_data(network::PowerGraphBase, f_bus::Int, t_bus::Int)::DataFrame
	get_switch(network.mpc, f_bus, t_bus)
end

function get_indicator_data(network::PowerGraphBase, f_bus::Int, t_bus::Int)::DataFrame
	get_indicator(network.mpc, f_bus, t_bus)
end

function get_transformer_data(network::PowerGraphBase, f_bus::Int, t_bus::Int)::DataFrame
	get_transformer(network.mpc, f_bus, t_bus)
end

function set_branch_data!(network::PowerGraphBase, f_bus::Int, t_bus::Int, data::DataFrame)
    set_branch!(network.mpc, f_bus, t_bus, data)
end

function set_switch_data!(network::PowerGraphBase, f_bus::Int, t_bus::Int, data::DataFrame)
    set_switch!(network.mpc, f_bus, t_bus, data)
end

function set_indicator_data!(network::PowerGraphBase, f_bus::Int, t_bus::Int, data::DataFrame)
    set_indicator!(network.mpc, f_bus, t_bus, data)
end

"""
    is_load_bus(network::PowerGraphBase, bus_id::Int)

    Returns true if the bus bus_id is a load.
"""
function is_load_bus(network::PowerGraphBase, bus_id::Int)
    return network.mpc.bus[bus_id,:Pd]>0
end

"""
    is_gen_bus(network::PowerGraphBase, bus_id::Int)

    Returns true if the bus bus_id is a load.
"""
function is_gen_bus(network::PowerGraphBase, bus_id::Int)
    return is_gen_bus(network.mpc, bus_id)
end

function is_indicator(network::PowerGraphBase, f_bus::Int, t_bus::Int)
	is_indicator(network.mpc, f_bus, t_bus)
end

function is_switch(network::PowerGraphBase, f_bus::Int, t_bus::Int)
	is_switch(network.mpc, f_bus, t_bus)
end

function is_transformer(network::PowerGraphBase, f_bus::Int, t_bus::Int)
	is_transformer(network.mpc, f_bus, t_bus)
end

function is_neighbor_switch(network::PowerGraphBase, f_bus::Int, t_bus::Int)
	is_neighbor_switch(network.mpc, f_bus, t_bus)
end

function is_neighbor_indicator(network::PowerGraphBase, f_bus::Int, t_bus::Int)
	is_neighbor_indicator(network.mpc, f_bus, t_bus)
end

"""
    get_π_equivalent(network::PowerGraphBase, from_bus::Int, to_bus::Int)
    
    Returns the π-equivalent of a line segment.
"""
function get_π_equivalent(network::PowerGraphBase, from_bus::Int, to_bus::Int)::π_segment
    branch = get_branch_data(network, from_bus, to_bus)
    if nrow(branch)>1
        @warn string("The branch ", repr(from_bus), "-", repr(to_bus),
                     " is parallel")
    elseif nrow(branch) == 0
        return π_segment(0, 0, 0)
    end
    return get_π_equivalent(branch[1,:])  
end

function get_π_equivalent(branch::DataFrameRow)::π_segment
    return π_segment(branch[:r]+branch[:x]im,
                     0+0.5*branch[:b]im,
                     0+0.5*branch[:b]im,)
end

"""
    get_dc_admittance_matrix(network::PowerGraphBase)::Array{Float64}
    Returns the admittance matrix for performing a dc power flow.
"""
function get_dc_admittance_matrix(network::PowerGraphBase)::Array{Float64, 2}
    A = incidence_matrix(network.G)
	return A*Diagonal(get_susceptance_vector(network))*A'
end

function get_incidence_matrix(network::PowerGraphBase)::Array{Int64, 2}
	return get_incidence_matrix(network.mpc)
end

"""
    get_susceptance_vector(network::PowerGraphBase)::Array{Float64}
    Returns the susceptance vector for performing a dc power flow.
"""
function get_susceptance_vector(network::PowerGraphBase)::Array{Float64,1}
    return get_susceptance_vector(network.mpc)
end

function get_power_injection_vector(network::PowerGraphBase)::Array{Float64, 1}
    return get_power_injection_vector(network.mpc)
end

function get_power_injection_vector_pu(network::PowerGraphBase)::Array{Float64, 1}
    return get_power_injection_vector(network.mpc)/network.mpc.baseMVA
end

function n_edges(network::PowerGraphBase)::Int
    return ne(network.G)
end

function n_vertices(network::PowerGraphBase)::Int
    return nv(network.G)
end

function take_out_line!(network::PowerGraphBase, id::Int)
    branch = get_branch(network.mpc, id)
    rem_edge!(network.G, branch.f_bus, branch.t_bus)
end

function put_back_line!(network::PowerGraphBase, id::Int)
    branch = get_branch(network.mpc, id)
    add_edge!(network.G, branch.f_bus, branch.t_bus)
end

function get_line_lims_pu(network::PowerGraphBase)::Array{Float64}
    return get_line_lims_pu(network.mpc)
end

"""Return list of buses in islands"""
function get_islanded_buses(network::PowerGraphBase)::Array{Array{Int64,1},1}
	connected_components(network.G)
end


