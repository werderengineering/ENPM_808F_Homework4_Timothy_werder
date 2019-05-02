function [Move,TPMNo]=random(AllowedMoves,TPM)

%Determine a move based on the remaining moves
[R,C,M]=size(AllowedMoves);
RandVal=randperm(M);
Move=RandVal(1);
CurMov=AllowedMoves(:,:,Move);
TPMNo = find(arrayfun(@(x) isequal(TPM(:,:,x),CurMov),1:size(TPM,3)));

end