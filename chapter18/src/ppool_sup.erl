%%%-------------------------------------------------------------------
%%% @author hebin
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 六月 2017 22:38
%%%-------------------------------------------------------------------
-module(ppool_sup).
-behavior(supervisor).

%% API
-export([init/1]).
-export([start_link/3]).

%%-------------------------------------------
init({Name, Limit, MFA}) ->
  MaxRestart = 1,
  MaxTime = 3600,
  io:format("[~p]The pool supervisor inited.~n", [self()]),
  {ok, {{one_for_all, MaxRestart, MaxTime},
    [{serv, {ppool_serv, start_link, [Name, Limit, self(), MFA]},
      permanent,
      5000,
      worker,
      [ppool_serv]}]}}.
%%-------------------------------------------

start_link(Name, Limit, MFA) ->
  supervisor:start_link(?MODULE, {Name, Limit, MFA}).


