function Choice=QPolicy(ChoiceSet,SBSA,Q,StatePoints,Game,State)

    if Game==1
        Epi=0;    
    else
        Epi=.5; %Train.5 Test 0
    end
[rowCS,ColCS]=size(ChoiceSet);
[rowQ,ColQ]=size(Q);
% disp('Next')

SpolGroup=[];


%     Qcol=Q(:,qq);
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


Movegroup=(ChoiceSet(:,1)).';
SpolGroup=SpolGroup.';
p = cumsum([0; SpolGroup(1:end-1).'; 1+1e3*eps]);
[a a] = histc(rand,p);

Choice=Movegroup(a);


