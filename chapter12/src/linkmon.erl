%%%-------------------------------------------------------------------
%%% @author hebin
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 六月 2017 21:59
%%%-------------------------------------------------------------------
-module(linkmon).
-author("hebin").

%% API
-compile(export_all).

start() ->
  true.

base() ->
  spawn(a()).

a() ->
  io:format("[~w]a process started.~n", [self()]),
  try
    link(spawn(b())),
    io:format("[~w]a linked b", [self()])
  catch
    exit:Reason -> io:format("[~w]catch a exit(~w)", [self(), Reason]), a()
  end,
  io:format("[~w]a execute over, time:~w~n", [self(), now()]).
%timer:sleep(100000).

b() ->
  io:format("[~w]b want to sleep 5 seconds. start from:~w~n", [self(), now()]),
  timer:sleep(5000),
  io:format("[~w]b sleep over.~n", [self()]),
  try
    exit(reason)
  after
    io:format("[~w]b exit~n", [self()])
  end.


c() ->
  List = {11, 22, 33, 44, 55},
  Sum = 32,
  io:format("the sum of ~w is ~w.~n", [List, Sum]).