%%%-------------------------------------------------------------------
%%% @author hebin
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 六月 2017 15:44
%%%-------------------------------------------------------------------
-module(ppool_serv).
-behavior(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start/4, start_link/4, run/2, sync_queue/2, async_queue/2, stop/1]).

%%-----------------------------------------
start(Name, Limit, Sup, MFA) when is_atom(Name), is_integer(Limit) ->
  gen_server:start({local, Name}, ?MODULE, {Limit, MFA, Sup}, []).

start_link(Name, Limit, Sup, MFA) when is_atom(Name), is_integer(Limit) ->
  gen_server:start_link({local, Name}, ?MODULE, {Limit, MFA, Sup}, []).

run(Name, Args) ->
  gen_server:call(Name, {run, Args}).

sync_queue(Name, Args) ->
  gen_server:call(Name, {sync, Args}, infinity).

async_queue(Name, Args) ->
  gen_server:cast(Name, {async, Args}).

stop(Name) ->
  gen_server:call(Name, stop).

%%-----------------------------------------
-define(SPEC(MFA), {worker_sup,
  {ppool_worker_sup, start_link, [MFA]},
  permanent, 10000, supervisor, [ppool_worker_sup]}).

-record(state, {limit = 0, sup, refs, queue = queue:new()}).
%%-----------------------------------------
init(P = {Limit, MFA, Sup}) ->
  %% {ok, Pid} = supervisor:start_child(Sup, ?SPEC(MFA)),
  %% %% 这里会死锁，在gen_*行为中，启动该行为的进程会一直等到init/1函数返回才会恢复运行。
  self() ! {start_worker_supervisor, Sup, MFA},
  io:format("[~p]The pool server inited, param: ~p~n", [self(), P]),
  {ok, #state{limit = Limit, refs = gb_sets:empty(), sup = Sup}}.

handle_call(P = {run, Args}, _From, S = #state{limit = N, sup = Sup, refs = R}) when N > 0 ->
  io:format("[~p]The pool Server handle a call, Param:~p Status:~p~n", [self(), P, S]),
  {ok, Pid} = supervisor:start_child(Sup, Args),
  Ref = erlang:monitor(process, Pid),
  {reply, {ok, Pid}, S#state{limit = N - 1, refs = gb_sets:add(Ref, R)}};
handle_call(P = {run, _Args}, _From, S = #state{limit = N}) when N =< 0 ->
  io:format("[~p]The pool Server handle a call, Param:~p Status:~p~n", [self(), P, S]),
  {reply, noalloc, S};
handle_call({sync, Args}, _From, S = #state{limit = N, sup = Sup, refs = R}) when N > 0 ->
  {ok, Pid} = supervisor:start_child(Sup, Args),
  Ref = erlang:monitor(process, Pid),
  {reply, {ok, Pid}, S#state{limit = N - 1, refs = gb_sets:add(Ref, R)}};
handle_call({sync, Args}, From, S = #state{queue = Q}) ->
  {noreply, S#state{queue = queue:in({From, Args}, Q)}};
handle_call(stop, _From, State) ->
  {stop, normal, ok, State};
handle_call(_Msg, _From, State) ->
  {noreply, State}.


handle_cast({async, Args}, S = #state{limit = N, sup = Sup, refs = R}) when N > 0 ->
  {ok, Pid} = supervisor:start_child(Sup, Args),
  Ref = erlang:monitor(process, Pid),
  {noreply, S#state{limit = N - 1, refs = gb_sets:add(Ref, R)}};
handle_cast({async, Args}, S = #state{limit = N, queue = Q}) when N =< 0 ->
  {noreply, S#state{queue = queue:in(Args, Q)}};
handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info({'DOWN', Ref, process, _Pid, _}, S = #state{refs = Refs}) ->
  io:format("received down msg~n"),
  case gb_sets:is_element(Ref, Refs) of
    true ->
      handle_down_worker(Ref, S);
    false -> %% Not our responsibility
      {noreply, S}
  end;
handle_info(P = {start_worker_supervisor, _Sup, MFA}, S = #state{}) ->
  io:format("[~p]The pool server handle a info[start_worker_supervisor], param:~p status:~p ~n", [self(), P, S]),
  ppool_worker_sup:start_link(MFA),
  {noreply, S};
handle_info(_Msg, State) ->
  {noreply, State}.

handle_down_worker(Ref, S = #state{limit = L, sup = Sup, refs = Refs}) ->
  io:format("[~p]The pool server handle a down worker, ~nparam:~p~n", [self(), S]),
  case queue:out(S#state.queue) of
    {{value, {From, Args}}, Q} ->
      {ok, Pid} = supervisor:start_child(Sup, Args),
      NewRef = erlang:monitor(process, Pid),
      NewRefs = gb_sets:insert(NewRef, gb_sets:delete(Ref, Refs)),
      gen_server:reply(From, {ok, Pid}),
      {noreply, S#state{refs = NewRefs, queue = Q}};
    {{value, Args}, Q} ->
      {ok, Pid} = supervisor:start_child(Sup, Args),
      NewRef = erlang:monitor(process, Pid),
      NewRefs = gb_sets:insert(NewRef, gb_sets:delete(Ref, Refs)),
      {noreply, S#state{refs = NewRefs, queue = Q}};
    {empty, _} ->
      io:format("[~p]The pool server handle a down worker, empty queue. ~n", [self()]),
      {noreply, S#state{limit = L + 1, refs = gb_sets:delete(Ref, Refs)}}
  end.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%-----------------------------------------




