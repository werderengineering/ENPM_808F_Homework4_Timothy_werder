close all

%Create Points
clc
clear all
%Initalize all the Functional Approximation Data sets
DLIn=[];
DLState=[];
DLStateSet=[];
DLAction=[];
DLReward=[];
DLQVals=[];

DLStateEpisode=[];
DLStateSetEpisode=[];
DLActionEpisode=[];
DLRewardEpisode=[];
DLEpisodeSize=[];
DLQValsEpisode=[];

%Make all the State possibilities for the 2x2 game
States=0:1:2^12-1;

States=States.';

StatesBin=dec2bin(States);
SBSA=[];

for ii=1:length(States)
    StatesBinSep=str2double(regexp(convertCharsToStrings(StatesBin(ii,:)),'\d','match'));
    SBSA=[SBSA;StatesBinSep];
end

%%
%Make the Game based on the number of boxes the user enters
Size=input('Input size: ')
Points=[];
for ii=1:1:Size(1)+1
    
    for jj=1:1:Size(2)+1
        Points=[Points,[ii;jj]];
    end
end

TN=input('Number of Training Sessions: ')
for Training=1:1:TN
    hold on
        figure(1)
        
        %Create the dots
        for kk=1:1:length(Points)
            plot(Points(1,kk),Points(2,kk), 'k.')
        end
    
    %     %Formatting grid
    ax=gca;
    axis([0,Size(1)+2,0,Size(1)+2]);
    grid off;
    ax.XTickLabel=[];
    ax.YTickLabel=[];
    
    %%
    %Total Possible Moves
    TPM=[];
    MvN=1;
    CTPList=[];
    TPLsit=[];
    invTPMCheck=[0 0;0 0];
    for qq=1:1:length(Points)
        CTP=Points(:,qq);
        
        
        for rr=1:1:length(Points)
            TP=Points(:,rr);
            
            if (abs(CTP(1)-TP(1))==1 && abs(CTP(2)-TP(2))==0)|| (abs(CTP(1)-TP(1))==0 && abs(CTP(2)-TP(2))==1)
                dubcheck=[CTP,TP];
                
                if any(all(all(bsxfun(@eq,invTPMCheck,dubcheck))))==0
                    TPM(:,:,MvN)=[CTP,TP];
                    invTPMCheck(:,:,MvN)=[TP,CTP];
                    MvN=MvN+1;
                end
            end
        end
    end
    %%
    
    %Initalize Values for the game
    MaxMoves=length(TPM);
    AllowedMoves=TPM;
    CM=1;
    ww=1;
    Player=1;
    Ply=1;
    Player1Points=0;
    P1PP=0;
    P2PP=0;
    Player2Points=0;
    UsedNN=[];
    UsedNodes=[];
    BoxWalls=zeros(1,Size(1)*Size(2));
    Player1Total=0;
    Player2Total=0;
    FA=0;
    
    %Create the Vertical and Horizontal Value lines
    VertVals=[];
    HorzVals=[];
    VertLow=1;
    VertHigh=MaxMoves;
    HorzLow=2;
    HorzDif=Size(1)*2-1;
    HorzMid=HorzLow+2;
    HorzMidG=[];
    HorzHigh=HorzLow+HorzDif;
    VertMid=VertLow+HorzDif+2;
    VertMidG=[];
    for ii=1:1:Size(1)
        
        for jj=1:1:Size(1)-1
            
            HorzMidG=[HorzMid;HorzMidG];
            HorzMid=HorzMid+2;
        end
        
        for ll=1:1:Size(1)-1
            
            VertMidG=[VertMidG,VertMid];
            VertMid=VertMid+HorzDif+2;
        end
        
        VertVals=[[VertLow,VertMidG,VertHigh];VertVals];
        HorzVals=[HorzVals,[HorzHigh;HorzMidG;HorzLow]];
        VertLow=VertLow+2;
        VertHigh=VertHigh-1;
        HorzLow=HorzLow+HorzDif+2;
        HorzHigh=HorzLow+HorzDif;
        HorzMid=HorzLow+2;
        VertMid=VertLow+HorzDif+2;
        HorzMidG=[];
        VertMidG=[];
        
        
    end
    
    %Organize the Horizonal and Veritcal line values
    HorzVals=flipud(HorzVals);
    LVV=size(VertVals);
    VertVals(:,LVV(2))=flipud(VertVals(:,LVV(2)));
    VertVals=flipud(VertVals);
    
    
    
    %Creating Boxes
    Boxes=[];
    for ii=1:1:length(HorzVals)-1
        for jj=1:1:length(VertVals)-1
            Box=[HorzVals(ii,jj),HorzVals(ii+1,jj),VertVals(ii,jj),VertVals(ii,jj+1)];
            Boxes=[Boxes;Box];
        end
        
    end
    BoxesLeft=Boxes;
    
    %Initalize the 2x2 games inside the 3x3 games
    if Size==[3,3]
        QuarterSet1=unique([Boxes(1,:),Boxes(2,:),Boxes(4,:),Boxes(5,:)]);
        QuarterSet2=unique([Boxes(4,:),Boxes(5,:),Boxes(7,:),Boxes(8,:)]);
        QuarterSet3=unique([Boxes(2,:),Boxes(3,:),Boxes(5,:),Boxes(6,:)]);
        QuarterSet4=unique([Boxes(5,:),Boxes(6,:),Boxes(8,:),Boxes(9,:)]);
        
        QuarterSets=[QuarterSet1;QuarterSet2;QuarterSet3;QuarterSet4];
        
    else
        QuarterSets=unique([Boxes(1,:),Boxes(2,:),Boxes(4,:),Boxes(3,:)]);
    end
    AllMoves=1:MaxMoves;
    [State,StateSet]=getState(UsedNN,SBSA,QuarterSets);
    
    %Initialize Q table for both Player 1 and 2 or initialize Q table
    
    if Training==1
        Q1=zeros(length(SBSA),length(StateSet));
        Qs=Q1;
        Q2=Q1;
    else
        Q1=QOut;
        Qs=QOut;
        
        if mod(Training,100)==1
            Q2=Q1;
            Training
        else
            Q2=QOut;
        end
        
    end
    
    %     input('')
    %Main Program
    while CM~=MaxMoves+1
        EG=0;
        
        %Update states and the remaining Moves
        RMoves=setdiff(AllMoves,UsedNN);
        [State,StateSet]=getState(UsedNN,SBSA,QuarterSets);
       
        
        if Player==1
            %Player1
