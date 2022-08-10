%%%-------------------------------------------------------------------
%% @doc virtualfs top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(virtualfs_sup).

-behaviour(supervisor).

-include("internal.hrl").

-export([start_link/0]).

-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type, Args), {I, {I, start_link, Args}, permanent, 
                               5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    FileServer = whereis(?FILE_SERVER),
    unregister(?FILE_SERVER),
    {ok, { {one_for_one, 5, 10}, [
                                  ?CHILD(virtualfs_file_server, worker,
                                         [FileServer])
                                 ]} }.

