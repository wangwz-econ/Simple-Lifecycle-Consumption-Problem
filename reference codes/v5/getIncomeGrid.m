function [Ygrid, TransMrx, minInc, maxInc] = getIncomeGrid

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function returns:
% 1. an income grid
% 2. a vector of minimum incomes in each year
% 3. a vector of maximum incomes in each year
% 4. A Markovian transition matrix (TransMrx) over income realisations

%% ------------------------------------------------------------------------ 
%  Declare the global variables that will be necessary in this function
global T Tretire sigma mu rho uncertainty  % Structural economic paramters
global Nbnd numPtsY                        % Numerical methods


%% ------------------------------------------------------------------------ 
% CONSTRUCT GRID IN INCOME
% Use truncated log-normal distribution if income is uncertain, otherwise
% just grid points equal to the single point in the (degenerate)
% distribution of income

% If there is no uncertainty

if uncertainty == 0
    y = exp(mu);                % income is set equal to the exp of the log mean
    minInc = y;                 
    maxInc = y;
    TransMrx = [1];             % The transition matrix TransMrx is simply a constant 1
                                % with prob 1 each period income is 1

             
% If there is uncertainty - income draws are log normally distributed 

elseif uncertainty == 1

	% Assume that the standard deviation of income does not change over
	% time and calculate it
	sigmaInc = sigma/((1-rho^2)^0.5);

    % Split the entire normal distribution into numPtsY sections that are
    % equiprobable. 
    % 'lNormDev': (numPtsY + 1) points that bound the sections
    % 'ly': (numPtsY) expected value in each section
    [ lNormDev, ly ] = getNormDev( mu, sigmaInc, Nbnd, numPtsY );    


    % Get transition matrix TransMrx(i, j) describing the probability of 
    % moving to income j in t+1 from income i in t
    
	TransMrx = NaN(numPtsY, numPtsY);                        % initialise the transition matrix
    
    for i = 1:1:numPtsY                                      % income i at time t
        for j = 1:1:numPtsY                                  % income j at time t+1
        	hiDraw = (lNormDev(j+1)-mu) - rho * (ly(i)-mu);  % highest innovation that will give income j tomorrow
            loDraw = (lNormDev(j)  -mu) - rho * (ly(i)-mu);  % lowest  innovation that will give income j tomorrow
            TransMrx(i,j) = SNcdf(hiDraw/sigma) - SNcdf(loDraw/sigma);
        end %j
            
        % Each row of TransMrx should add up to 1. But it won't due to the 
        % truncation. So we standardise by dividing by the total
        % probability
        TransMrx(i, :) = TransMrx(i, :) ./ sum(TransMrx(i, :));                
        
    end %i

    % Now get income in levels and its bounds
    y = exp(ly);                    % Get y from log y
    minInc = exp(-Nbnd * sigmaInc); % Get the minimum income in each year 
    maxInc = exp(Nbnd * sigmaInc);  % Get the maximum income in each year 
    
    % error check
    if (y(1) < 1e-4) || (y(numPtsY) > 1e5)
        warning('Combination of sigma and rho give a very high income variance. Numerical instability possible')
    end
        
end  % if uncertainty == 0


% Now construct matrix Ygrid, of dimensions (T,numPtsY), that stores the 
% grid in income for each year
Ygrid = repmat(y', T, 1);

% And store bounds for the income shocks
minInc = repmat(minInc', T, 1);          
maxInc = repmat(maxInc', T, 1);

% Replace these arrays with zeros for all years after retirement
% (set Tretire=1 to turn off income altogether)
Ygrid(Tretire:T, :)  = 0;
minInc(Tretire:T, :) = 0;
maxInc(Tretire:T, :) = 0;


% ------------------------------------------------------------------------- 
end
