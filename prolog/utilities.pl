
%train_classifier helper
node_is_start(Node, TrainPath):-
    nth1(1, TrainPath, Node).

%train_classifier helper
node_is_end(Node, TrainPath):-
    length(TrainPath, N),
    nth1(N, TrainPath, Node).

%train_classifier helper
node_is_interm(Node, TrainPath):-
    length(TrainPath, Len),
    nth1(N, TrainPath, Node),
    N > 1, N < Len.

%constraint_adder helper
absCFD(X, Y):-
    (X #>= 0, Y #= X);
    (X #< 0, Y #= -1 * X).

%constraint_adder helper
zip_tuples([], [], []).
zip_tuples([], _, []).
zip_tuples(_, [], []).
zip_tuples([X|Xs], [Y|Ys], [pair(X,Y)|Zs]) :- 
    zip_tuples(Xs,Ys,Zs).

%constraint_adder helper
all_pairs([X|T],PS):- 
    pairs(X, T, T, PS, []).
all_pairs([],[]).

all_pairs([], _, []).
all_pairs(_, [], []).
all_pairs(Xs, Ys, Ps):-
    pairs2(Xs, Ys, Ys, Ps, []).

% pair(+CurrentElem, +RestElem, +UnconsideredElems, CumulativeList, -Result)
pairs(_, [], [], Z, Z).
pairs(_, [], [X|T], PS, Z):- 
    pairs(X, T, T, PS, Z).
pairs(X, [Y|T], R, [pair(X, Y)|PS], Z):- 
    pairs(X, T , R, PS, Z).

pairs2([], _, _, Z, Z). 
pairs2([_|Xs], [], L, PS, Z):- 
    pairs2(Xs, L, L, PS, Z).
pairs2([X|Xs], [Y|Ys], L, [pair(X, Y)|PS], Z):- 
    pairs2([X|Xs], Ys, L, PS, Z).

%constraint_adder helper
nexthop_pairs(L1, NL1, L2, NL2, L1L2Ps, Ps):-
    all_pairs(L1, L2, L1L2Ps),
    nexthop_pairs_helper(NL1, NL2, L1L2Ps, Ps).

nexthop_pairs_helper(_, _, [], []).
nexthop_pairs_helper(L1, L2, [H|T], [HPair|TPairs]):-
    H = pair(
            (TrainID1, _, _, _, _),
            (TrainID2, _, _, _, _)
        ),
    member(Tuple1, L1), Tuple1 = (TrainID1, _, _, _, _),
    member(Tuple2, L2), Tuple2 = (TrainID2, _, _, _, _),
    HPair = pair(Tuple1, Tuple2),
    nexthop_pairs_helper(L1, L2, T, TPairs).

%% next_hop(+Path, +Node, -NextNode)
%% gets the next node in a given path
%- special case: last element in path
next_hop(Path, Node, nil):-
    nth1(Index, Path, Node),
    length(Path, Index).
  
  next_hop(Path, Node, NextNode):-
    nth1(Index, Path, Node),
    NIndex #= Index +1,
    nth1(NIndex, Path, NextNode).
  