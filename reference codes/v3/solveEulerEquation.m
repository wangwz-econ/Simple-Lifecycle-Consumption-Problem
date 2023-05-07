function [ policyA1, policyC, V, dU  ] = solveEulerEquation

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function constructs the value function and the policy function (i.e. 
% optimal next-period asset choice) for each time period.
%
% The problem is solved by backwards recursion. The choice of the optimal 
% level of savings is calculated in each period using 'fzero'. This is an 
% in-built root-finding routine. We use it to find the solution to the
% Euler equation. 

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to

global T r tol minCons
global numPtsA Agrid Ygrid linearise
global Agrid1 dU1 lindU1 V1    % tomorrow's asset grid, marginal utilities (dU), linearised dUs and value


%% ------------------------------------------------------------------------ 
% GENERATE MATRICES TO STORE NUMERICAL APPROXIMATIONS
% Matrices to hold the policy, value and marginal utility functions 
% Set dimension of output matrices to equal number of periods x number of
% points in grid for assets

V        = NaN(T+1, numPtsA);
policyA1 = NaN(T,   numPtsA);
policyC  = NaN(T,   numPtsA);        
dU       = NaN(T,   numPtsA);

% If using quasi-linearisation of the marginal utility to solve Euler 
% equation, store relevant section at t+1 in 'lindU1'
lindU1   = NaN(numPtsA, 1);


%% ------------------------------------------------------------------------ 
% Set the terminal value function to 0
V(T + 1,:,:) = 0 ;


%% ------------------------------------------------------------------------ 
% SOLVE PROBLEM AT TIME T, WHEN SOLUTION IS KNOWN
% Optimal consumption equals total resources (assets+income) as there is no 
% value in keeping them for after death

for ixA = 1:1:numPtsA                              % points on asset grid

	% Information for optimisation
    A    = Agrid(T, ixA);                          % assets today
    Y    = Ygrid(T);                               % income today

    % Compute and store solution and its value
    policyC(T,ixA)  = A + Y;                       % optimal consumption
    policyA1(T,ixA) = 0;                           % optimal next period assets
    V(T,ixA)  = utility(policyC(T, ixA));          % value of policyC
    dU(T,ixA) = getmargutility(policyC(T,ixA));    % marginal value of policyC    
end %ixA

fprintf('Passed period %d of %d.\n',T, T)


%% ------------------------------------------------------------------------ 
% SOLVE RECURSIVELY THE CONSUMER'S PROBLEM, BACKWARDS FROM T-1 TO ZERO

for ixt=(T-1):-1:1                         % Loop from time T-1 to 1
    
    Agrid1 = Agrid(ixt + 1, :);            % The grid on assets tomorrow
    dU1 = dU(ixt + 1,:);                   % relevant section of Edu matrix (in assets tomorrow)     
    V1  = V(ixt + 1,:) ;                   % relevant section of V matrix (in assets tomorrow)
    
    % get value of income today
    % since in this version there is only 1 grid point in income, we do not
    % need a loop over income
	Y = Ygrid(ixt);
    
    % solve problem for each grid point in assets today
    for ixA = 1:1:numPtsA                  %Loop through points on the asset grid

        % Information for optimisation
        A    = Agrid(ixt, ixA);            % assets today
        lbA1 = Agrid1(1);                  % lower bound: assets tomorrow
        ubA1 = (A + Y - minCons)*(1+r);    % upper bound: assets tomorrow
        bndForSol = [lbA1, ubA1];          % if the Euler equation has a soluton it will be within these bounds
        if linearise == 1                  % get 'linearised' marginal utility tomorrow
        	lindU1 = getinversemargutility(dU1);
        end
           
        % Compute solution 
        signoflowerbound = sign(eulerforzero(A, lbA1, Y));
        if (signoflowerbound == 1) || (ubA1 - lbA1 < tol)        % if liquidity constrained 
            policyA1(ixt, ixA) = lbA1;
        else                                                     % if interior solution                              
        	signofupperbound = sign(eulerforzero(A, ubA1, Y));
            if (signoflowerbound*signofupperbound == 1)
            	error('Sign of lower bound and upperbound are the same - no solution to Euler equation. Bug likely')
            end
            [policyA1(ixt, ixA)] = fzero(@(A1) eulerforzero(A, A1, Y), bndForSol, optimset('TolX',tol));
        end 
 
        % Store solution and its value          
        policyC(ixt,ixA) = A + Y - policyA1(ixt, ixA)/(1+r);            
        dU(ixt,ixA)      = getmargutility(policyC(ixt, ixA));
        V(ixt,ixA)       = -objectivefunc(policyA1(ixt, ixA), A, Y);

    end %ixA

    fprintf('Passed period %d of %d.\n',ixt, T)
end %ixt

end

