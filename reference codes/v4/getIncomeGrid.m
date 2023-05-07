function [Ygrid, TransMrx, minInc, maxInc] = getIncomeGrid

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function returns:
% 1. an income grid
% 2. a vector of minimum incomes in each year
% 3. a vector of maximum incomes in each year
% 4. A Markovian transition matrix (Q) over income realisations

%% ------------------------------------------------------------------------ 
%  Declare the global variables that will be necessary in this function
global T Tretire               % Structural economic paramters
global hcIncome hcIncPDF       % Income process (hardcoded)
global numPtsY                 % Grid points in income


%% ------------------------------------------------------------------------ 
% CONSTRUCT GRID IN INCOME
% Use hardcoded distribution of income shocks, where shocks are drawn from
% a hard-coded discrete distribution

% Construct matrix Ygrid, of dimensions (T,numPtsY), that stores the grid 
% in income for each year
Ygrid = repmat(hcIncome', T, 1);

% And store bounds for the income shocks
minInc = min(hcIncome) .* ones(T, 1);          
maxInc = max(hcIncome) .* ones(T, 1);

% Replace these arrays with zeros for all years after retirement
% (set Tretire=1 to turn off income altogether)
Ygrid(Tretire:T, :)  = 0;
minInc(Tretire:T, :) = 0;
maxInc(Tretire:T, :) = 0;


%% ------------------------------------------------------------------------ 
% Store description of the transition matrix
% Without persistency, the transition matrix simply describes the PDF of
% the income shocks
TransMrx = repmat(hcIncPDF, [1, numPtsY]);  


% ------------------------------------------------------------------------
end

