function Choice=QPolicy2(ChoiceSet,SBSA,Q,StatePoints,Game,State)

    if Game==1
        Epi=0;    
    else
        Epi=.5; %Train.5 Test 0
    end
[rowCS,ColCS]=size(ChoiceSet);
[rowQ,ColQ]=size(Q);
% disp('Next')
if ColQ~=1
   State=State(:).'; 
end
SpolGroup=[];

if Game==1
    SAPSet=[];
    for cs=1:length(ChoiceSet(:,1))
        SAP=[State,ChoiceSet(cs,1)];
        SAPSet=[SAPSet;SAP];
       
    end
    
    SAPSet;

SAPS="";

for i = 1:size(SAPSet, 1)
    SAPS=SAPS+"[";
    for j = 1:size(SAPSet, 2)
        if j == size(SAPSet, 2)
            SAPS=SAPS+sprintf("%1.0f", SAPSet(i, j));
        else
            SAPS=SAPS+sprintf("%1.0f,", SAPSet(i, j));
        end
    end
    if i == size(SAPSet, 1)
        SAPS=SAPS+"]";
    else
        SAPS=SAPS+"],";
    end
end

SAPS="["+SAPS+"]";

SAPS;

%Write to a python file for the functional approximator to evaluate
   [~,Qout]=system("python DLQOut.py "+SAPS);
  
   %Compare the FA Q value outputs to determine next action
   Qout=str2num(Qout(1048:end));
   QFA=[Qout,ChoiceSet(:,1)];
   [~,QUse]=max(QFA(:,1));
   Choice=QFA(QUse,2);
   

   
else

    %Determine the Q values based on the state action pairs
    QNA=Q(ChoiceSet(:,4:end));
    [AnomVal,anomloc]=max(sum(QNA,2));
    nomState=ChoiceSet(anomloc,4:end);

    %Policy Dev
    anom=nomState;
    SPolSet=[];
        for ii=1:1:rowCS
            
            a=ChoiceSet(ii,4:end);

            if a==anom
                SPol=1-Epi+(Epi/rowCS);

            else
                SPol=(Epi/rowCS);

            end
            SPolSet=[SPolSet;SPol];
            
        end
        SpolGroup=[SpolGroup,SPolSet];

%Choose the Next move based on the Q Values
Movegroup=(ChoiceSet(:,1)).';
SpolGroup=SpolGroup.';
p = cumsum([0; SpolGroup(1:end-1).'; 1+1e3*eps]);
[a a] = histc(rand,p);

Choice=Movegroup(a);

end
