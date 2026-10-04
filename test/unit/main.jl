@testset "main" begin
    help_path, help_io = mktemp()
    help_code = redirect_stdout(help_io) do
        DistSSHUp.main(["-h"])
    end
    close(help_io)
    help = read(help_path, String)
    @test help_code == 0
    @test occursin("DistSSHUp\n", help)
    @test occursin("julia -m DistSSHUp parent", help)
    @test occursin("child:host1", help)
    @test occursin("julia -m DistSSHUp update", help)
    @test !occursin("qhost", help)

    update_path, update_io = mktemp()
    update_code = redirect_stdout(update_io) do
        DistSSHUp.main(["update", "-h"])
    end
    close(update_io)
    update_help = read(update_path, String)
    @test update_code == 0
    @test occursin("DistSSHUp update\n", update_help)
    @test occursin("julia -m DistSSHUp update parent", update_help)
    @test occursin("update child:host1", update_help)
    @test !occursin("qhost", update_help)

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
    @test occursin("parent", read(empty_path, String))
    @test DistSSHBase.cli_entry() === :DistSSHKit
end
