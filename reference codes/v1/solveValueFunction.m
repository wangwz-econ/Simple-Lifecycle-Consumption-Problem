function [ policyA1, policyC, V ] = solveValueFunction

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
global numPtsA Agrid 
global V1 Agrid1                % tomorrow's value function and asset grid


%% ------------------------------------------------------------------------ 
% GENERATE MATRICES TO STORE NUMERICAL APPROXIMATIONS
% Matrices to hold the policy and value functions 
% Set dimension of output matrices to equal number of periods x number of
% points in grid for assets

V        = NaN(T+1, numPtsA);
policyA1 = NaN(T,   numPtsA);
policyC  = NaN(T,   numPtsA);        


%% ------------------------------------------------------------------------ 
%Set the terminal value function to 0
V(T + 1,:) = 0; 


%% ------------------------------------------------------------------------ 
% SOLVE RECURSIVELY THE CONSUMER'S PROBLEM, STARTING AT TIME T AND MOVING
% BACKWARDS TO ZERO, ONE PERIOD AT A TIME

for ixt=T:-1:1                               % Loop backwards from time T to 1
    
    V1  = V(ixt + 1,:) ;                     % Tomorrow's value function at grid points
    Agrid1 = Agrid(ixt + 1, :);              % Tomorrow's asset grid
    
    % Solve problem at grid points in assets      
    for ixA = 1:1:numPtsA                    % Loop over points on asset grid
        
        % Information for optimisation
        A    = Agrid(ixt, ixA);              % assets today
        lbA1 = Agrid1(1);                    % assets tomorrow: lower bound
        ubA1 = (A - minCons)*(1+r);          % assets tomorrow: upper bound

        % Compute solution
        if (ubA1 - lbA1 < tol)               % if liquidity constrained
        	negV = objectivefunc(lbA1, A); 
            policyA1(ixt,ixA) = lbA1;
        else                                 % if interior solution
            [policyA1(ixt,ixA), negV] = ...
                fminbnd(@(A1) objectivefunc(A1, A), lbA1, ubA1, optimset('TolX',tol));                     
        end % if (ubA1 - lbA1 < tol)          

        % Store solution and its value
        policyC(ixt, ixA) = A - policyA1(ixt, ixA)/(1+r);
        V(ixt, ixA)       = -negV; 
        
    end %ixA

    
    fprintf('Passed period %d of %d.\n',ixt, T)
end %ixt

end %function

