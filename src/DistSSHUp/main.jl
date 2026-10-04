# `julia -m DistSSHUp parent child:host`. Confirm text and progress stay in DistSSHRun.

function _pkg_version()::String
    for line in eachline(joinpath(pkgdir(DistSSHUp), "Project.toml"))
        m = match(r"^version\s*=\s*\"([^\"]+)\"", line)
        m === nothing || return String(m.captures[1])
    end
    return "0.1.0"
end

function print_main_usage(io::IO = stdout; update::Bool = false)
    title = update ? DistSSHBase.cli_heading("update") : string(DistSSHBase.cli_entry())
    DistSSHBase.print_help_chrome(title; io = io)
    DistSSHBase.print_help_section("Usage"; io = io)
    if update
        DistSSHBase.print_help_lines(
            io,
            "  $(DistSSHBase.cli_m()) update parent",
            "  $(DistSSHBase.cli_m()) update child:host1",
        )
        DistSSHBase.print_help_blank(io)
        DistSSHBase.print_help_lines(
            io,
            "  juliaup update on each target. Does not change the default.",
            "  parent is this machine. child:NAME is SSH. :N is ignored.",
        )
    else
        DistSSHBase.print_help_lines(
            io,
            "  $(DistSSHBase.cli_m()) parent child:host1",
            "  $(DistSSHBase.cli_m()) update parent",
        )
        DistSSHBase.print_help_blank(io)
        DistSSHBase.print_help_lines(
            io,
            "  juliaup add, update, and default on each target.",
            "  parent is this machine. child:NAME is SSH. :N is ignored.",
        )
    end
    return nothing
end

function _hosts_from(args::Vector{String})::Vector{String}
    hosts = String[]
    for a in args
        startswith(a, "-") && throw(ArgumentError("unknown argument: $a"))
        p = DistSSHBase.parse_placement_token(a)
        name = p.role === :parent ? DistSSHBase.PARENT_HOST_NAME : p.name
        name in hosts || push!(hosts, name)
    end
    return hosts
end

function _run_hosts(hosts::Vector{String}; update::Bool)::Cint
    failed = false
    for host in hosts
        try
            if update
                juliaup_update_host!(host)
                println("$host: updated")
            else
                result = juliaup_align_host!(host)
                if result.already
                    println("$(result.host): already on $(result.channel)")
                else
                    println("$(result.host): aligned to $(result.ver)")
                end
            end
        catch err
            err isa ErrorException || rethrow()
            println(stderr, "$host: $(err.msg)")
            failed = true
        end
    end
    return failed ? 1 : 0
end

function _main(args::Vector{String})::Cint
    if length(args) == 1 && args[1] in ("--version", "-v", "-V")
        println("DistSSHUp $(_pkg_version())")
        return 0
    end
    update = false
    rest = args
    if !isempty(args) && args[1] == "update"
        update = true
        rest = args[2:end]
    end
    if any(a -> a in ("-h", "--help", "help"), rest)
        print_main_usage(; update = update)
        return 0
    end
    hosts = try
        _hosts_from(rest)
    catch err
        err isa ArgumentError || rethrow()
        println(stderr, err.msg)
        print_main_usage(; update = update)
        return 1
    end
    if isempty(hosts)
        print_main_usage(; update = update)
        return 1
    end
    return _run_hosts(hosts; update = update)
end

"""Align `parent` and `child:NAME`, or `update` to run `juliaup update` only."""
function main(args::Vector{String} = copy(ARGS))::Cint
    return DistSSHBase.with_cli_entry(:DistSSHUp) do
        _main(args)
    end
end