%             Update QTable and Select Next Move
            [Q1,P1PP,RewardOut1]=QUpdate(Q1,Player1Points,Player2Points,State,StateSet,EG,P1PP,AllowedMoves,UsedNN,SBSA,QuarterSets,Boxes,Size,BoxWalls,TPM,UsedNodes,Player1Points);
            [Move,TPMNo]=RLearner(AllowedMoves,TPM,UsedNodes,UsedNN,Boxes,Size,Player1Points,Player2Points,BoxWalls,State,StateSet,SBSA,QuarterSets,Player1Points,Q1,0,FA);
            
            %Update the Per Turn Functional Approximator values
            if Size==[3,3]
                StateR=SBSA(StateSet,:);
                StateR=StateR(:).';
                DLState=[DLState;StateR];
            else
                DLState=[DLState;State];
            end
            DLStateSet=[DLStateSet;StateSet];
            DLAction=[DLAction;TPMNo];
            DLReward=[DLReward;RewardOut1];
            
            if Size==[3,3]
                DLQVals=[DLQVals;sum(Q1(StateSet))];
            end
            
            %Update Visuals
            plot(AllowedMoves(1,:,Move),AllowedMoves(2,:,Move),'r')
            Color=[1,0,0];
        else
            %Player2
            
            %Random Bot
%             [Move,TPMNo]=random(AllowedMoves,TPM);
            
            
            %Greedy Bot
