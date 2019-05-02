function [Move,TPMNo,State]=RLearner(AllowedMoves,TPM,UsedNodes,UsedNN,Boxes,Size,MyPoints,EnemyPoints,BoxWalls,State,StateSet,SBSA,QuarterSets,StatePoints,Q,Game,FA)
[R,C,M]=size(AllowedMoves);
ChoiceSet=[];


%Creating a look ahead set of State Action Pairs
%     disp('Look Ahead')
for ii=1:1:M
    TempUsedNN=UsedNN;
    CurMov=AllowedMoves(:,:,ii);
    TPMNoC = find(arrayfun(@(x) isequal(TPM(:,:,x),CurMov),1:size(TPM,3)));
    TempUsedNN=[TempUsedNN,TPMNoC];
    [YIB,~]=isBox(UsedNodes,TempUsedNN,TPMNoC,Boxes,Size,BoxWalls);
    BoM=sum(YIB);
    [TempState,TempStateset]=getState(TempUsedNN,SBSA,QuarterSets);
    TempStateset=TempStateset.';
    ChoiceSet=[ChoiceSet;[TPMNoC,BoM,StatePoints,TempStateset]];
end

%Policy
if FA==1
    Choice=QPolicy2(ChoiceSet,SBSA,Q,StatePoints,Game,State);
else
    Choice=QPolicy(ChoiceSet,SBSA,Q,StatePoints,Game,State);
end
%Where is the choice value in the lineup?
ChosenVal=find(Choice==ChoiceSet);

%Greedy
%     ChosenVal=find(ChoiceSet(:,2)==max(ChoiceSet(:,2)))

Move=ChosenVal(1);
CurMov=AllowedMoves(:,:,Move);
TPMNo = find(arrayfun(@(x) isequal(TPM(:,:,x),CurMov),1:size(TPM,3)));

TPMNoSupdate=TPMNo;

end
