%%%-------------------------------------------------------------------
%% @doc virtualfs public API
%% @end
%%%-------------------------------------------------------------------

-module(virtualfs_app).

-behaviour(application).

-include("internal.hrl").

-export([start/2, prep_stop/1, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    {ok, Pid} = virtualfs_sup:start_link(),
    {ok, OriginalFilename} = virtualfs_filename:load(),
    {virtualfs_file_server, FileServer, _Type, _Modules} = 
        lists:keyfind(virtualfs_file_server, 1, supervisor:which_children(Pid)),
    {ok, Pid, {FileServer, virtualfs:original_file_server(FileServer), OriginalFilename}}.

prep_stop({_FileServer, _OriginalFileServer, Filename} = State) ->
    ok = virtualfs_filename:unload(Filename),
    State.

stop({_FileServer, OriginalFileServer, _Filename}) ->
    true = register(?FILE_SERVER, OriginalFileServer),
    ok.
