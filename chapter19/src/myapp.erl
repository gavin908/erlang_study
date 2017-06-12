%%%-------------------------------------------------------------------
%%% @author hebin
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 六月 2017 20:50
%%%-------------------------------------------------------------------
-module(myapp).
-behavior(gen_server).
-behavior(application).
-import(mylogger, [start/1, debug/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3, start_link/0, start/2, stop/1]).
-record(state, {name = myapp_server, count = 10, delay = 1000}).

start_link() ->
  gen_server:start_link(?MODULE, #state{}, []).


init(S = #state{}) ->
  io:format("my app(~p) inited!~n", [S#state.name]),
  mylogger:start("com.erlang.app"),
  {ok, S, S#state.delay}.

handle_call(Request, _From, S) ->
  io:format("my app(~p) handle a call(~p)!~n", [S#state.name, Request]),
  {noreply, S}.

handle_cast(Request, S) ->
  io:format("my app(~p) handle a cast(~p)!~n", [S#state.name, Request]),
  {noreply, S}.

handle_info(Info, S) ->
  io:format("my app(~p) handle a info(~p), Count:~p!~n", [S#state.name, Info, S#state.count]),
  case S#state.count > 0 of
    true -> mylogger:debug(string:concat("print a debug message:", S#state.count)),
      {noreply, S#state{count = S#state.count - 1}, S#state.delay};
    false -> {stop, normal, S}
  end.

terminate(_R, _S) ->
  ok.

code_change(_OldVsn, _State, _Extra) ->
  ok.

%%------------- application behavior ------------
start(normal, _StartArgs) ->
  io:format("the application will start!~n"),
  start_link().

stop(_State) ->
  ok.