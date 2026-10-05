#!/usr/bin/env julia

using Test
using DistSSHBase
using DistSSHUp

@testset "DistSSHUp" verbose = true begin
    include(joinpath(@__DIR__, "unit", "version.jl"))
    include(joinpath(@__DIR__, "unit", "status.jl"))
    include(joinpath(@__DIR__, "unit", "remote.jl"))
    include(joinpath(@__DIR__, "unit", "local.jl"))
    include(joinpath(@__DIR__, "unit", "hosts.jl"))
    include(joinpath(@__DIR__, "unit", "runtime.jl"))
    include(joinpath(@__DIR__, "unit", "main.jl"))
end
