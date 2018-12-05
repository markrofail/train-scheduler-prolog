multi_train_classifier([], [], _, []).
multi_train_classifier([HNode| TNodes], [HTrains|TTrains], Paths, [H|T]):-
  train_classifier(HNode, HTrains, Paths, H),
  multi_train_classifier(TNodes, TTrains, Paths, T).

train_classifier(Node, TrainIDs, Paths, ClassifiedTrains):-
findall(X, connected(Node, X, _), ConnectedNodes),
(
  (length(ConnectedNodes, 1), train_classifier_one(Node, ConnectedNodes, TrainIDs, Paths, ClassifiedTrains));
  (length(ConnectedNodes, 2), train_classifier_two(Node, ConnectedNodes, TrainIDs, Paths, ClassifiedTrains));
  (length(ConnectedNodes, 3), train_classifier_three(Node, ConnectedNodes, TrainIDs, Paths, ClassifiedTrains))
).

train_classifier_one(NodeA, [NodeB], [], _, ClassifiedTrains):-
ClassifiedTrains =  [
  (NodeA, NodeB, [], [])
].
train_classifier_one(NodeA, [NodeB], [HTrainID|TTrainsID], Paths, ClassifiedTrains):-
ClassifiedTrains = [
  (NodeA, NodeB, DirectionBA, DirectionAB)
],

train_classifier_one(NodeA, [NodeB], TTrainsID, Paths, TClassifiedTrains),
  TClassifiedTrains = [
    (NodeA, NodeB, TDirectionBA, TDirectionAB)
  ],

  nth1(HTrainID, Paths, TrainPath),
  (
    %Case A is Start
    (node_is_start(NodeA, TrainPath),
        append([HTrainID], TDirectionAB, DirectionAB), 
        DirectionBA = TDirectionBA
        );
    %Case A is End
    (node_is_end(NodeA, TrainPath),
        append([HTrainID], TDirectionBA, DirectionBA), 
        DirectionAB = TDirectionAB
        )
  ).

train_classifier_two(NodeA, [NodeB, NodeC], [], _, ClassifiedTrains):-
ClassifiedTrains =  [
  (NodeA, NodeB, [], []), 
  (NodeA, NodeC, [], [])
].

train_classifier_two(NodeA, [NodeB, NodeC], [HTrainID|TTrainsID], Paths, ClassifiedTrains):-
ClassifiedTrains = [
  (NodeA, NodeB, DirectionBA, DirectionAB),
  (NodeA, NodeC, DirectionCA, DirectionAC)
],

train_classifier_two(NodeA, [NodeB, NodeC], TTrainsID, Paths, TClassifiedTrains),
TClassifiedTrains = [
  (NodeA, NodeB, TDirectionBA, TDirectionAB),
  (NodeA, NodeC, TDirectionCA, TDirectionAC)
],

nth1(HTrainID, Paths, TrainPath),
(
  (
      % Case A is Start
      (node_is_start(NodeA, TrainPath),
          % Case A -> B 
          (next_hop(TrainPath, NodeA, NodeB),
              append([HTrainID], TDirectionAB, DirectionAB), 
              DirectionBA = TDirectionBA,
              DirectionCA = TDirectionCA,
              DirectionAC = TDirectionAC);
          % Case A -> C
          (next_hop(TrainPath, NodeA, NodeC),
              append([HTrainID], TDirectionAC, DirectionAC), 
              DirectionCA = TDirectionCA,
              DirectionAB = TDirectionAB,
              DirectionBA = TDirectionBA)
      )
  );
  (
      % Case A is End
      (node_is_end(NodeA, TrainPath),
          % Case B -> A 
          (next_hop(TrainPath, NodeB, NodeA),
              append([HTrainID], TDirectionBA, DirectionBA), 
              DirectionAB = TDirectionAB,
              DirectionCA = TDirectionCA,
              DirectionAC = TDirectionAC);
          % Case C -> A
          (next_hop(TrainPath, NodeC, NodeA),
              append([HTrainID], TDirectionCA, DirectionCA), 
              DirectionAC = TDirectionAC,
              DirectionAB = TDirectionAB,
              DirectionBA = TDirectionBA)
      )
  );
  (
      % Case A is Intermdiate
      (node_is_interm(NodeA, TrainPath),
          % Case B -> A -> C
          (next_hop(TrainPath, NodeB, NodeA),
              next_hop(TrainPath, NodeA, NodeC),
              append([HTrainID], TDirectionBA, DirectionBA), 
              append([HTrainID], TDirectionAC, DirectionAC), 
              DirectionAB = TDirectionAB,
              DirectionCA = TDirectionCA); 
          % Case C -> A -> B
          (next_hop(TrainPath, NodeC, NodeA),
              next_hop(TrainPath, NodeA, NodeB),
              append([HTrainID], TDirectionCA, DirectionCA), 
              append([HTrainID], TDirectionAB, DirectionAB), 
              DirectionAC = TDirectionAC,
              DirectionBA = TDirectionBA)
      )
  )
). 

train_classifier_three(NodeA, [NodeB, NodeC, NodeD], [], _, ClassifiedTrains):-
    ClassifiedTrains =  [
    (NodeA, NodeB, [], []), 
    (NodeA, NodeC, [], []), 
    (NodeA, NodeD, [], [])
    ].

