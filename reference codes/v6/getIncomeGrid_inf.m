function [Ygrid, TransMrx, minInc, maxInc] = getIncomeGrid_inf

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function returns:
% 1. an income grid
% 2. a vector of minimum incomes in each year
% 3. a vector of maximum incomes in each year
% 4. A Markovian transition matrix (TransMrx) over income realisations

%% ------------------------------------------------------------------------ 
%  Declare the global variables that will be necessary in this function

global sigma mu rho uncertainty     % Structural economic paramters
global Nbnd numPtsY                 % Numerical methods


%% ------------------------------------------------------------------------ 
% CONSTRUCT GRID IN INCOME
% Use truncated log-normal distribution if income is uncertain, otherwise
% just grid points equal to the single point in the (degenerate)
% distribution of income

% If there is no uncertainty

if uncertainty == 0
    Ygrid = exp(mu);            % income is set equal to the exp of the log mean
    minInc = Ygrid;                 
    maxInc = Ygrid;
    TransMrx = [1];             % The transition matrix Q is simply a constant 1
                                % with prob 1 each period income is 1

% If there is uncertainty - income draws are log normally distributed 

elseif uncertainty == 1

    % First get the standard deviation of income (from sigma and rho)
    sigmaInc = sigma/((1-rho^2)^0.5);

    % Split the entire normal distribution into numPtsY sections that are
    % equiprobable. 
    % 'lNormDev': (numPtsY + 1) points that bound the sections
    % 'ly': (numPtsY) expected value in each section
	[ lNormDev, ly ] = getNormDev(mu, sigmaInc, Nbnd, numPtsY );  

    % Get transition matrix TransMrx(i, j) describing the probability of 
    % moving to income j in t+1 from income i in t

    TransMrx = NaN(numPtsY, numPtsY);             % initialise the transition matrix
    for i = 1:1:numPtsY
        for j = 1:1:numPtsY
            hiDraw = (lNormDev(j+1)-mu) - rho * (ly(i)-mu);  % highest innovation that will give us income j tomorrow
            loDraw = (lNormDev(j)-mu)   - rho * (ly(i)-mu);  % lowest  innovation that will give us income j tomorrow
            TransMrx(i,j) = SNcdf(hiDraw/sigma) - SNcdf(loDraw/sigma);
        end %j
            
        % Each row of TransMrx should add up to 1. But it won't due to the 
        % truncation. So we standardise by dividing by the total
        % probability
        TransMrx(i, :) = TransMrx(i, :) ./ sum(TransMrx(i, :));                
       
    end %i

    % Now get income in levels and its bounds
    Ygrid  = exp(ly)';                  % Get y from log y
    minInc = exp(-Nbnd * sigmaInc);     % Get the minimum income in each year 
    maxInc = exp(Nbnd * sigmaInc);      % Get the maximum income in each year 

    % error check
    if (Ygrid(1) < 1e-4) || (Ygrid(numPtsY) > 1e5)
    	warning('Combination of sigma and rho give a very high income variance. Numerical instability possible')
    end
  
end


% ------------------------------------------------------------------------- 
end
