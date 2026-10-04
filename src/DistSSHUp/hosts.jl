# add / update / default on `parent` and on a child SSH host.
# Confirm text and progress stay in DistSSHRun.

function _juliaup_remote_capture(host::AbstractString, script::AbstractString)
    out_buf = IOBuffer()
    err_buf = IOBuffer()
    proc = run(
        pipeline(
            ignorestatus(_host_sync_remote_shell_cmd(String(host), String(script)));
            stdout = out_buf,
            stderr = err_buf,
        );
        wait = true,
    )
    out_s = strip(String(take!(out_buf)))
    err_s = strip(String(take!(err_buf)))
    if proc.exitcode != 0
        msg = err_s
        isempty(msg) && (msg = out_s)
        isempty(msg) && (msg = "exit $(proc.exitcode)")
        error(first(split(msg, '\n')))
    end
    return out_s
end

"""
`juliaup add` / `update` / `default` for one target.

`parent` is this machine. Anything else is an SSH host. Returns
`(host, channel, already, ver)`. `ver` is `nothing` when a child was already
on the channel.
"""
function juliaup_align_host!(
        host::AbstractString;
        channel::AbstractString = juliaup_channel(),
    )
    h = String(host)
    ch = String(channel)
    if DistSSHBase.is_parent_host_name(h)
        r = juliaup_align_local!(ch)
        return (;
            host = DistSSHBase.PARENT_HOST_NAME,
            channel = ch,
            already = !r.changed,
            ver = r.ver,
        )
    end
    out = _juliaup_remote_capture(h, _juliaup_align_remote_sh(ch))
    if out == "already"
        return (; host = h, channel = ch, already = true, ver = nothing)
    end
    DistSSHBase.clear_detect_julia_path_cache!(h)
    path = DistSSHBase.detect_julia_path(h)
    path === nothing && error("Julia not found after juliaup align")
    ver = _remote_julia_version_setup_ssh(h, path)
    ver === nothing && error("Julia --version unparseable after juliaup align")
    if julia_version_mismatch_kind(VERSION, ver) == :minor
        error("still mismatched after align: process $(VERSION), remote $ver")
    end
    return (; host = h, channel = ch, already = false, ver = ver)
end

"""Installed patch of the juliaup default on `host`, or `-`.

`parent` is this machine. Anything else is an SSH host. Missing juliaup, a
failed `status`, or no Version column is `-`.
"""
function juliaup_default_patch(host::AbstractString)::String
    h = String(host)
    if DistSSHBase.is_parent_host_name(h)
        ju = find_local_juliaup()
        ju === nothing && return "-"
        proc, out, _ = _juliaup_run_captured(ju, ["status"])
        Int(something(proc.exitcode, 1)) == 0 || return "-"
        return _juliaup_patch_from_status(out)
    end
    try
        out_buf = IOBuffer()
        proc = run(
            pipeline(
                ignorestatus(_host_sync_remote_shell_cmd(h, _juliaup_status_sh()));
                stdout = out_buf,
                stderr = devnull,
            );
            wait = true,
        )
        Int(something(proc.exitcode, 1)) == 0 || return "-"
        return _juliaup_patch_from_status(String(take!(out_buf)))
    catch
        return "-"
    end
end

"""`juliaup update` on `parent` or one SSH host. Does not change the default."""
function juliaup_update_host!(host::AbstractString)
    h = String(host)
    if DistSSHBase.is_parent_host_name(h)
        juliaup_update_local!()
        return (; host = DistSSHBase.PARENT_HOST_NAME)
    end
    _juliaup_remote_capture(h, _juliaup_update_remote_sh())
    return (; host = h)
end
