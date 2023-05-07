function [ policyA1, policyC, V, EV, EdU  ] = solveEulerEquation_inf

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function constructs the value function and the policy function (i.e. 
% optimal next-period asset choice), which are the same in each period. It 
% then integrates the value and marginal utility functions over income to
% get their expected value at t as seen from period t-1.
%
% The problem is solved by backwards recursion. The choice of the optimal 
% level of savings is calculated in each period using 'fzero'. This is an 
% in-built root-finding routine. We use it to find the solution to the
% Euler equation. 

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to

global tolForFixedPoint r tol linearise minCons
global numPtsA Agrid Ygrid
global incTransitionMrx numPtsY
global Agrid1 Edu1 linEdU1 EV1      % Tomorrow's asset grid, expec marg util, linearised expec marg util and expected value 


%% ------------------------------------------------------------------------ 
% GENERATE MATRICES TO STORE NUMERICAL APPROXIMATIONS AND INITIATE AS NAN
% Matrices to hold the policy, value and marginal utility functions and the
% expected value of the latter two
% Set dimension of output matrices to equal number of periods x number of
% points in grid for assets

% Matrices to hold the policy, value and marginal utility functions 
V        = NaN(numPtsA, numPtsY) ;
policyA1 = NaN(numPtsA, numPtsY) ;
policyC  = NaN(numPtsA, numPtsY) ;   
dU       = NaN(numPtsA, numPtsY);

% Matrices to hold expected value and marginal utility functions 
EV       = NaN(numPtsA, numPtsY);
EdU      = NaN(numPtsA, numPtsY);


%% ------------------------------------------------------------------------ 
% SOLVE THE CONSUMER'S PROBLEM AT INITAL GUESS
% Initial guess: optimal consumption set to equal to half of possible 
% consumption; continuation value set to zero

% solve problem for each grid point in assets
for ixA = 1:1:numPtsA                               % points on asset grid

    % ---------------------------------------------------------------------
    % step 1. solve problem for each grid point in income today
    for ixY = 1:1:numPtsY                           % points on income grid

         % Value of state variables
         Y    = Ygrid(ixY);                         % income today
         A    = Agrid(ixA);                         % assets today
         maxC = A + Y - Agrid(1)/(1+r); 
         policyC(ixA, ixY) = maxC/2;                % guess: consumption
         
         V(ixA, ixY)  = utility(policyC(ixA, ixY));         % value of policyC
         dU(ixA, ixY) = getmargutility(policyC(ixA, ixY));  % marginal value of policyC

    end %ixY

    % ---------------------------------------------------------------------
    % step 2. integrate out income today conditional on income yesterday to
    % get EV and EdU 
    for ixY = 1:1:numPtsY                                     % for each point on the income grid (last income)
        EV(ixA, ixY)  = incTransitionMrx(ixY,:)*V(ixA, :)';   % continuation value (EV_t seen from t-1)
        EdU(ixA, ixY) = incTransitionMrx(ixY,:)*dU(ixA, :)';  % expected marginal utility (EdU_t seen from t-1)
    end %ixY
    
end %ixA


%% ------------------------------------------------------------------------ 
% SOLVE THE MODEL BY ITERATING ON THE VALUE FUNCTION UNTIL WE REACH A FIXED
% POINT

diff = 1;
ixiter = 0;

while diff > tolForFixedPoint    % Iterate until convergence (fixed point is found)
    
    ixiter = ixiter + 1;         % Augment iteration index
    EV0 = EV;                    % Store previous approximation to EV as EV0
    Agrid1 = Agrid;
    
    
    % solve problem for each grid point in assets
    for ixA = 1:1:numPtsA        % Loop through points on the asset grid

        % -----------------------------------------------------------------
        % step 1. solve problem for each grid point in income today
        for ixY = 1:1:numPtsY

            % Information for optimisation
            A = Agrid(ixA);                  % assets today
            Y = Ygrid(ixY);                  % income today
            lbA1 = Agrid(1);                 % lower bound: assets tomorrow
            ubA1 = (A + Y - minCons)*(1+r);  % upper bound: assets tomorrow
            bndForSol = [lbA1, ubA1];        % if the Euler equation has a soluton it will be within these bounds
            Edu1 = EdU(:, ixY);              % relevant section of Edu matrix (in assets tomorrow)     
            if linearise == 1                % get 'linearised' marginal utility tomorrow
                  linEdU1 = getinversemargutility(Edu1);
            end

            % Compute solution 
            signoflowerbound = sign(eulerforzero(A, lbA1, Y));
            if (signoflowerbound == 1) || (ubA1 - lbA1 < tol)       % if liquidity constrained 
                 policyA1(ixA, ixY) = lbA1;
            else                                                    % if interior solution                              
                signofupperbound = sign(eulerforzero(A, ubA1, Y));
                if (signoflowerbound*signofupperbound == 1)
                    error('Sign of lower bound and upperbound are the same - no solution to Euler equation. bug likely')
                end
                [policyA1(ixA, ixY)] = fzero(@(A1) eulerforzero(A, A1, Y), bndForSol, optimset('TolX',tol));
            end

            % Store solution and its value          
            policyC(ixA, ixY) = A + Y - policyA1(ixA, ixY)/(1+r);
            dU(ixA, ixY)      = getmargutility(policyC(ixA, ixY));
            EV1               = EV(:, ixY);                % Relevant part of continuation value matrix given income today - as a fc of assets tomorrow
            V(ixA, ixY)       = -objectivefunc(policyA1(ixA, ixY), A, Y);
        end %ixY

        
        % STEP 2. integrate out income today conditional on income
        % yesterday to get EV and EdU
        % --------------------------------------------------------
        for ixY = 1:1:numPtsY       
            EV(ixA, ixY)  =  incTransitionMrx(ixY,:)*V(ixA, :)';
            EdU(ixA, ixY) =  incTransitionMrx(ixY,:)*dU(ixA, :)';
        end %ixY
        
    end %ixA
   
    diff = max(max(abs(EV - EV0)));    % max over columns and rows of the absolute differences
    fprintf('Iteration: %d. Diff %d.\n',ixiter, diff)

end % while diff > tolForFixedPoint  


% ------------------------------------------------------------------------- 
end