%             [Move,TPMNo]=Greedy(AllowedMoves,TPM,UsedNodes,UsedNN,Boxes,Size,Player2Points,Player1Points,BoxWalls,State,StateSet,SBSA,QuarterSets,Player2Points,Q2,0,FA);

            
            %Q Bot
            [~,P2PP,~]=QUpdate(Q2,Player2Points,Player1Points,State,StateSet,EG,P2PP,AllowedMoves,UsedNN,SBSA,QuarterSets,Boxes,Size,BoxWalls,TPM,UsedNodes,Player2Points);
            [Move,TPMNo]=RLearner(AllowedMoves,TPM,UsedNodes,UsedNN,Boxes,Size,Player2Points,Player1Points,BoxWalls,State,StateSet,SBSA,QuarterSets,Player2Points,Q2,0,FA);
            
            %Update Visuals
            plot(AllowedMoves(1,:,Move),AllowedMoves(2,:,Move),'b')
            Color=[0,0,1];
        end
        
        
        %Update the Availible Moves
        UsedNN=[UsedNN,TPMNo];
        UsedNodes(:,:,CM)= AllowedMoves(:,:,Move);
        AllowedMoves(:,:,Move)=[];
        
        %Check to see if it was a box and update the Drawing, Scores and
        %Player turn
        [YIB,WhichB]=isBox(UsedNodes,UsedNN,TPMNo,BoxesLeft,Size,BoxWalls);
        if sum(YIB)~=0
            for ii=1:1:length(YIB)
                
                if YIB(ii)==1
                    fillx=[];
                    filly=[];
                    %
                    for kk=1:1:5
                        fillx=[fillx,TPM(1,:,WhichB(ii,kk))];
                        filly=[filly,TPM(2,:,WhichB(ii,kk))];
                        
                        
                    end
                    minx=min(fillx);
                    maxx=max(fillx);
                    miny=min(filly);
                    maxy=max(filly);
                    fzx=[minx,minx,maxx,maxx,minx];
                    fzy=[miny,maxy,maxy,miny,miny];
                    %                     input('FillSquare ')
                    fill(fzx,fzy,Color)
                    
                    
                    
                    
                    if  Player==1
                        Player1Points=Player1Points+1;
                    else
                        Player2Points=Player2Points+1;
                    end
                end
            end
        else
            Ply=Ply+1;
            Player=mod(Ply,2);
        end
        
        
        %             input(' ')
                pause(.001)
        CM=CM+1;
    end
    hold off
    
    % disp('Game Over')
    % disp(' ')
    
    if Player1Points>Player2Points
        %     disp('Player 1 Wins')
        %     Player1Points
        %     Player2Points
        
    elseif Player2Points>Player1Points
        %     disp('Player 2 Wins')
        %     Player1Points
        %     Player2Points
    else
        %     disp('Tie Game')
    end
    %End the Game and Update all State and Q Values
    EG=1;
    [State,StateSet]=getState(UsedNN,SBSA,QuarterSets);
    [Q1,P1PP,RewardOut1]=QUpdate(Q1,Player1Points,Player2Points,State,StateSet,EG,P1PP,AllowedMoves,UsedNN,SBSA,QuarterSets,Boxes,Size,BoxWalls,TPM,UsedNodes,Player1Points);
    [~,P2PP,RewardOut2]=QUpdate(Q2,Player2Points,Player1Points,State,StateSet,EG,P2PP,AllowedMoves,UsedNN,SBSA,QuarterSets,Boxes,Size,BoxWalls,TPM,UsedNodes,Player2Points);
    
    
    %Function Approximation Value Development
    if Size==[3,3]
        StateR=SBSA(StateSet,:);
        StateR=StateR(:).';
        DLState=[DLState;StateR];
    else
        DLState=[DLState;State];
    end
    DLStateSet=[DLStateSet;StateSet];
    DLAction=[DLAction;TPMNo];
    DLReward=[DLReward;RewardOut1];
    
    if Size==[3,3]
        DLQVals=[DLQVals;sum(Q1(StateSet))];
    else
        DLQVals=[DLQVals;Q1(DLStateSet)];
    end
    
    DLStateEpisode=[DLStateEpisode;DLState];
    DLEpisodeSize=[DLEpisodeSize;length(DLStateSet)];
    DLStateSetEpisode=[DLStateSetEpisode;DLStateSet];
    DLActionEpisode=[DLActionEpisode;DLAction];
    DLRewardEpisode=[DLRewardEpisode;DLReward];
    DLQValsEpisode=[DLQValsEpisode;DLQVals];
    
    DLState=[];
    DLStateSet=[];
    DLAction=[];
    DLReward=[];
    DLQVals=[];
    
    %Set the Q Value for the next round
    QOut=Q1;
    clf(figure(1))
end
%%
%Function Approximation Value Concatonation
QFA=[];
DLSA=[DLStateEpisode,DLActionEpisode];


%%
%Choose whether to run the Functional Approximator
FA=input('Enter 1 to use Function approximation else, press enter: ')
gamerun=0;
Player1WinSet=[];

while gamerun<5
    
    if FA==1
        
        %Write out State action pairs to Python to create the Approximator
        Lernt=writeoutDL(DLSA,DLQValsEpisode,Size);
        disp('Starting')
        
        %Initialize for the Evaluation gameplay
        QGame=Q1;
        Player1PointTotal=0;
        Player2PointTotal=0;
        Player1WinTotal=0;
        Player2WinTotal=0;
        TieGames=0;
        
        %Play the Evaluation Game set
        [Player1PointsTotal,~,Player1WinTotal,Player2WinTotal,TieGames]=GameOn(QGame,Size,Player1PointTotal,Player2PointTotal,Player1WinTotal,Player2WinTotal,TieGames,FA)
        close all
        
    else
        
        %Initialize for the Evaluation gameplay
        FA=0;
        QGame=Q1;
        Player1PointTotal=0;
        Player2PointTotal=0;
        Player1WinTotal=0;
        Player2WinTotal=0;
        TieGames=0;
        
        %Play the Evaluation Game set
        [~,~,Player1WinTotal,Player2WinTotal,TieGames]=GameOn(QGame,Size,Player1PointTotal,Player2PointTotal,Player1WinTotal,Player2WinTotal,TieGames,FA)
        close all
        
    end
    
    Player1WinSet=[Player1WinSet,Player1WinTotal];
    gamerun=gamerun+1;
    
