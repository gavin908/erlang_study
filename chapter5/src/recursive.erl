-module(recursive).
-compile(export_all).

%% calculate length of a list
len([]) -> 0;
len([_|T]) -> 1 + len(T).

len2(T) -> len2(T, 0).
len2([], Len) -> Len;
len2([_|T], Len) -> len2(T, Len+1).

%% calculate fac of a number
fac(0) -> 1;
fac(N) when N > 0 -> N * fac(N-1).

%% calculate fac of a number by tail recursive 
fac2(N) -> fac2(N, 1).
fac2(0, R) -> R;
fac2(N, R) when N > 0 -> fac2(N-1, N*R).


%% 列表去重
norep(L) -> norep(L, []).
norep([], R) -> R;
norep([H|T], R) -> 
	case lists:member(H, R) of
		false -> norep(T, R++[H]);
		true -> norep(T, R)
	end.


%% ZIP 列表合并，两个长度相同的列表为参数，把它们合并成一个元组列表，每个元组中有两个数据项。
zip1([], _) -> [];
zip1([X|Xs], [Y|Ys]) -> [{X, Y} | zip1(Xs, Ys)].

%% ZIP函数尾递归实现
zip2(L1, L2) -> tail_zip(L1, L2, []).
tail_zip([], _, RS) -> RS;
tail_zip([X|Xs], [Y|Ys], RS) -> tail_zip(Xs, Ys, [{X, Y} | RS]).

zip(A, B) ->
  io:format("ZIP fucniton~n"),
  io:format("~W~n", zip1(A, B)),
  io:format("ZIP tail~n"),
  zip2(A, B).