:- use_module(library(clpfd)).
:- include('paths_generator.pl').
:- include('dynamic_time_generator.pl').
:- include('train_classifier.pl').
:- include('node_train.pl').
:- include('constraints.pl').
:- include('utilities.pl').
:- include('constants.pl').

% Knowledge Base ==================
node(a). node(b). node(c). node(d).
node(e). node(f). node(g). node(g).
node(h). node(i). node(j). node(k).
node(l). node(m).

edge(a, b, 40, 1).
edge(b, c, 40, 1).
edge(c, d, 50, 2).
edge(c, k, 60, 1).
edge(k, l, 60, 1).
edge(d, e, 35, 1).
edge(e, f, 35, 1).
edge(d, g, 30, 2).
edge(g, h, 30, 1).
edge(h, i, 25, 1).
edge(h, j, 30, 1).
edge(j, l, 60, 2).
edge(l, m, 20, 1).

train(1,  f, a,   0, 240).
train(2,  i, a,  60, 270).
train(3,  i, m,  30, 210).
train(4,  m, a,  60, 300).
train(5,  a, j, 240, 360).
train(6,  a, f, 120, 330).
train(7,  c, m,  90, 240).
train(8,  h, f,  30, 210).
train(9,  m, g,  60, 300).
train(10, m, d,  90, 300).
train(11, f, i, 150, 300).

% Predicates ==================
connected(X, Y, T) :- edge(X, Y, T, _).
connected(X, Y, T) :- edge(Y, X, T, _).
connected(X, Y, Time, Type) :- edge(X, Y, Time, Type).
connected(X, Y, Time, Type) :- edge(Y, X, Time, Type).

path(A, B, Path_rev, Time) :-
       travel(A, B, [A], Path, Time),
       reverse(Path, Path_rev).

travel(A, B, Visited, [B|Visited], Time) :-
       connected(A, B, Time).

travel(A, B, Visited, Path, Time) :-
       connected(A, C, T1),
       C \== B,
       \+member(C, Visited),
       travel(C, B, [C|Visited], Path, T2),
       Time #= T1 + T2.

route(TrainID, Path, Time, Error):-
  train(TrainID, A, B, Depart, Arrival),
  path(A, B, Path, Time),
  Error #= Time - (Arrival - Depart).

dispatcher(Output_path, Minimum_Tardiness):-
  setof(Paths, paths_generator(Paths), All_Schedules),

  minimum_path(All_Schedules, Minimum_Schedule, Minimum_Tardiness),
  pretty_print(Minimum_Schedule, Output_path).
  % write("Schedule: "), nl, pretty_print(Minimum_Schedule), nl,
  % write("Total Tardiness: "), write(Minimum_Tardiness), nl.

pretty_print(In, Out):-
  parse_schedule_level1(In, Out).

parse_schedule_level1([], []).
parse_schedule_level1([Hin|Tin], [Hout|Tout]):-
  parse_schedule_level2(Hin, Hout),
  parse_schedule_level1(Tin, Tout).

parse_schedule_level2([], []).
parse_schedule_level2([Hin|Tin], [Hout|Tout]):-
  Hin = (TrainID, Node, A, W, D),
  Hout = [TrainID, atom(Node), A, W, D],
  parse_schedule_level2(Tin, Tout).

minimum_path([Paths], Scheudle, Tardiness):-
  one_path(Paths, Scheudle, Tardiness).
minimum_path([HPaths|TPaths], Minimum_Schedule, Minimum_Tardiness):-
  one_path(HPaths, Scheudle, Tardiness),
  minimum_path(TPaths, TScheudle, TTardiness),
  (
    (Tardiness =< TTardiness, Minimum_Tardiness = Tardiness, Minimum_Schedule = Scheudle);
    (Tardiness > TTardiness, Minimum_Tardiness = TTardiness, Minimum_Schedule = TScheudle)
  ).

one_path(Paths, ListOfTuples, TotalTardiness):-
  paths_generator(Paths),

  findall(X, train(X, _, _, _, _), TrainIDs),
  multi_dynamic_time_generator(TrainIDs, Paths, ListOfTuples),

  findall(X, node(X), Nodes),
  multi_node_train(Nodes, Paths, TrainsInNodes),
  
  multi_train_classifier(Nodes, TrainsInNodes, Paths, ClassifiedTrains),

  constraint_adder(ClassifiedTrains, ListOfTuples, Paths),

  get_departures(ListOfTuples, Params),
  get_total_tardiness(ListOfTuples, TotalTardiness),

  flatten(Params, L),
  
  labeling([min(TotalTardiness)], L).

get_departures(X, L):-
  flatten(X, Y),
  get_departures_helper(Y, L).
  

get_departures_helper([], []).
get_departures_helper([H|T], [[A, W, D]|T2]):-
    H = ( _, _, A, W, D),
    get_departures_helper(T, T2).

get_total_tardiness([], 0).
get_total_tardiness([HListOfTuples|TListOfTuples], TotalTardiness):-
  length(HListOfTuples, N),
  nth1(N, HListOfTuples, LastTuple),
  LastTuple = (TrainID, _, ActualArrival, _, _),
  
  train(TrainID, _, _, _, DesiredArrival),

  % absCFD(ActualArrival - DesiredArrival, Tardiness),
  % Tardiness #= DesiredArrival - ActualArrival,
  Tardiness #= ActualArrival - DesiredArrival,

  get_total_tardiness(TListOfTuples, TTardiness),
  TotalTardiness #= TTardiness + Tardiness.
