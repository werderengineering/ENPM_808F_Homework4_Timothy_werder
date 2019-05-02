function [YIB,WhichB]=isBox(UsedNodes,UsedNN,TPMNo,Boxes,Size,BoxWalls)
    
    YIB=[];
    WhichB=[];
   
    %Find which boxes were affect by the drawn line 
    [x,y]=find(TPMNo==Boxes);
    BoxWalls=BoxWalls(x)+1;

    
    %Determine if and which box was drawn by seeing how many remaning lines need
    %to be drawn per box
    for ii=1:1:length(x)
        if ismember(Boxes(x(ii),1),UsedNN)==1 && ismember(Boxes(x(ii),2),UsedNN)==1 && ismember(Boxes(x(ii),3),UsedNN)==1 && ismember(Boxes(x(ii),4),UsedNN)==1

            Which=[[Boxes(x(ii),1),Boxes(x(ii),2),Boxes(x(ii),3),Boxes(x(ii),4),Boxes(x(ii),1)]];
            WhichB=[WhichB;Which];
            YIB=[YIB,1];
        else
            Which=[0 0 0 0 0];
            WhichB=[WhichB;Which];
            YIB=[YIB,0];
        end
    end
    return
end
