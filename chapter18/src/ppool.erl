%%%-------------------------------------------------------------------
%%% @author hebin
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 六月 2017 22:31
%%%-------------------------------------------------------------------
-module(ppool).
-export([start_link/0, stop/0, start_pool/3,
  run/2, sync_queue/2, async_queue/2, stop_pool/1]).

start_link() ->
  ppool_supersup:start_link().

stop() ->
  ppool_supersup:stop().

start_pool(Name, Limit, {M, F, A}) ->
  ppool_supersup:start_pool(Name, Limit, {M, F, A}).

stop_pool(Name) ->
  ppool_supersup:stop_pool(Name).

run(Name, Args) ->
  ChildSpec = {ppool_worker, {ppool_nagger, start_link, Args}, temporary, 5000, worker, [ppool_nagger]},
  ppool_serv:run(Name, ChildSpec).

async_queue(Name, Args) ->
  ppool_serv:async_queue(Name, Args).

sync_queue(Name, Args) ->
  ppool_serv:sync_queue(Name, Args).
