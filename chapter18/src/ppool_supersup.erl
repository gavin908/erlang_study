%%%-------------------------------------------------------------------
%%% @author hebin
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 六月 2017 09:19
%%%-------------------------------------------------------------------
-module(ppool_supersup).
-author("hebin").
-behavior(supervisor).
-export([init/1]).

-export([start_link/0, stop/0, start_pool/3, stop_pool/1]).

init([]) ->
    io:format("[~p]The super supervisor init~n", [self()]),
    MaxRestart = 6,
    MaxTime = 3600,
    {ok, {{one_for_one, MaxRestart, MaxTime}, []}}.
%%--------------------------------------------------

start_link() ->
    supervisor:start_link({local, ppool}, ?MODULE, []).

stop() ->
    case whereis(ppool) of
        P when is_pid(P) ->
            exit(P, kill);
        _ -> ok
    end.

start_pool(Name, Limit, MFA) ->
    ChildSpec = {Name, {ppool_sup, start_link, [Name, Limit, MFA]}, permanent, 10500, supervisor, [ppool_sup]},
    io:format("[~p]The super supervisor want to start pool, param:~p~n", [self(), ChildSpec]),
    supervisor:start_child(ppool, ChildSpec).

stop_pool(Name) ->
    supervisor:terminate_child(ppool, Name),
    supervisor:delete_child(ppool, Name).
