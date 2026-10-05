#!/usr/bin/env julia
# Real SSH for juliaup align. Not part of Pkg.test().
#
#   testenv/docker-ssh/scripts/up.sh --e2e
#   DISTSSHKIT_SSH_E2E=1 julia --project=. test/e2e.jl

using Test
using DistSSHUp

if get(ENV, "DISTSSHKIT_SSH_E2E", "") != "1"
    @info "Skipping SSH E2E (set DISTSSHKIT_SSH_E2E=1 to enable)"
    exit(0)
end

const _root = abspath(joinpath(@__DIR__, "..", "testenv", "docker-ssh"))
const _ssh_config = joinpath(_root, ".generated", "ssh_config")
isfile(_ssh_config) ||
    error("docker-ssh not ready: missing $(_ssh_config). Run testenv/docker-ssh/scripts/up.sh")

@testset "DistSSHUp SSH" verbose = true begin
    withenv("DISTRIBUTED_SSH_OPTS" => "-F $(_ssh_config) -o RequestTTY=no") do
        aligned = juliaup_align_host!("child-1")
        @test aligned.host == "child-1"
        @test aligned.channel == juliaup_channel()
        @test aligned.already isa Bool
    end
end
