%%%-------------------------------------------------------------------
%%% @author hebin
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 六月 2017 20:52
%%%-------------------------------------------------------------------
-module(mylogger).
-behavior(gen_event).

-export([init/1, handle_event/2, handle_call/2, handle_info/2, terminate/2, code_change/3, start/1, debug/1]).

start(Name) ->
  gen_event:start({local, logger_server}),
  gen_event:add_handler(logger_server, mylogger, [Name]).

debug(Msg) ->
  gen_event:notify(logger_server, Msg).

init(Name) ->
  io:format("logger(~p) inited!~n", [Name]),
  {ok, Name}.

handle_event(Event, Name) ->
  io:format("logger(~p) handle a event(~p)!~n", [Name, Event]),
  {ok, Name}.

handle_call(Request, Name) ->
  io:format("logger(~p) handle a call(~p)!~n", [Name, Request]),
  {ok, Name}.

handle_info(Info, Name) ->
  io:format("logger(~p) handle a info(~p)!~n", [Name, Info]),
  {ok, Name}.

terminate(_Args, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.