multi_node_train([], _, []).
multi_node_train([HNode|TNodes], Paths, [HTrains|TTrains]):-
    findall(X, train(X, _, _, _, _), TrainIDs),
    node_trains(HNode, Paths, TrainIDs, HTrains),
    multi_node_train(TNodes, Paths, TTrains).

node_trains(_, [], [], []).
node_trains(Node,[HPaths|TPaths], [HTrain|TTrains], [HTrain|NxtTrainID]):-
  member(Node, HPaths),
  node_trains(Node, TPaths, TTrains, NxtTrainID).

node_trains(Node, [HPaths|TPaths], [_|TTrains], NxtTrainID):-
  \+member(Node, HPaths),
  node_trains(Node, TPaths, TTrains, NxtTrainID).
