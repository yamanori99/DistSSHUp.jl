# `julia -m DistSSHUp parent child:host`. Confirm text and progress stay in DistSSHRun.

function _pkg_version()::String
    root = pkgdir(DistSSHUp)
    root === nothing && return "0.1.0"
    for line in eachline(joinpath(root, "Project.toml"))
        m = match(r"^version\s*=\s*\"([^\"]+)\"", line)
        m === nothing && continue
        cap = m.captures[1]
        cap === nothing && continue
        return String(cap)
    end
    return "0.1.0"
end

function print_main_usage(io::IO = stdout)
    DistSSHBase.print_help_chrome(string(DistSSHBase.cli_entry()); io = io)
    DistSSHBase.print_help_section("Usage"; io = io)
    m = DistSSHBase.cli_m()
    DistSSHBase.print_help_lines(
        io,
        "  $m add 1.13 parent child:host1",
        "  $m default 1.13 parent",
        "  $m update parent",
        "  $m update 1.13 child:host1",
        "  $m status parent",
        "  $m status 1.13 parent",
    )
    DistSSHBase.print_help_blank(io)
    DistSSHBase.print_help_lines(
        io,
        "  add installs a channel. default switches to it.",
        "  update with no channel updates every installed channel.",
        "  status prints installed channels. parent is this machine.",
        "  child:NAME is SSH. :N is ignored.",
    )
    return nothing
end

function _host_token(arg::AbstractString)::Bool
    a = String(arg)
    return a == "parent" || startswith(a, "parent:") || startswith(a, "child:")
end

"""Verb, optional channel, and host names. `add` and `default` require a channel."""
function _parse_command(args::Vector{String})
    isempty(args) && throw(ArgumentError("missing command"))
    verb = String(args[1])
    verb in ("add", "default", "update", "status") ||
        throw(ArgumentError("unknown command: $verb"))
    rest = String.(args[2:end])
    any(startswith(a, "-") for a in rest) &&
        throw(ArgumentError("unknown argument: $(first(a for a in rest if startswith(a, "-")))"))
    channel = nothing
    hostargs = rest
    if verb in ("add", "default")
        isempty(rest) && throw(ArgumentError("$verb needs a channel"))
        _host_token(rest[1]) && throw(ArgumentError("$verb needs a channel"))
        channel = rest[1]
        hostargs = rest[2:end]
    elseif !isempty(rest) && !_host_token(rest[1])
        channel = rest[1]
        hostargs = rest[2:end]
    end
    isempty(hostargs) && throw(ArgumentError("missing host"))
    hosts = String[]
    for a in hostargs
        _host_token(a) || throw(ArgumentError("$(repr(a)): expected parent or child:NAME"))
        p = DistSSHBase.parse_placement_token(a)
        name = p.role === :parent ? DistSSHBase.PARENT_HOST_NAME : p.name
        name in hosts || push!(hosts, name)
    end
    return (; verb, channel, hosts)
end

function _run_command(parsed)::Cint
    failed = false
    for host in parsed.hosts
        try
            if parsed.verb == "add"
                juliaup_add_host!(host, parsed.channel)
                println("$host: added $(parsed.channel)")
            elseif parsed.verb == "default"
                juliaup_default_host!(host, parsed.channel)
                println("$host: default $(parsed.channel)")
            elseif parsed.verb == "update"
                juliaup_update_host!(host; channel = parsed.channel)
                if parsed.channel === nothing
                    println("$host: updated")
                else
                    println("$host: updated $(parsed.channel)")
                end
            else
                lines = juliaup_status_lines(host; channel = parsed.channel)
                if isempty(lines)
                    println("$host: (none)")
                else
                    for line in lines
                        println("$host: $line")
                    end
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
    if isempty(args) || any(a -> a in ("-h", "--help", "help"), args)
        print_main_usage()
        return isempty(args) ? 1 : 0
    end
    parsed = try
        _parse_command(args)
    catch err
        err isa ArgumentError || rethrow()
        println(stderr, err.msg)
        print_main_usage()
        return 1
    end
    return _run_command(parsed)
end

"""Run juliaup `add`, `default`, `update`, or `status` on `parent` and `child:NAME`."""
function main(args::Vector{String} = copy(ARGS))::Cint
    return DistSSHBase.with_cli_entry(:DistSSHUp) do
        _main(args)
    end
end
