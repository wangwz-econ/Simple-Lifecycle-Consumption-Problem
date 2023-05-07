function [ BC ] = getMinAndMaxAss_inf(borrowingAllowed, minIncome)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This fuction returns the minimum on the asset grid in an infinite
% horizon. The minimum is the natural borrowing constraint.

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global r minCons


%% ------------------------------------------------------------------------ 
% Lower bound in assets

BC = - 1/r * (minIncome - minCons);

if (borrowingAllowed == 0)        
    BC(BC<0) =  0;
end


% ------------------------------------------------------------------------- 
end

