function [ BC, maxA ] = getMinAndMaxAss(borrowingAllowed, minIncome, maxIncome, startA)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This fuction returns the minimum and maximum on the asset grid in each
% year. The minimum is the natural borrowing constraint. The maximum is how
% much one would have if saving everything, conditional on initial assets.

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global T r minCons

%% ------------------------------------------------------------------------ 
% Initialise the output matrices
BC   = NaN(T+1, 1);
maxA = NaN(T+1, 1);
   
%% ------------------------------------------------------------------------ 
% Iteratively, calculate the borrowing constraints and maximum on asset
% grid
    
% Borrowing constraints
BC(T + 1) = 0;
for ixt = T:-1:1
    BC(ixt) = BC(ixt+1)/(1+r) - minIncome(ixt, 1) + minCons;
end

% if borrowing is not allowed, replace negative points in the borrowing
% constraint with zero
if (borrowingAllowed == 0 )
    BC(BC<0) = 0;
end

% Maximum Assets
maxA(1) = startA+1;    % allow for slightly higher initial assets to avoid an empty solution space in assets
for ixt = 2:1:T+1
    maxA(ixt) = (maxA(ixt - 1) + maxIncome(ixt-1) ) * (1+r);
end

% check for errors: return error if interval in assets is empty
for ixt = 1:1:T+1
  if maxA(ixt) < BC(ixt)
    error('maxA<BC')
  end
end

% ------------------------------------------------------------------------
end


