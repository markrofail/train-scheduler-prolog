
% ONE TRAIN
% in: train ID
% out: paths with tolerance of 60 between each other

% filter case: there is a huge difference between path times
filter(Path1, Time1, Path2, Time2, Paths):-
  tolerance(Tolerance),
  abs(Time1 - Time2, TimeDiff), TimeDiff > Tolerance,
  (
    (Time1 =< Time2, Paths = [Path1]);
    (Time1 > Time2, Paths = [Path2])
  ).

% filter case: the two path times are relatively the same
filter(Path1, Time1, Path2, Time2, [Path1, Path2]):-
  tolerance(Tolerance),
  abs(Time1 - Time2, TimeDiff), TimeDiff =< Tolerance.

one_train(TrainID, Paths):-
  route(TrainID, Path1, Time1, _),
  route(TrainID, Path2, Time2, _),
  Path1 \= Path2, !,
  filter(Path1, Time1, Path2, Time2, Paths).

all_trains_paths(Paths):-
  findall(X, train(X, _, _, _, _), All_IDS),
  findall(Path, (member(TrainID, All_IDS), one_train(TrainID, Path)), Paths).

%% schedule_generator(-Scenarios)
%% generates a candidate route for all trains
paths_generator(Routes):-
  all_trains_paths(All_Paths),

  nth1(1,  All_Paths, Train01_Paths),
  member(Train01_Path, Train01_Paths),

  nth1(2,  All_Paths, Train02_Paths),
  member(Train02_Path, Train02_Paths),

  nth1(3,  All_Paths, Train03_Paths),
  member(Train03_Path, Train03_Paths),

  nth1(4,  All_Paths, Train04_Paths),
  member(Train04_Path, Train04_Paths),

  nth1(5,  All_Paths, Train05_Paths),
  member(Train05_Path, Train05_Paths),

  nth1(6,  All_Paths, Train06_Paths),
  member(Train06_Path, Train06_Paths),

  nth1(7,  All_Paths, Train07_Paths),
  member(Train07_Path, Train07_Paths),

  nth1(8,  All_Paths, Train08_Paths),
  member(Train08_Path, Train08_Paths),

  nth1(9,  All_Paths, Train09_Paths),
  member(Train09_Path, Train09_Paths),

  nth1(10, All_Paths, Train10_Paths),
  member(Train10_Path, Train10_Paths),

  nth1(11, All_Paths, Train11_Paths),
  member(Train11_Path, Train11_Paths),

  Routes = [
    Train01_Path, Train02_Path, Train03_Path,
    Train04_Path, Train05_Path, Train06_Path,
    Train07_Path, Train08_Path, Train09_Path,
    Train10_Path, Train11_Path
  ].
