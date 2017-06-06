%%%-------------------------------------------------------------------
%%% @author ebihebi
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. Jun 2017 14:34
%%%-------------------------------------------------------------------
-module(kitty_server).
-author("ebihebi").

%% API
%% -export([]).
-compile(export_all).

-record(cat, {name, color = green, description}).


start_link() -> spawn_link(fun init/0).

order_cat(Pid, Name, Color, Description) ->
  Ref = erlang:monitor(process, Pid),
  Pid ! {self(), Ref, {order, Name, Color, Description}},
  receive
    {Ref, Cat} ->
      erlang:demonitor(Ref, [flush]),
      Cat;
    {'DOWN', Ref, process, Pid, Reason} ->
      erlang:error(Reason)
  after 500 ->
    erlang:error(timeout)
  end.

return_cat(Pid, Cat = #cat{}) ->
  Pid ! {return, Cat},
  ok.

show(Pid) ->
  Pid ! show,
 ok.

close_shop(Pid) ->
  Ref = erlang:monitor(process, Pid),
  Pid ! {self(), Ref, terminate},
  receive
    {Ref, ok} ->
      erlang:demonitor(Ref, [flush]),
      ok;
    {'DOWN', Ref, process, Pid, Reason} ->
      erlang:error(Reason)
  after 500 ->
    erlang:error(timeout)
  end.

init() ->
  io:format("[~p]Cat shop is going to init.~n", [self()]),
  loop([]).

loop(Cats) ->
  io:format("[~p]Cat shop is waiting for customers. Cats~p~n", [self(), Cats]),
  receive
    {Pid, Ref, {order, Name, Color, Description}} ->
      if Cats =:= [] ->
        Pid ! {Ref, make_cat(Name, Color, Description)},
        loop(Cats);
        Cats =/= [] ->
          Pid ! {Ref, hd(Cats)},
          loop(tl(Cats))
      end;
    {return, Cat = #cat{}} ->
      loop([Cat | Cats]);
    {Pid, Ref, terminate} ->
      Pid ! {Ref, ok},
      terminate(Cats);
    show ->
      io:format("[~p]Cat shop have cats~p~n", [self(), Cats]),
      loop(Cats);
    Unknown ->
      io:format("Unknown message: ~p~n", [Unknown]),
      loop(Cats)
  end.

make_cat(Name, Color, Description) ->
  #cat{name = Name, color = Color, description = Description}.

terminate(Cats) ->
  io:format("[~p]kitty shop is going to terminate.~n", [self()]),
  [io:format("[~p]~p was set free.~n", [self(), C#cat.name]) || C <- Cats],
  ok.

