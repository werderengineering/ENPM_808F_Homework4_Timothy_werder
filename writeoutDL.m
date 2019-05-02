function Lernt=writeoutDL(DLSA,DLQEpisode,Size)

%This file writes the State Action paris and Q Values of the Episodes to a
%python file

someStateActions = DLSA;
someQs = DLQEpisode;

fid = fopen('States.py', 'w');
fprintf(fid, "import numpy as np \n");
fprintf(fid, "someStateActions = np.array([");
for i = 1:size(someStateActions, 1)
    fprintf(fid, "[");
    for j = 1:size(someStateActions, 2)
        if j == size(someStateActions, 2)
            fprintf(fid, "%f", someStateActions(i, j));
        else
            fprintf(fid, "%f,", someStateActions(i, j));
        end
    end
    if i == size(someStateActions, 1)
        fprintf(fid, "]");
    else
        fprintf(fid, "],");
    end
end
fprintf(fid, "]) \n");
fprintf(fid, "someQs = np.array([");
for i = 1:size(someQs, 1)
    fprintf(fid, "[");
    fprintf(fid, "%f", someQs(i));
    if i == size(someQs, 1)
        fprintf(fid, "]");
    else
        fprintf(fid, "],");
    end
end
fprintf(fid, "]) \n");

fclose(fid);

if Size==[3,3]
    [response,Lernt]=system("python DLQApprox3x3.py");
    
else
    [response,Lernt]=system("python DLQApprox.py");
end

end