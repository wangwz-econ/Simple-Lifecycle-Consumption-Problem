function [Ygrid, minInc, maxInc] = getIncomeGrid

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function returns:
% 1. an income grid
% 2. a vector of minimum incomes in each year
% 3. a vector of maximum incomes in each year

%% ------------------------------------------------------------------------ 
%  Declare the global variables that will be necessary in this function
global T Tretire mu              % Structural economic paramters

%% ------------------------------------------------------------------------ 
% CONSTRUCT GRID IN INCOME
% In the absence of uncertainty, income flows at a constant rate each
% period before retirement

% construct matrices
Ygrid  = exp(mu) .* ones(T,1);
minInc = Ygrid;
maxInc = Ygrid;

% and set possible income to zero after retirement
Ygrid(Tretire:T, :)  = 0;
minInc(Tretire:T, :) = 0;
maxInc(Tretire:T, :) = 0;

end
