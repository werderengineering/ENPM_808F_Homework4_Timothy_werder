function [State,Stateset]=getState(UsedNN,SBSA,QuarterSets)


State=zeros(size(QuarterSets));
StateUpdate=find(ismember(QuarterSets,UsedNN));
State(StateUpdate)=1;
Stateset=[];
[StateSetsNo,~]=size(State);
    for qq=1:StateSetsNo
        [bool,cSL]=ismember(State(qq,:),SBSA,'rows');
        Stateset=[Stateset;cSL];
    end
end