function [ a1] = checkSimExtrap_inf( lba1,y )

%--------------------------------------------------------------------------
% DESCRIPTION
% This function checks that we do not select a value for next period's 
% assets betlow the borrowing constraint. This could occur for one of two 
% reasons. First it could be that we are extrapolatingusing  in 
% income in the period that is larger than the largest income in the grid.
% In this case we set next period's assets to the lowest permissable
% level. Otherwise it is likely that there is an error - and in this case
% we cause the programme to stop

%% ------------------------------------------------------------------------ 
global Ygrid numPtsY

if (y > Ygrid(numPtsY)) || (y < Ygrid(1)) 
    a1 = lba1;
else
    error('Next periods asset is below minimum permissable assets. And we are not extrapolating. Likely there is a bug')
end


%--------------------------------------------------------------------------
end

