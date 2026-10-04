"""Run local `juliaup` with stdout and stderr captured."""
function _juliaup_run_captured(
        ju::AbstractString,
        args::AbstractVector{<:AbstractString},
    )
    out = IOBuffer()
    err = IOBuffer()
    cmd = Cmd(String[String(ju), String.(args)...])
    proc = run(pipeline(ignorestatus(cmd); stdout = out, stderr = err); wait = true)
    return proc, String(take!(out)), String(take!(err))
end

function _juliaup_captured_fail_msg(
        args::AbstractVector{<:AbstractString},
        proc,
        stdout_s::AbstractString,
        stderr_s::AbstractString,
    )::String
    msg = strip(String(stderr_s))
    isempty(msg) && (msg = strip(String(stdout_s)))
    isempty(msg) && (msg = "juliaup $(join(args, " ")) exit $(proc.exitcode)")
    return first(split(msg, '\n'))
end

"""When the default channel and the Julia beside juliaup already match, return that version."""
function _juliaup_local_already_aligned(
        ju::AbstractString,
        channel::AbstractString,
    )::Union{Nothing, VersionNumber}
    ch = String(channel)
    proc, out, _ = _juliaup_run_captured(ju, ["status"])
    proc.exitcode == 0 || return nothing
    default_ch = _juliaup_default_channel_from_status(out)
    default_ch === nothing && return nothing
    default_ch == ch || return nothing
    jl = _local_julia_beside_juliaup(ju)
    isfile(jl) || return nothing
    ver = parse_julia_version(read(`$jl --version`, String))
    ver === nothing && return nothing
    julia_version_mismatch_kind(VERSION, ver) == :minor && return nothing
    return ver
end

"""Run local `juliaup add` / `update` / `default` for `channel`."""
function juliaup_align_local!(
        channel::AbstractString;
        candidates::Vector{String} = local_juliaup_candidates(),
    )::NamedTuple
    ch = String(channel)
    ju = find_local_juliaup(candidates)
    ju === nothing && error(
        "juliaup not found (tried: $(join(candidates, ", ")))",
    )
    if (ver = _juliaup_local_already_aligned(ju, ch)) !== nothing
        return (; ver, changed = false)
    end
    add, add_out, add_err = _juliaup_run_captured(ju, ["add", ch])
    if add.exitcode != 0
        st = sprint() do io
            try
                run(pipeline(Cmd([ju, "status"]); stdout = io, stderr = devnull); wait = true)
            catch
            end
        end
        occursin(ch, st) || error(
            _juliaup_captured_fail_msg(["add", ch], add, add_out, add_err),
        )
    end
    for args in (["update", ch], ["default", ch])
        proc, out_s, err_s = _juliaup_run_captured(ju, args)
        proc.exitcode == 0 || error(_juliaup_captured_fail_msg(args, proc, out_s, err_s))
    end
    jl = _local_julia_beside_juliaup(ju)
    isfile(jl) || error("Julia not found after juliaup align ($jl)")
    out = read(`$jl --version`, String)
    ver = parse_julia_version(out)
    ver === nothing && error("Julia --version unparseable after juliaup align")
    if julia_version_mismatch_kind(VERSION, ver) == :minor
        error("still mismatched after align: process $(VERSION), juliaup default $ver")
    end
    return (; ver, changed = true)
end

const _juliaup_align_local! = juliaup_align_local!

"""Parse a remote Julia version over SSH."""
function _remote_julia_version_setup_ssh(
        host::AbstractString,
        julia_path::AbstractString,
    )::Union{Nothing, VersionNumber}
    pq = _remote_shell_path_word(String(julia_path))
    try
        out = read(
            pipeline(_host_sync_remote_shell_cmd(String(host), "$pq --version"); stderr = devnull),
            String,
        )
        return parse_julia_version(out)
    catch
        return nothing
    end
end

"""Run local `juliaup update` (all installed channels)."""
function juliaup_update_local!(
        candidates::Vector{String} = local_juliaup_candidates(),
    )
    ju = find_local_juliaup(candidates)
    ju === nothing && error(
        "juliaup not found (tried: $(join(candidates, ", ")))",
    )
    proc, out_s, err_s = _juliaup_run_captured(ju, ["update"])
    proc.exitcode == 0 || error(_juliaup_captured_fail_msg(["update"], proc, out_s, err_s))
    return nothing
end

const _juliaup_update_local! = juliaup_update_local!
