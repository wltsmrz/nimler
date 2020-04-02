
main(_) ->
    io:format("~s/erts-~s/include/\n", [code:root_dir(), erlang:system_info(version)]),
    io:format("~s", [erlang:system_info(nif_version)]).
