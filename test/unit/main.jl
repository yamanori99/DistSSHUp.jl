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
    @test_throws ArgumentError DistSSHUp._parse_command(["update", "1.13"])
    @test_throws ArgumentError DistSSHUp._parse_command(["add", "1.13", "parent", "--yes"])
    @test_throws ArgumentError DistSSHUp._parse_command(["status", "parent", "nope"])
    collapsed = DistSSHUp._parse_command(["status", "parent", "parent:4", "child:h", "child:h:2"])
    @test collapsed.channel === nothing
    @test collapsed.hosts == ["parent", "h"]
    nightly = DistSSHUp._parse_command(["status", "nightly", "child:h"])
    @test nightly.channel == "nightly"
    @test nightly.hosts == ["h"]

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

    mktempdir() do d
        ju = joinpath(d, "juliaup")
        write(
            ju,
            """
            #!/bin/sh
            case "\$1" in
              --version) echo 'Juliaup 1.22.7'; exit 0 ;;
              status) echo '      1.13     1.13.2+0'; exit 0 ;;
              add) exit 0 ;;
              *) exit 1 ;;
            esac
            """,
        )
        chmod(ju, 0o755)
        ssh = joinpath(d, "ssh.jl")
        write(
            ssh,
            """
            println(stderr, "juliaup not found")
            exit(1)
            """,
        )
        withenv(
            "DISTSSHKIT_TEST_LOCAL_JULIAUP" => ju,
            "DISTSSHKIT_TEST_SSH" => ssh,
        ) do
            add_out_path, add_out_io = mktemp()
            add_err_path, add_err_io = mktemp()
            code = redirect_stdout(add_out_io) do
                redirect_stderr(add_err_io) do
                    DistSSHUp.main(["add", "1.13", "parent", "child:host1"])
                end
            end
            close(add_out_io)
            close(add_err_io)
            @test code == 1
            @test occursin("parent: added 1.13", read(add_out_path, String))
            @test occursin("host1: juliaup not found", read(add_err_path, String))

            st_path, st_io = mktemp()
            st_code = redirect_stdout(st_io) do
                DistSSHUp.main(["status", "1.13", "parent"])
            end
            close(st_io)
            @test st_code == 0
            @test occursin("parent: 1.13", read(st_path, String))
        end
    end
end
