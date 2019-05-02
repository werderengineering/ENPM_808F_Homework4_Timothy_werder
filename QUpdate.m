function [Q,PPP,RewardOut]=QUpdate(Q,PlayerPoints,EnemyPoints,State,StateSet,EG,PPP,AllowedMoves,UsedNN,SBSA,QuarterSets,Boxes,Size,BoxWalls,TPM,UsedNodes,StatePoints);
    Reward=0;
    
    %Determine the reward for the move made
    if EG==1
        
        if PlayerPoints>EnemyPoints
         Reward=Reward+5;
        
        else
            Reward=0;
        end

    end

        if PPP<PlayerPoints
            PPP=PlayerPoints;
            Reward=Reward+1;        

        else
            Reward=0;        

        end

    
    
    [R,C,M]=size(AllowedMoves);
    ChoiceSet=[];
    
    %For the 
%     disp('Look Ahead');
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
    
    
    %Update the Q Values based on the move and the look ahead
    if EG==0
        [rowCS,ColCS]=size(ChoiceSet);
        [rowQ,ColQ]=size(Q);

        QNA=Q(ChoiceSet(:,4:end));
        QNAM=max(sum(QNA,2));

        gamma=.25;
        Reward+gamma*QNAM;
        RewardOut=Reward+gamma*QNAM;
        Q(StateSet)=Reward+gamma*QNAM;
        
    
    else
        RewardOut=Reward;
        Q(StateSet)=Reward;
        
    end

end
