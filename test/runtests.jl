#!/usr/bin/env julia

using Test
using DistSSHUp

@testset "DistSSHUp" verbose = true begin
    include(joinpath(@__DIR__, "unit", "version.jl"))
    include(joinpath(@__DIR__, "unit", "status.jl"))
    include(joinpath(@__DIR__, "unit", "remote.jl"))
    include(joinpath(@__DIR__, "unit", "local.jl"))
end
