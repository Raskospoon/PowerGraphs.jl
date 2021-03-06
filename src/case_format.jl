using DataFrames
using CSV
import Pkg.TOML

mutable struct Case
    baseMVA::Float64
    bus::DataFrame
    branch::DataFrame
    gen::DataFrame
	switch::DataFrame
	indicator::DataFrame
	reldata::DataFrame
	loaddata::DataFrame
	transformer::DataFrame
    gencost::DataFrame
end

function Case()::Case
    baseMVA = 100
    bus = DataFrame()
    branch = DataFrame()
    gen = DataFrame()
	switch = DataFrame()
	indicator = DataFrame()
	reldata = DataFrame()
	loaddata = DataFrame()
	transformer = DataFrame()
    gencost = DataFrame()
    Case(baseMVA, bus, branch, gen, switch, indicator, reldata, loaddata, transformer, gencost)
end
    
function Case(fname::String)::Case
	mpc = Case()
	conf = TOML.parsefile(fname)
	dir = splitdir(fname)[1]
	for (field, file) in conf["files"]
		setfield!(mpc, Symbol(field), CSV.File(joinpath(dir, file)) |> DataFrame)
	end
	mpc.baseMVA = conf["configuration"]["baseMVA"]

	return mpc
end

function push_bus!(mpc::Case, bus::DataFrameRow)
    push!(mpc.bus, bus)
end

function push_branch_type!(df::DataFrame, f_bus::Int, t_bus::Int, data::DataFrameRow)
    data[:f_bus] = f_bus
    data[:t_bus] = t_bus
    push!(df, data) 
end

function push_branch!(mpc::Case, f_bus::Int, t_bus::Int, branch::DataFrameRow)
	push_branch_type!(mpc.branch, f_bus, t_bus, branch)
end

function push_branch!(mpc::Case, type::Symbol, f_bus::Int, t_bus::Int, data::DataFrameRow)
	push_branch_type!(getfield(mpc, type), f_bus, t_bus, data)
end

function push_indicator!(mpc::Case, f_bus::Int, t_bus::Int, branch::DataFrameRow)
	push_branch_type!(mpc.indicator, f_bus, t_bus, branch)
end

function push_switch!(mpc::Case, f_bus::Int, t_bus::Int, branch::DataFrameRow)
	push_branch_type!(mpc.switch, f_bus, t_bus, branch)
end

function push_transformer!(mpc::Case, f_bus::Int, t_bus::Int, transformer::DataFrameRow)
	push_branch_type!(mpc.transformer, f_bus, t_bus, transformer)
end
    
function push_gen!(mpc::Case, gen::DataFrameRow)
    push!(mpc.gen, gen)
end

function push_loaddata!(mpc::Case, load::DataFrameRow)
    push!(mpc.loaddata, load)
end

function get_bus(mpc::Case, ID::Int)::DataFrameRow
    return mpc.bus[ID, :]
end

function get_bus!(mpc::Case, ID::Int)::DataFrameRow
    return mpc.bus[ID, !]
end

function get_loaddata(mpc::Case, bus_id::Int)::DataFrame
    return mpc.loaddata[mpc.loaddata.bus.==bus_id,:]
end

function get_gen(mpc::Case, bus_id::Int)::DataFrame
    return mpc.gen[mpc.gen.bus.==bus_id,:]
end

function get_gen!(mpc::Case, bus_id::Int)::DataFrame
    return mpc.gen[mpc.gen.bus.==bus_id, !]
end

function get_branch_type(branch::DataFrame, f_bus::Int, t_bus::Int)::DataFrame
    temp = branch[(branch.f_bus .== f_bus) .&
                      (branch.t_bus .== t_bus),:]
	if isempty(temp)
		temp = branch[(branch.t_bus .== f_bus) .&
               (branch.f_bus .== t_bus),:]
		   end
   return temp
end

function get_branch(mpc::Case, f_bus::Int, t_bus::Int)::DataFrame
	get_branch_type(mpc.branch, f_bus, t_bus)
end

function get_switch(mpc::Case, f_bus::Int, t_bus::Int)::DataFrame
	get_branch_type(mpc.switch, f_bus, t_bus)
end

function get_indicator(mpc::Case, f_bus::Int, t_bus::Int)::DataFrame
	get_branch_type(mpc.indicator, f_bus, t_bus)
end

function get_transformer(mpc::Case, f_bus::Int, t_bus::Int)::DataFrame
	get_branch_type(mpc.transformer, f_bus, t_bus)
end

function get_branch(mpc::Case, id::Int)::DataFrameRow
    return mpc.branch[id,:]
end

function get_branch_data(mpc::Case, type::Symbol, f_bus::Int, t_bus::Int)::DataFrameRow
	get_branch_type(getfield(mpc, type), f_bus, t_bus)[1,:]
end

function get_branch_data(mpc::Case, type::Symbol, column::Symbol, f_bus::Int, t_bus::Int)

	get_branch_data(mpc, type, f_bus, t_bus)[column]
end

function is_branch_type_in_case(df::DataFrame, f_bus::Int, t_bus)
	(any((df.f_bus .== f_bus) .& (df.t_bus .== t_bus)) ||
	 any((df.t_bus .== f_bus) .& (df.f_bus .== t_bus)))
end

function is_branch_type_in_case(mpc::Case, type::Symbol, f_bus::Int,
								 t_bus::Int)
	is_branch_type_in_case(getfield(mpc, type), f_bus, t_bus)
end

