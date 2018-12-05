
% constraint_adder(+ClassifiedTrains, +ListOfTuples)
constraint_adder([], _, _).
constraint_adder([HClassifiedTrains|TClassifiedTrains], ListOfTuples, Paths):-
    nth1(1, HClassifiedTrains, (NodeA, _, _, _)),
  
    flatten(ListOfTuples, FlattenedTuples),
    
    filter_tuples(NodeA, FlattenedTuples, FilteredTuples),
    node_constrain_adder(HClassifiedTrains, FilteredTuples, FlattenedTuples, Paths),
    constraint_adder(TClassifiedTrains, ListOfTuples, Paths).


node_constrain_adder([], _, _, _).
node_constrain_adder([H|T], FilteredTuples, ListOfTuples, Paths):-
    H = (NodeA, NodeB, TrainsIN, TrainOUT),
    node_constrain_adder_helper(NodeA, NodeB, TrainsIN, TrainOUT, FilteredTuples, ListOfTuples, Paths),
    node_constrain_adder(T, FilteredTuples, ListOfTuples, Paths).

node_constrain_adder_helper(NodeA, NodeB, TrainsIN, TrainOUT, FilteredTuples, ListOfTuples, Paths):-
    filter_tuples_by_trainIds(TrainsIN, FilteredTuples, TuplesIN),
    filter_tuples_by_trainIds(TrainOUT, FilteredTuples, TuplesOUT),

    filter_tuples_by_nexthop(TuplesIN, Paths, ListOfTuples, TuplesINNextHop),
    filter_tuples_by_nexthop(TuplesOUT, Paths, ListOfTuples, TuplesOUTNextHop),
    
    all_pairs(TuplesIN, PairsIN),
    all_pairs(TuplesOUT, PairsOUT),
    nexthop_pairs(TuplesIN, TuplesINNextHop, TuplesOUT, TuplesOUTNextHop, PairsINOUT, PairsINOUTNextHop),

    solve_conflict_same_dir(PairsIN),
    solve_conflict_same_dir(PairsOUT),

    connected(NodeA, NodeB, Cost),
    solve_conflict_opposite_dir(NodeA, NodeB, PairsINOUT, PairsINOUTNextHop, Cost).
    
filter_tuples(_, [], []).

filter_tuples(Node, [HTuple|TTuples], FilteredTuples):-
    HTuple = (_, X, _, _, _), X \= Node,
    filter_tuples(Node, TTuples, FilteredTuples).

filter_tuples(Node, [HTuple|TTuples], [HTuple|TFilteredTuples]):-
    HTuple = (_, Node, _, _, _),
    filter_tuples(Node, TTuples, TFilteredTuples).

filter_tuples_by_trainIds(_, [], []).
filter_tuples_by_trainIds(TrainIDs, [H|T], TFilteredTuples):-
    H = (TrainID, _, _, _, _),
    \+member(TrainID, TrainIDs),
    filter_tuples_by_trainIds(TrainIDs, T, TFilteredTuples).

filter_tuples_by_trainIds(TrainIDs, [H|T], [H|TFilteredTuples]):-
    H = (TrainID, _, _, _, _),
    member(TrainID, TrainIDs),
    filter_tuples_by_trainIds(TrainIDs, T, TFilteredTuples).

filter_tuples_by_nexthop([], _, _, []).
filter_tuples_by_nexthop([HTuples|TTuples], Paths, ListOfTuples, [X|TOut]):-
    HTuples = (TrainID, Node, _, _, _),
    nth1(TrainID, Paths, PathID),
    next_hop(PathID, Node, NextNode),
    member(X, ListOfTuples),
    X = (TrainID, NextNode, _, _, _),
    filter_tuples_by_nexthop(TTuples, Paths, ListOfTuples, TOut).

filter_tuples_by_nexthop([HTuples|TTuples], Paths, ListOfTuples, [X|TOut]):-
    HTuples = (TrainID, Node, _, _, _),
    nth1(TrainID, Paths, PathID),
    next_hop(PathID, Node, nil),
    X = (TrainID, nil, 0, 0, 0),
    filter_tuples_by_nexthop(TTuples, Paths, ListOfTuples, TOut).

solve_conflict_same_dir([]).
solve_conflict_same_dir([H|T]):-
    H = pair(
        (_, _, _, _, DepartureA),
        (_, _, _, _, DepartureB)
        ),

    absCFD(DepartureA - DepartureB, TimeDiff),
    TimeDiff #>= 10,
    
    solve_conflict_same_dir(T).

solve_conflict_opposite_dir(_, _, [], [], _).
solve_conflict_opposite_dir(NodeA, NodeB, [H|T], [HNextHop|TNextHop], Cost):-
     H = pair(
        (TrainID1, NodeA, Arrival1A, _, _),
        (TrainID2, NodeA, Arrival2A, _, _)
    ),

    HNextHop = pair(
        (TrainID1, NodeX, Arrival1B, _, _),
        (TrainID2, NodeY, Arrival2B, _, _)
    ),
    
    (
        % case double railway
        (connected(NodeA, NodeB, _, 2));
        % case single railway
        (
            connected(NodeA, NodeB, _, 1),
            (
                (NodeX = NodeB, absCFD(Arrival1B - Arrival2A, TimeDiff));
                (NodeY = NodeB, absCFD(Arrival2B - Arrival1A, TimeDiff))
            ),
            TimeDiff #> Cost
        )
    ),
    solve_conflict_opposite_dir(NodeA, NodeB, T, TNextHop, Cost).
