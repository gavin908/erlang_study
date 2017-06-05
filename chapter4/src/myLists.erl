-module(myLists).
-export([map/2]).

map(F, [H|T]) -> [F(H)|map(F, T)];
map(_, []) -> [].

filter(F, [H|T]) -> 
