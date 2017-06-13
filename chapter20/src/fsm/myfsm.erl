%%%-------------------------------------------------------------------
%%% @author ebihebi
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Jun 2017 14:20
%%%-------------------------------------------------------------------
-module(myfsm).
-behaviour(gen_fsm).

-export([init/1, handle_event/3, handle_sync_event/4, handle_info/3, terminate/3, code_change/4, start/0, stop/0, stateA/2]).
-record(state, {name = "begin"}).


start() ->
  gen_fsm:start({local, ?MODULE}, ?MODULE, #state{}, []).

stop() ->
  gen_fsm:stop(?MODULE).

init(S) ->
  {ok, stateA, S}.

stateA(_, S) ->
  io:format("state A is execute, State:~p~n", [S]).

handle_event(Event, StateName, StateData) ->
  erlang:error(not_implemented).

handle_sync_event(Event, From, StateName, StateData) ->
  erlang:error(not_implemented).

handle_info(Info, StateName, StateData) ->
  erlang:error(not_implemented).

terminate(Reason, StateName, StateData) ->
  erlang:error(not_implemented).

code_change(OldVsn, StateName, StateData, Extra) ->
  erlang:error(not_implemented).