using DBGraphs
using Base.Test
using JuliaDB
using LightGraphs
# write your own tests here

path = Pkg.dir("DBGraphs", "test", "data")
# g = DBGraph(loadfiles(path, indexcols=["src","dst"]))
g = DBGraph(loadfiles(path))

@show g
@test g.src == :src
@test g.dst == :dst
# @test 2 ∈ neighbors(g, 1)

@test outdegree(g, 1) == 2
@test indegree(g, 1) == 0
@test indegree(g, 3) == 0
@test outdegree(g, 3) == 2

@test ne(bfs_tree(g, 1)) == 1
@test ne(bfs_tree(g, 3)) == 10
for e in edges(bfs_tree(g, 3))
  println(e)
end
