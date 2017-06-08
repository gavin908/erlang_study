%%%-------------------------------------------------------------------
%%% @author ebihebi
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Jun 2017 14:15
%%%-------------------------------------------------------------------
-module(kitty_gen_server).
-compile(export_all).
-behavior(gen_server).

start_link() ->
  gen_server:start_link(?MODULE, [a, b], []).

order_cat(Pid, Name, Color, Description) ->
  gen_server:call(Pid, {order, Name, Color, Description}).

init(Args) ->
  io:format("[~p]Server init is called, Args:~p~n", [self(), Args]),
  {ok, []}.

handle_call(Request, From, State) ->
  io:format("[~p]Server handle a call, Request:~p, State:~p~n", [self(), Request, State]),
  {reply, ["myResult"], State}.

handle_cast(Request, State) ->
  io:format("[~p]Server handle a cast, Request:~p, State:~p~n", [self(), Request, State]),
  {reply, ["myResult"], State}.

handle_info(Info, State) ->
  erlang:error(not_implemented).

terminate(Reason, State) ->
  erlang:error(not_implemented).

code_change(OldVsn, State, Extra) ->
  erlang:error(not_implemented).
