@testset "main" begin
    help_path, help_io = mktemp()
    help_code = redirect_stdout(help_io) do
        DistSSHUp.main(["-h"])
    end
    close(help_io)
    help = read(help_path, String)
    @test help_code == 0
    @test occursin("DistSSHUp\n", help)
    @test occursin("julia -m DistSSHUp add 1.13 parent", help)
    @test occursin("default 1.13", help)
    @test occursin("update 1.13 child:host1", help)
    @test occursin("status parent", help)
    @test !occursin("qhost", help)

    parsed = DistSSHUp._parse_command(["update", "child:host1"])
    @test parsed.verb == "update"
    @test parsed.channel === nothing
    @test parsed.hosts == ["host1"]
    parsed = DistSSHUp._parse_command(["update", "1.13", "parent", "child:host1:2"])
    @test parsed.channel == "1.13"
    @test parsed.hosts == ["parent", "host1"]
    parsed = DistSSHUp._parse_command(["add", "release", "parent"])
    @test parsed.verb == "add" && parsed.channel == "release"
    @test_throws ArgumentError DistSSHUp._parse_command(["add", "parent"])
    @test_throws ArgumentError DistSSHUp._parse_command(["default"])
    @test_throws ArgumentError DistSSHUp._parse_command(["status"])

    ver_path, ver_io = mktemp()
    ver_code = redirect_stdout(ver_io) do
        DistSSHUp.main(["--version"])
    end
    close(ver_io)
    @test ver_code == 0
    @test startswith(read(ver_path, String), "DistSSHUp ")

    err_path, err_io = mktemp()
    bad = redirect_stderr(err_io) do
        DistSSHUp.main(["bogus"])
    end
    close(err_io)
    @test bad == 1
    @test occursin("bogus", read(err_path, String))

    empty_path, empty_io = mktemp()
    empty_code = redirect_stdout(empty_io) do
        DistSSHUp.main(String[])
    end
    close(empty_io)
    @test empty_code == 1
    @test occursin("add 1.13", read(empty_path, String))
    @test DistSSHBase.cli_entry() === :DistSSHKit
end
