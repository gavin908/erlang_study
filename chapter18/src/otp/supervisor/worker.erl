%%%-------------------------------------------------------------------
%%% @author ebihebi
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Jun 2017 15:43
%%%-------------------------------------------------------------------
-module(worker).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3, start_link/1]).
-record(state, {name = "MyWorker", count = 10, delay = 1000}).

start_link(Cnt) ->
  io:format("The Worker Server will start.~n"),
  gen_server:start_link(?MODULE, #state{count = Cnt}, []).

init(S) ->
  io:format("The Worker Server inited.~n"),
  {ok, S, S#state.delay}.

handle_call(Request, From, State) ->
  erlang:error(not_implemented).

handle_cast(Request, State) ->
  erlang:error(not_implemented).

handle_info(Info, State) ->
  io:format("The Worker Server handle a info[~p], ~p.~n", [Info, State]),
  case State#state.count > 0 of
    true -> {noreply, #state{count = State#state.count - 1}, State#state.delay};
    false -> {stop, normal, State}
  end.

terminate(_Reason, _State) ->
  io:format("The worker will exit!~n"),
  ok.

code_change(OldVsn, State, Extra) ->
  erlang:error(not_implemented).