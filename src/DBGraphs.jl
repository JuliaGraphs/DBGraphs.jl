module DBGraphs

# package code goes here

using LightGraphs
using JuliaDB
import JuliaDB: DTable
import LightGraphs: AbstractGraph, vertices, edges, neighbors, indegree, outdegree,
       in_neighbors, out_neighbors, nv, ne, is_directed

export DBGraph

abstract type AbstractDBGraph <: LightGraphs.AbstractGraph end

mutable struct DBGraph{T} <: AbstractDBGraph
  table::T
  src::Symbol
  dst::Symbol
  directed::Bool
end

function DBGraph(table::DTable)
  return DBGraph(table, :src, :dst, true)
end

is_directed(g::DBGraph) = g.directed
is_directed(::DBGraph) = true
is_directed(::Type{DBGraph}) = true
is_directed(::Type{DBGraph{T}}) where T = true

colmax(table, column) = reduce(max,map(x->getfield(x, column), table))
nv(g::DBGraph) = max(colmax(g.table, g.src), colmax(g.table, g.dst))
ne(g::DBGraph) = size(g.table,1)

function vertices(g::DBGraph)
  return select(g.table, g.dst, agg=first)
end

function edges(g::DBGraph)
  return select(g.table, [g.src,g.dst])
end

# function out_neighbors(g::DBGraph, v)
#   return g.table[v,:]
# end
# function in_neighbors(g::DBGraph, v)
#   return g.table[:,v]
# end
# function neighbors(g::DBGraph, v)
#   return merge(out_neighbors(g,v), in_neighbors(g, v))
# end

function out_neighbors(g::DBGraph, v::Integer)
  return collect(map(x->x.dst, filter(x->x[1] == v, g.table)))
end
function in_neighbors(g::DBGraph, v::Integer)
  return collect(map(x->x.src, filter(x->x[2] == v, g.table)))
end
function neighbors(g::DBGraph, v::Integer)
  return union(out_neighbors(g,v), in_neighbors(g, v))
end

indegree(g::DBGraph, v::Integer) = length(collect(in_neighbors(g, v)))
outdegree(g::DBGraph, v::Integer) = length(collect(out_neighbors(g, v)))

end # module
