%%%-------------------------------------------------------------------
%%% @author hebin
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 六月 2017 19:41
%%%-------------------------------------------------------------------
-module(event).
-author("hebin").
-compile(export_all).
-record(state, {server, name = "", to_go = 0}).


%% API
%-export([]).
loop(S = #state{server = Server, to_go = [T | Next]}) ->
  io:format("loop called, to_go[~w].~n", [S#state.to_go]),
  receive
    {Server, Ref, cancel} ->
      Server ! {Ref, ok}
  after T * 1000 ->
    if Next =:= [] ->
      io:format("timeout totally arrived.~n"),
      Server ! {done, S#state.name};
      Next =/= [] ->
        io:format("timeout partially arrived.~n"),
        loop(S#state{to_go = Next})
    end
  end.

%% 由于Erlang受49天的时间限制。因此需要使用这个函数
normalize(N) ->
  Limit = 49 * 24 * 60 * 60,
  [N rem Limit | lists:duplicate(N div Limit, Limit)].

start(EventName, Delay) ->
  spawn(?MODULE, init, [self(), EventName, Delay]).

start_link(EventName, Delay) ->
  spawn_link(?MODULE, init, [self(), EventName, Delay]).

%% 事件模块的内部实现
init(Server, EventName, Delay) ->
  loop(#state{server = Server, name = EventName, to_go = normalize(Delay)}).


cancel(Pid) ->
  io:format("we want to cancel Event[~w].~n", [Pid]),
  Ref = erlang:monitor(process, Pid),
  Pid ! {self(), Ref, cancel},
  receive
    {Ref, ok} ->
      erlang:demonitor(Ref, [flush]),
      ok;
    {'DOWN', Ref, process, Pid, _Reason} ->
      ok
  end.