end
close all

%Output the Evaluation Set
Player1WinSet=Player1Winset


%%
%%%%%%
%Game%
%%%%%%


function [Player1PointTotal,Player2PointTotal,Player1WinTotal,Player2WinTotal,TieGames]=GameOn(Q,Size,Player1PointTotal,Player2PointTotal,Player1WinTotal,Player2WinTotal,TieGames,FA)

States=0:1:2^12-1;

States=States.';

StatesBin=dec2bin(States);
SBSA=[];

for ii=1:length(States)
    StatesBinSep=str2double(regexp(convertCharsToStrings(StatesBin(ii,:)),'\d','match'));
    SBSA=[SBSA;StatesBinSep];
end

Points=[];
for ii=1:1:Size(1)+1
    
    for jj=1:1:Size(2)+1
        Points=[Points,[ii;jj]];
    end
end
for Game=1:1:100
    hold on
    figure(1)
    for kk=1:1:length(Points)
        plot(Points(1,kk),Points(2,kk), 'k.')
    end
    
    %Formatting grid
    ax=gca;
    axis([0,Size(1)+2,0,Size(1)+2]);
    grid off;
    ax.XTickLabel=[];
    ax.YTickLabel=[];
    
    %%
    %Total Possible Moves
    TPM=[];
    MvN=1;
    CTPList=[];
    TPLsit=[];
    invTPMCheck=[0 0;0 0];
    for qq=1:1:length(Points)
        CTP=Points(:,qq);
        
        
        for rr=1:1:length(Points)
            TP=Points(:,rr);
            
            if (abs(CTP(1)-TP(1))==1 && abs(CTP(2)-TP(2))==0)|| (abs(CTP(1)-TP(1))==0 && abs(CTP(2)-TP(2))==1)
                dubcheck=[CTP,TP];
                
                if any(all(all(bsxfun(@eq,invTPMCheck,dubcheck))))==0
                    TPM(:,:,MvN)=[CTP,TP];
                    invTPMCheck(:,:,MvN)=[TP,CTP];
                    MvN=MvN+1;
                end
            end
        end
    end
    %%
    
    MaxMoves=length(TPM);
    AllowedMoves=TPM;
    CM=1;
    ww=1;
    Player=1;
    Ply=1;
    Player1Points=0;
    P1PP=0;
    P2PP=0;
    Player2Points=0;
    UsedNN=[];
    UsedNodes=[];
    BoxWalls=zeros(1,Size(1)*Size(2));
    
    %OusideVals
    VertVals=[];
    HorzVals=[];
    VertLow=1;
    VertHigh=MaxMoves;
    HorzLow=2;
    HorzDif=Size(1)*2-1;
    HorzMid=HorzLow+2;
    HorzMidG=[];
    HorzHigh=HorzLow+HorzDif;
    VertMid=VertLow+HorzDif+2;
    VertMidG=[];
    for ii=1:1:Size(1)
        
        for jj=1:1:Size(1)-1
            
            HorzMidG=[HorzMid;HorzMidG];
            HorzMid=HorzMid+2;
        end
        
        for ll=1:1:Size(1)-1
            
            VertMidG=[VertMidG,VertMid];
            VertMid=VertMid+HorzDif+2;
        end
        
        VertVals=[[VertLow,VertMidG,VertHigh];VertVals];
        HorzVals=[HorzVals,[HorzHigh;HorzMidG;HorzLow]];
        VertLow=VertLow+2;
        VertHigh=VertHigh-1;
        HorzLow=HorzLow+HorzDif+2;
        HorzHigh=HorzLow+HorzDif;
        HorzMid=HorzLow+2;
        VertMid=VertLow+HorzDif+2;
        HorzMidG=[];
        VertMidG=[];
        
        
    end
    
    
    HorzVals=flipud(HorzVals);
    LVV=size(VertVals);
    VertVals(:,LVV(2))=flipud(VertVals(:,LVV(2)));
    VertVals=flipud(VertVals);
    
    
    
    %Creating Boxes
    Boxes=[];
    for ii=1:1:length(HorzVals)-1
        for jj=1:1:length(VertVals)-1
            Box=[HorzVals(ii,jj),HorzVals(ii+1,jj),VertVals(ii,jj),VertVals(ii,jj+1)];
            Boxes=[Boxes;Box];
        end
        
    end
    BoxesLeft=Boxes;
    if Size==[3,3]
        QuarterSet1=unique([Boxes(1,:),Boxes(2,:),Boxes(4,:),Boxes(5,:)]);
        QuarterSet2=unique([Boxes(4,:),Boxes(5,:),Boxes(7,:),Boxes(8,:)]);
        QuarterSet3=unique([Boxes(2,:),Boxes(3,:),Boxes(5,:),Boxes(6,:)]);
        QuarterSet4=unique([Boxes(5,:),Boxes(6,:),Boxes(8,:),Boxes(9,:)]);
        
        QuarterSets=[QuarterSet1;QuarterSet2;QuarterSet3;QuarterSet4];
        
    else
        QuarterSets=unique([Boxes(1,:),Boxes(2,:),Boxes(4,:),Boxes(3,:)]);
    end
    AllMoves=1:MaxMoves;
    [State,StateSet]=getState(UsedNN,SBSA,QuarterSets);
    
    
    %Main Program
    while CM~=MaxMoves+1
        EG=0;
        
        RMoves=setdiff(AllMoves,UsedNN);
        [State,StateSet]=getState(UsedNN,SBSA,QuarterSets);
        
        
        if Player==1
            %Player1
            %         [Move,TPMNo]=random(AllowedMoves,TPM);
            [Move,TPMNo]=RLearner(AllowedMoves,TPM,UsedNodes,UsedNN,Boxes,Size,Player1Points,Player2Points,BoxWalls,State,StateSet,SBSA,QuarterSets,Player1Points,Q,1,FA);
            plot(AllowedMoves(1,:,Move),AllowedMoves(2,:,Move),'r')
            Color=[1,0,0];
        else
            %Player2
            
            %GreedyBot
            %             [Move,TPMNo]=Greedy(AllowedMoves,TPM,UsedNodes,UsedNN,Boxes,Size,Player2Points,Player1Points,BoxWalls,State,StateSet,SBSA,QuarterSets,Player2Points,Q,0,FA);
            
            %RandomBot
            [Move,TPMNo]=random(AllowedMoves,TPM);
            plot(AllowedMoves(1,:,Move),AllowedMoves(2,:,Move),'b')
            Color=[1,0,1];
        end
        
        UsedNN=[UsedNN,TPMNo];
        UsedNodes(:,:,CM)= AllowedMoves(:,:,Move);
        AllowedMoves(:,:,Move)=[];
        
        
        [YIB,WhichB]=isBox(UsedNodes,UsedNN,TPMNo,BoxesLeft,Size,BoxWalls);
        if sum(YIB)~=0
            for ii=1:1:length(YIB)
                
                if YIB(ii)==1
                    fillx=[];
                    filly=[];
                    %
                    for kk=1:1:5
                        fillx=[fillx,TPM(1,:,WhichB(ii,kk))];
                        filly=[filly,TPM(2,:,WhichB(ii,kk))];
                        
                        
                    end
                    minx=min(fillx);
                    maxx=max(fillx);
                    miny=min(filly);
                    maxy=max(filly);
                    fzx=[minx,minx,maxx,maxx,minx];
                    fzy=[miny,maxy,maxy,miny,miny];
                    %                     input('FillSquare ')
                    fill(fzx,fzy,Color)
                    
                    
                    
                    
                    if  Player==1
                        Player1Points=Player1Points+1;
                    else
                        Player2Points=Player2Points+1;
                    end
                end
            end
        else
            Ply=Ply+1;
            Player=mod(Ply,2);
        end
        
        
        pause(.001)
        CM=CM+1;
    end
    hold off
    
    
    if Player1Points>Player2Points
        
        Player1Points;
        Player2Points;
        Player1WinTotal=Player1WinTotal+1;
        Player2WinTotal=Player2WinTotal;
    elseif Player2Points>Player1Points
        
        Player1Points;
        Player2Points;
        Player2WinTotal=Player2WinTotal+1;
        Player1WinTotal=Player1WinTotal;
    else
        TieGames=TieGames+1;
    end
    
    Player1PointTotal=Player1PointTotal+Player1Points;
    Player2PointTotal=Player2PointTotal+Player2Points;
    
    clf(figure(1))
    
end

end