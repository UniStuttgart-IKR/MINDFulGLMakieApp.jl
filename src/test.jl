using GLMakie

import Pkg
Pkg.activate(".")
import .MINDFulGraphs: generate_ibns



fig = Figure()

a = Axis(fig[1,1])

# println(asd[1,1])
# println(fieldnames(typeof(f2)))
# println(fieldnames(typeof(f2.current_axis.x)))
# println(fieldnames(typeof((contents(f2[1,1])[1]))))
# println(content(f2[1,1]).title)
# println(fieldnames(typeof(p.attributes)))
# println(p.attributes)
# println(fieldnames(typeof(f2.layout.layoutobservables)))
# println(f2.layout.layoutobservables)


p = generate_ibns(a)

#f2

# fig[1,1] = p
# #fig[1,1] = Axis(fig)
#
fig

println("hello")