function set_branch_type(branch::DataFrame, f_bus::Int, t_bus::Int, data::DataFrame)
    branch[(branch.f_bus .== f_bus) .&
              (branch.t_bus .== t_bus), :] = data
end

function set_branch!(mpc::Case, f_bus::Int, t_bus::Int, data::DataFrame)
	set_branch_type(mpc.branch, f_bus, t_bus, data)
end

function set_branch_data(df::DataFrame, column::Symbol, f_bus::Int, t_bus::Int, data)
	df[(df.f_bus .== f_bus) .& (df.t_bus .== t_bus) .|
	  (df.f_bus .== t_bus) .& (df.t_bus .== f_bus), column] .= data
end

function set_branch_data!(mpc::Case, type::Symbol, column::Symbol, f_bus::Int, t_bus::Int,
				 data)
set_branch_data(getfield(mpc, type), column, f_bus, t_bus, data)
end

function set_switch!(mpc::Case, f_bus::Int, t_bus::Int, data::DataFrame)
	set_branch_type(mpc.switch, f_bus, t_bus, data)
end

function set_indicator!(mpc::Case, f_bus::Int, t_bus::Int, data::DataFrame)
	set_branch_type(mpc.indicator, f_bus, t_bus, data)
end

function is_gen_bus(mpc::Case, bus_id::Int)::Bool
    return bus_id in mpc.gen.bus
end

function is_neighbor_switch_or_indicator(df::DataFrame, f_bus::Int, t_bus::Int)::Bool
	(any(df.f_bus .== f_bus) || any(df.t_bus .== f_bus) ||
	 any(df.f_bus .== t_bus) || any(df.t_bus .== t_bus))
end

function is_neighbor_switch(mpc::Case, f_bus::Int, t_bus)
	nrow(mpc.switch) > 0 && is_neighbor_switch_or_indicator(mpc.switch,
															f_bus,
															t_bus)
end

function is_neighbor_indicator(mpc::Case, f_bus::Int, t_bus)
	nrow(mpc.indicator) > 0 && is_neighbor_switch_or_indicator(mpc.indicator,
															   f_bus,
															      t_bus)
end

function is_switch(mpc::Case, f_bus::Int, t_bus::Int)::Bool
	nrow(mpc.switch) > 0 && is_branch_type_in_case(mpc.switch, f_bus, t_bus)
end

function is_indicator(mpc::Case, f_bus::Int, t_bus::Int)::Bool
	nrow(mpc.indicator) > 0 && is_branch_type_in_case(mpc.indicator, f_bus, t_bus)
end

function is_transformer(mpc::Case, f_bus::Int, t_bus::Int)::Bool
	nrow(mpc.transformer) > 0 && is_branch_type_in_case(mpc.transformer, f_bus, t_bus)
end

function delete_branch!(mpc::Case, f_bus::Int, t_bus::Int)
    deleterows!(mpc.branch, (mpc.branch.f_bus .== f_bus) .&
               mpc.branch.t_bus .== t_bus)
end

function delete_bus!(mpc::Case, bus::Int)
    deleterows!(mpc.bus, bus)
end

"""
    get_susceptance_vector(network::PowerGraphBase)::Array{Float64}
    Returns the susceptance vector for performing a dc power flow.
"""
function get_susceptance_vector(case::Case)::Array{Float64, 1}
    return map(x-> 1/x, case.branch[:,:x])
end

"""
    get_incidence_matrix(network::PowerGraphBase)::Array{Float64}
    Returns the susceptance vector for performing a dc power flow.
"""
function get_incidence_matrix(case::Case)::Array{Int64, 2}
	A = zeros(Int, nrow(case.branch), nrow(case.bus))
	for (id, branch) in enumerate(eachrow(case.branch))
		A[id, get_bus_row(case, branch.f_bus)] = 1
		A[id, get_bus_row(case, branch.t_bus)] = -1
	end
	return A
end

function get_power_injection_vector(case::Case)::Array{Float64, 1}
    Pd = -case.bus[:, :Pd]
    Pg = zeros(length(Pd), 1) 
    for gen in eachrow(case.gen) 
        Pg[gen.bus] = gen.Pg
    end
    return Pg[:] + Pd
end

function get_line_lims_pu(case::Case)::Array{Float64}
    return case.branch.rateA/case.baseMVA
end

function update_ID!(mpc::Case)
	mpc.bus.ID = 1:length(mpc.bus.ID)
end

function to_csv(mpc::Case, fname::String)
	conf = Dict("files"=>Dict{String, String}(),
				"configuration"=>Dict{String, Any}())
	for field in fieldnames(typeof(mpc))
		df = getfield(mpc, field)
		if typeof(df) == DataFrame
			fpath = string(fname, "_", String(field))
			conf["files"][String(field)] = fpath
			file = open(string(fpath, ".csv"), "w")
			CSV.write(file, df)
			close(file)
		else 
			conf["configuration"][String(field)] = df
		end
	end
	file = open(string(fname, ".toml"), "w")
	TOML.print(file, conf)
	close(file)
end


""" Returns the number of buses in the case."""
function get_n_buses(mpc::Case)::Int64
	nrow(mpc.bus)
end

""" Returns the row number of a bus given by id"""
function get_bus_row(mpc::Case, id::Int64)::Int64
	row = findall(mpc.bus.ID .== id)
	if length(row) == 0
		error(string("Bus with ID ", repr(id), " not found."))
	elseif length(row) > 1
		error(string("Multiple buses with the ID ", repr(id)))
	else
		return row[1]
	end
end



