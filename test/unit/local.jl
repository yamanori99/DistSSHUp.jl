using Test

@testset "local juliaup" begin
    mktempdir() do d
        ju = joinpath(d, "juliaup")
        jl = joinpath(d, "julia")
        write(
            ju, """
            #!/bin/sh
            case "\$1" in
              add|update|default)
                echo "Checking for new Julia versions" >&2
                echo "'1.13' is already installed."
                exit 0
                ;;
              status) echo "1.12"; exit 0 ;;
              *) exit 1 ;;
            esac
            """
        )
        write(
            jl, """
            #!/bin/sh
            echo "julia version $(VERSION.major).$(VERSION.minor).$(VERSION.patch)"
            """
        )
        chmod(ju, 0o755)
        chmod(jl, 0o755)
        withenv("DISTSSHKIT_TEST_LOCAL_JULIAUP" => ju) do
            @test DistSSHUp.find_local_juliaup() == ju
            ch = "$(VERSION.major).$(VERSION.minor)"
            r = nothing
            captured = mktemp() do path, io
                redirect_stdout(io) do
                    redirect_stderr(io) do
                        r = DistSSHUp.juliaup_align_local!(ch)
                    end
                end
                flush(io)
                return read(path, String)
            end
            @test r.changed
            @test DistSSHUp.julia_version_mismatch_kind(VERSION, r.ver) != :minor
            @test !occursin("Checking for new Julia versions", captured)
        end
    end

    mktempdir() do d
        ju = joinpath(d, "juliaup")
        jl = joinpath(d, "julia")
        ch = "$(VERSION.major).$(VERSION.minor)"
        write(
            ju,
            """
            #!/bin/sh
            case "\$1" in
              status) echo '       *  $ch     julia version'; exit 0 ;;
              add|update|default) echo "unexpected \$1" >&2; exit 1 ;;
              *) exit 1 ;;
            esac
            """,
        )
        write(
            jl,
            """
            #!/bin/sh
            echo "julia version $(VERSION.major).$(VERSION.minor).$(VERSION.patch)"
            """,
        )
        chmod(ju, 0o755)
        chmod(jl, 0o755)
        withenv("DISTSSHKIT_TEST_LOCAL_JULIAUP" => ju) do
            r = DistSSHUp.juliaup_align_local!(ch)
            @test !r.changed
            @test DistSSHUp.julia_version_mismatch_kind(VERSION, r.ver) != :minor
        end
    end

    mktempdir() do d
        ju = joinpath(d, "juliaup")
        jl = joinpath(d, "julia")
        write(
            ju, """
            #!/bin/sh
            case "\$1" in
              add) echo "network failed"; exit 1 ;;
              status) echo "empty"; exit 0 ;;
              *) exit 1 ;;
            esac
            """
        )
        write(
            jl, """
            #!/bin/sh
            echo "julia version $(VERSION.major).$(VERSION.minor).$(VERSION.patch)"
            """
        )
        chmod(ju, 0o755)
        chmod(jl, 0o755)
        withenv("DISTSSHKIT_TEST_LOCAL_JULIAUP" => ju) do
            err = try
                DistSSHUp.juliaup_align_local!("$(VERSION.major).$(VERSION.minor)")
                nothing
            catch e
                sprint(showerror, e)
            end
            @test err !== nothing
            @test occursin("network failed", err)
        end
    end
end
