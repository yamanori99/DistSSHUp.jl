if !isdefined(Main, :_with_tempdir)
    # Isolated temp directory, removed after `f(path)` returns.
    function _with_tempdir(f::Function)
        path = abspath(string(mktempdir()))
        try
            return f(path)
        finally
            rm(path; recursive = true, force = true)
        end
    end
end
