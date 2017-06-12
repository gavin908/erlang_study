%%%-------------------------------------------------------------------
%%% @author hebin
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 六月 2017 22:35
%%%-------------------------------------------------------------------
-module(ppool_nagger).
-behaviour(gen_server).
-export([start_link/4, stop/1]).
-export([init/1, handle_call/3, handle_cast/2,
  handle_info/2, code_change/3, terminate/2]).

start_link(Task, Delay, Max, SendTo) ->
  io:format("[~p]The pool worker start_link.~nparam:~p~n", [self(), {Task, Delay, Max, SendTo}]),
  gen_server:start_link(?MODULE, {Task, Delay, Max, SendTo}, []).

stop(Pid) ->
  gen_server:call(Pid, stop).


init({Task, Delay, Max, SendTo}) ->
  io:format("[~p]The pool worker inited, param:~p~n", [self(), {Task, Delay, Max, SendTo}]),
  {ok, {Task, Delay, Max, SendTo}, Delay}.

%%% OTP Callbacks
handle_call(stop, _From, State) ->
  {stop, normal, ok, State};
handle_call(_Msg, _From, State) ->
  {noreply, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(timeout, P = {Task, Delay, Max, SendTo}) ->
  io:format("[~p]The pool worker handle a info, param:~p~n", [self(), P]),
  SendTo ! {self(), Task},
  if Max =:= infinity ->
    {noreply, {Task, Delay, Max, SendTo}, Delay};
    Max =< 1 ->
      {stop, normal, {Task, Delay, 0, SendTo}};
    Max > 1 ->
      {noreply, {Task, Delay, Max - 1, SendTo}, Delay}
  end.
%% We cannot use handle_info below: if that ever happens,
%% we cancel the timeouts (Delay) and basically zombify
%% the entire process. It's better to crash in this case.
%% handle_info(_Msg, State) ->
%%    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

terminate(_Reason, _State) -> ok.
