multi_dynamic_time_generator([], _, []).
multi_dynamic_time_generator([HTrainID| TTrainIDs], Paths, [H|T]):-
  dynamic_time_generator(HTrainID, Paths, H),
  multi_dynamic_time_generator(TTrainIDs, Paths, T).

dynamic_time_generator(TrainID, Paths, ListOfTuples):-
    train(TrainID, _, _, StartTime, _),
    nth1(TrainID, Paths, Path),
    
    length(Path ,Len),
    length(ListOfTuples, Len),
  
    init_times(TrainID, Path, ListOfTuples),
    ListOfTuples = [(_, _, StartTime, _, _)|_].
  
  %                       40   40
  %                     a -> b -> c
  %    [(ArrivalA,       (ArrivalB,       (ArrivalC
  %        WaitA,            WaitB,            WaitC
  %        DepartureA),      DepartureB),      DepartureC)]
  
init_times(_, [_], [_]).
init_times(TrainID, [A, B| T], [TupleA, TupleB |TTuple]):-
    connected(A, B, TravelCost),
  
    TupleA = (TrainID, A, ArrivalA, WaitA, DepartureA),
    DepartureA #= WaitA + ArrivalA,
    
    TupleB = (TrainID, B, ArrivalB, WaitB, DepartureB),
    DepartureB #= WaitB + ArrivalB,

    ArrivalB #= DepartureA + TravelCost,

    waitMax(MAXWAIT),
    [WaitA, WaitB] ins 0..MAXWAIT,
    init_times(TrainID, [B|T], [TupleB|TTuple]).
  