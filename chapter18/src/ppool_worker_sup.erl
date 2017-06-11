%%%-------------------------------------------------------------------
%%% @author hebin
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 六月 2017 22:50
%%%-------------------------------------------------------------------
-module(ppool_worker_sup).
-behavior(supervisor).
%% API
-export([init/1, start_link/1]).

init({M, F, A}) ->
  MaxRestart = 5,
  MaxTime = 3600,
  {ok, {
    {simple_one_for_one, MaxRestart, MaxTime},
    [
      {ppool_worker, {M, F, A}, temporary, 5000, worker, [M]}
    ]
  }}.


start_link(MFA = {_, _, _}) ->
  supervisor:start_link(?MODULE, MFA).