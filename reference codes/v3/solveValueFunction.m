function [ policyA1, policyC, V, dU  ] = solveValueFunction

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function constructs the value function and the policy function 
% (i.e. optimal next-period asset choice) for each time period.
% From the latter we can work the optimal consumption level.
% 
% The problem is solved by backwards recursion. The choice of the optimal 
% level of savings is calculated in each period using 'fminbnd'. This is an 
% in-built optimiser in Matlab, a routine that combines two methods,
% 'golden section search' and 'parabolic interpolation'.

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global T r tol minCons
global numPtsA Agrid Ygrid
global V1 Agrid1                % tomorrow's value function and asset grid

%% ------------------------------------------------------------------------ 
% GENERATE MATRICES TO STORE NUMERICAL APPROXIMATIONS
% Matrices to hold the policy, value and marginal utility functions 
% Set dimension of output matrices to equal number of periods x number of
% points in grid for assets

% Matrices to hold the policy and value functions 
V        = NaN(T+1, numPtsA);
policyA1 = NaN(T,   numPtsA);
policyC  = NaN(T,   numPtsA);        


%% ------------------------------------------------------------------------ 
%Set the terminal value function to 0
V(T + 1,:) = 0; 


%% ------------------------------------------------------------------------ 
% SOLVE RECURSIVELY THE CONSUMER'S PROBLEM, STARTING AT TIME T-1 AND MOVING
% BACKWARDS TO ZERO, ONE PERIOD AT A TIME

for ixt=T:-1:1                                 % Loop from time T-1 to 1
    
    V1  = V(ixt + 1,:) ;                       % Get tomorrow's value function
    Agrid1 = Agrid(ixt + 1, :);                % Get tomorrow's asset grid

    % get value of income today
    % since in this version there is only 1 grid point in income, we do not
    % need a loop over income
	Y = Ygrid(ixt);

    % Solve problem at grid points in assets      
    for ixA = 1:1:numPtsA                   % points on asset grid
        
        % Information for optimisation
        A    = Agrid(ixt, ixA);                % assets today
        lbA1 = Agrid1(1);                      % assets tomorrow: lower bound
        ubA1 = (A + Y - minCons)*(1+r);        % assets tomorrow: upper bound

        % Compute solution 
        if (ubA1 - lbA1 < tol)                 % if liquidity constrained
        	negV = objectivefunc(lbA1, A, Y); 
            policyA1(ixt,ixA) = lbA1;
        else                                   % if interior solution
        	[policyA1(ixt,ixA), negV] = ...
                fminbnd(@(A1) objectivefunc(A1, A, Y), lbA1, ubA1, optimset('TolX',tol));                     
        end
        
        % Store solution, its value and the marginal utility of optimal
        % consumption
        policyC(ixt, ixA) = A + Y - policyA1(ixt, ixA)/(1+r);
        V(ixt, ixA)       = -negV; 
        dU(ixt, ixA)      = getmargutility(policyC(ixt, ixA));  %not necessary, but maybe interesting to output
        
    end %ixA
            
    fprintf('Passed period %d of %d.\n',ixt, T)
end %ixt

end %function

