-module(shop_car).
-export([total/1]).

total([{What, N}|T]) -> shop:cost(What) * N + total(T);
total({What, N}) -> shop:cost(What) * N;
total([]) -> 0.
