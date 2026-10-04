using Test

@testset "version" begin
    @test DistSSHUp.julia_version_mismatch_kind(v"1.12.6", v"1.12.6") == :none
    @test DistSSHUp.julia_version_mismatch_kind(v"1.12.6", v"1.12.9") == :patch
    @test DistSSHUp.julia_version_mismatch_kind(v"1.12.6", v"1.11.6") == :minor
    @test DistSSHUp.julia_version_mismatch_kind(v"1.12.6", v"2.0.6") == :minor
    @test DistSSHUp.julia_version_mismatch_kind(VERSION, VersionNumber(VERSION.major, VERSION.minor + 1, 0)) ==
        :minor

    @test DistSSHUp.juliaup_channel(v"1.12.6") == "1.12"
    @test DistSSHUp.juliaup_channel(VERSION) == "$(VERSION.major).$(VERSION.minor)"

    @test DistSSHUp.juliaup_parent_behind_channel(v"1.12.6", v"1.12.9")
    @test !DistSSHUp.juliaup_parent_behind_channel(v"1.12.9", v"1.12.6")
    @test !DistSSHUp.juliaup_parent_behind_channel(v"1.12.6", v"1.12.6")
    @test !DistSSHUp.juliaup_parent_behind_channel(v"1.12.6", v"1.11.9")
end
