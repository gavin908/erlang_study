%%%-------------------------------------------------------------------
%%% @author ebihebi
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Jun 2017 15:41
%%%-------------------------------------------------------------------
-module(my_supervisor).
-behaviour(supervisor).

%% API
-export([init/1, start_link/2, run_worker/0, stop/0]).


init({dynamic, _Cnt}) ->
  MaxRestart = 6,
  MaxTime = 3600,
  {ok, {one_for_one, MaxRestart, MaxTime}};
init({static, Cnt}) ->
  MaxRestart = 2,
  MaxTime = 3600,
  {ok, {{one_for_one, MaxRestart, MaxTime},
    [{my_worker1, {worker, start_link, [Cnt]},
      permanent,
      5000,
      worker,
      [my_worker_module]}]}}.

start_link(Type, Cnt) ->
  Args = {Type, Cnt},
  supervisor:start_link({local, mySupervisor}, ?MODULE, Args).

stop() ->
  case whereis(mySupervisor) of
    P when is_pid(P) ->
      exit(P, kill);
    _ -> ok
  end.

run_worker() ->
  ChildSpec = {my_worker2, {worker, start_link, [10]},
    permanent,
    5000,
    worker,
    [my_worker_module]},
  supervisor:start_child(mySupervisor, ChildSpec).