train_classifier_three(NodeA, [NodeB, NodeC, NodeD], [HTrainID|TTrainsID], Paths, ClassifiedTrains):-
  ClassifiedTrains = [
    (NodeA, NodeB, DirectionBA, DirectionAB),
    (NodeA, NodeC, DirectionCA, DirectionAC),
    (NodeA, NodeD, DirectionDA, DirectionAD)
  ],

  train_classifier_three(NodeA, [NodeB, NodeC, NodeD], TTrainsID, Paths, TClassifiedTrains),
  TClassifiedTrains = [
    (NodeA, NodeB, TDirectionBA, TDirectionAB),
    (NodeA, NodeC, TDirectionCA, TDirectionAC),
    (NodeA, NodeD, TDirectionDA, TDirectionAD)
  ],

  nth1(HTrainID, Paths, TrainPath),
  (
    (
        % Case A is Start
        (node_is_start(NodeA, TrainPath),
            % Case A -> B 
            (next_hop(TrainPath, NodeA, NodeB),
                append([HTrainID], TDirectionAB, DirectionAB), 
                DirectionBA = TDirectionBA,
                DirectionAC = TDirectionAC,
                DirectionCA = TDirectionCA,
                DirectionAD = TDirectionAD,
                DirectionDA = TDirectionDA);
            % Case A -> C
            (next_hop(TrainPath, NodeA, NodeC),
                append([HTrainID], TDirectionAC, DirectionAC), 
                DirectionCA = TDirectionCA,
                DirectionAB = TDirectionAB,
                DirectionBA = TDirectionBA,
                DirectionAD = TDirectionAD,
                DirectionDA = TDirectionDA);
            % Case A -> D
            (next_hop(TrainPath, NodeA, NodeD),
                  append([HTrainID], TDirectionAD, DirectionAD), 
                  DirectionDA = TDirectionDA,
                  DirectionAB = TDirectionAB,
                  DirectionBA = TDirectionBA,
                  DirectionAC = TDirectionAC,
                  DirectionCA = TDirectionCA)
          )
    );
    (
        % Case A is End
        (node_is_end(NodeA, TrainPath),
            % Case B -> A 
            (next_hop(TrainPath, NodeB, NodeA),
                append([HTrainID], TDirectionBA, DirectionBA), 
                DirectionAB = TDirectionAB,
                DirectionCA = TDirectionCA,
                DirectionAC = TDirectionAC,
                DirectionAD = TDirectionAD,
                DirectionDA = TDirectionDA);
            % Case C -> A
            (next_hop(TrainPath, NodeC, NodeA),
                append([HTrainID], TDirectionCA, DirectionCA), 
                DirectionAC = TDirectionAC,
                DirectionAB = TDirectionAB,
                DirectionBA = TDirectionBA,
                DirectionAD = TDirectionAD,
                DirectionDA = TDirectionDA);
          % Case D -> A
            (next_hop(TrainPath, NodeD, NodeA),
                  append([HTrainID], TDirectionDA, DirectionDA), 
                  DirectionAD = TDirectionAD,
                  DirectionAB = TDirectionAB,
                  DirectionBA = TDirectionBA,
                  DirectionAC = TDirectionAC,
                  DirectionCA = TDirectionCA)  
      )
    );
    (
        % Case A is Intermdiate
        (node_is_interm(NodeA, TrainPath),
            % Case B -> A -> C
            (next_hop(TrainPath, NodeB, NodeA),
                next_hop(TrainPath, NodeA, NodeC),
                append([HTrainID], TDirectionBA, DirectionBA), 
                append([HTrainID], TDirectionAC, DirectionAC), 
                DirectionAB = TDirectionAB,
                DirectionCA = TDirectionCA,
                DirectionAD = TDirectionAD,
                DirectionDA = TDirectionDA);
            % Case B -> A -> D
            (next_hop(TrainPath, NodeB, NodeA),
                next_hop(TrainPath, NodeA, NodeD),
                append([HTrainID], TDirectionBA, DirectionBA), 
                append([HTrainID], TDirectionAD, DirectionAD), 
                DirectionAB = TDirectionAB,
                DirectionDA = TDirectionDA,
                DirectionAC = TDirectionAC,
                DirectionCA = TDirectionCA);
            % Case C -> A -> B
            (next_hop(TrainPath, NodeC, NodeA),
                next_hop(TrainPath, NodeA, NodeB),
                append([HTrainID], TDirectionCA, DirectionCA), 
                append([HTrainID], TDirectionAB, DirectionAB), 
                DirectionAC = TDirectionAC,
                DirectionBA = TDirectionBA,
                DirectionAD = TDirectionAD,
                DirectionDA = TDirectionDA);
            % Case C -> A -> D
            (next_hop(TrainPath, NodeC, NodeA),
                next_hop(TrainPath, NodeA, NodeD),
                append([HTrainID], TDirectionCA, DirectionCA), 
                append([HTrainID], TDirectionAD, DirectionAD), 
                DirectionAC = TDirectionAC,
                DirectionDA = TDirectionDA,
                DirectionAB = TDirectionAB,
                DirectionBA = TDirectionBA);  
            % Case D -> A -> B
            (next_hop(TrainPath, NodeD, NodeA),
                next_hop(TrainPath, NodeA, NodeB),
                append([HTrainID], TDirectionDA, DirectionDA), 
                append([HTrainID], TDirectionAB, DirectionAB), 
                DirectionAD = TDirectionAD,
                DirectionBA = TDirectionBA,
                DirectionAC = TDirectionAC,
                DirectionCA = TDirectionCA));
            % Case D -> A -> C
            (next_hop(TrainPath, NodeD, NodeA),
                next_hop(TrainPath, NodeA, NodeC),
                append([HTrainID], TDirectionDA, DirectionDA), 
                append([HTrainID], TDirectionAC, DirectionAC), 
                DirectionAD = TDirectionAD,
                DirectionCA = TDirectionCA,
                DirectionAB = TDirectionAB,
                DirectionBA = TDirectionBA)
    )
  ). 
