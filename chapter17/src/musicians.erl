%%%-------------------------------------------------------------------
%%% @author ebihebi
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Jun 2017 15:55
%%%-------------------------------------------------------------------
-module(musicians).
-behaviour(gen_server).

-compile(export_all).
-record(state, {name = "", role, skill = good}).
-define(DELAY, 750).

start_link(Role, Skill) ->
  gen_server:start_link({local, Role}, ?MODULE, [Role, Skill], []).

stop(Role) ->
  gen_server:call(Role, stop).

init([Role, Skill]) ->
  process_flag(trap_exit, true),
  random:seed(now()),
  TimeToPlay = random:uniform(3000),
  Name = pick_name(),
  StrRole = atom_to_list(Role),
  io:format("[~p]Musician ~s, playing the ~s entered the room. TimeToPlay:~p~n", [self(), Name, StrRole, TimeToPlay]),
  {ok, #state{name = Name, role = StrRole, skill = Skill}, TimeToPlay}.

handle_call(stop, _From, S = #state{}) ->
  io:format("[~p]Handle a call, msg:~p~n", [self(), stop]),
  {stop, normal, ok, S};
handle_call(_Message, _From, S) ->
  io:format("[~p]Handle a call, msg:~p~n", [self(), _Message]),
  {noreply, S, ?DELAY}.

handle_cast(_Message, S) ->
  io:format("[~p]Handle a cast, msg:~p~n", [self(), _Message]),
  {noreply, S, ?DELAY}.

handle_info(timeout, S = #state{name = N, skill = good}) ->
  R = random:uniform(7),
  io:format("[~p]~s produced sound(~p)!~n", [self(), N, R]),
  {noreply, S, ?DELAY};
handle_info(timeout, S = #state{name = N, skill = bad}) ->
  R = random:uniform(7),
  case R of
    1 ->
      io:format("[~p]~s played a false note(~p). Uh oh~n", [self(), N, R]),
      {stop, bad_note, S};
    _ ->
      io:format("[~p]~s produced sound(~p)!~n", [self(), N, R]),
      {noreply, S, ?DELAY}
  end;
handle_info(_Message, S) ->
  io:format("[~p]Handle a info, msg:~p~n", [self(), _Message]),
  {noreply, S, ?DELAY}.

terminate(normal, S) ->
  io:format("[~p]~s left the room (~s)~n", [self(), S#state.name, S#state.role]);
terminate(bad_note, S) ->
  io:format("[~p]~s played a bad note, sucks! kicked that member out of the band!(~s)~n", [self(), S#state.name, S#state.role]);
terminate(shutdown, S) ->
  io:format("[~p]The manager is mad and fired the whole band! "
  "~s just got back to playing in the subway~n",
    [S#state.name]);
terminate(_Reason, S) ->
  io:format("[~p]~s has been kicked out.(~s)~n", [self(), S#state.name, S#state.role]).

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

pick_name() ->
  lists:nth(random:uniform(10), firstnames()) ++ " " ++ lists:nth(random:uniform(10), lastnames()).

firstnames() ->
  ["Valerie", "Arnold", "Carlos", "Dorothy", "Keesha",
    "Phoebe", "Ralphie", "Tim", "Wanda", "Janet"].

lastnames() ->
  ["Frizzle", "Perlstein", "Ramon", "Ann", "Franklin",
    "Terese", "Tennelli", "Jamal", "Li", "Perlstein"].