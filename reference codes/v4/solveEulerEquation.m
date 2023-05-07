function [ policyA1, policyC, V, EV, EdU  ] = solveEulerEquation

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function constructs the value function and the policy function (i.e. 
% optimal next-period asset choice) for each time period. It then
% integrates the value and marginal utility functions over income to get 
% their expected value at t as seen from period t-1.
%
% The problem is solved by backwards recursion. The choice of the optimal 
% level of savings is calculated in each period using 'fzero'. This is an 
% in-built root-finding routine. We use it to find the solution to the
% Euler equation. 

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to

global T r tol linearise minCons
global numPtsA Agrid Ygrid
global incTransitionMrx numPtsY
global Agrid1 Edu1 linEdU1 EV1    % Tomorrow's asset grid, expec marg util, linearised expec marg util and expected value 


%% ------------------------------------------------------------------------ 
% GENERATE MATRICES TO STORE NUMERICAL APPROXIMATIONS
% Matrices to hold the policy, value and marginal utility functions and the
% expected value of the latter two
% Set dimension of output matrices to equal number of periods x number of
% points in grid for assets

% Matrices to hold the policy, value and marginal utility functions 
V        = NaN(T + 1, numPtsA, numPtsY);
policyA1 = NaN(T    , numPtsA, numPtsY);
policyC  = NaN(T,     numPtsA, numPtsY);   
dU       = NaN(T,     numPtsA, numPtsY);

% Matrices to hold expected value and marginal utility functions 
EV       = NaN(T + 1, numPtsA, numPtsY);
EdU      = NaN(T,     numPtsA, numPtsY);


%% ------------------------------------------------------------------------ 
% Set the terminal value function and expected value function to 0
V(T + 1,:,:)   = 0;
EV(T + 1,:,:)  = 0;


%% ------------------------------------------------------------------------ 
% SOLVE PROBLEM AT TIME T, WHEN SOLUTION IS KNOWN
% Optimal consumption equals total resources (assets+income) as there is no 
% value in keeping them for after death

% solve problem for each grid point in assets
for ixA = 1:1:numPtsA                               % points on asset grid

    % ---------------------------------------------------------------------
    % step 1. solve problem for each grid point in income today
    for ixY = 1:1:numPtsY                           % points on income grid

         % Value of state variables
         Y = Ygrid(T, ixY);                         % income today
         A = Agrid(T, ixA);                         % assets today

         % Compute and store solution and its value
         policyC(T,ixA,ixY)  = A + Y;                         % optimal consumption
         policyA1(T,ixA,ixY) = 0;                             % optimal next period assets
         V(T,ixA,ixY)  = utility(policyC(T,ixA,ixY));         % value of policyC
         dU(T,ixA,ixY) = getmargutility(policyC(T,ixA,ixY));  % marginal value of policyC

    end %ixY

    % ---------------------------------------------------------------------
    % step 2. integrate out income today conditional on income yesterday to
    % get EV and EdU 
    realisedV(:,:)  = V(T,ixA,:);
    realiseddU(:,:) = dU(T,ixA,:);    
    for ixY = 1:1:numPtsY                                     % for each point on the income grid at T-1 (last income)
        EV(T,ixA,ixY)  = incTransitionMrx(:,ixY)'*realisedV;  % continuation value at T-1
        EdU(T,ixA,ixY) = incTransitionMrx(:,ixY)'*realiseddU; % expect marginal utility at T
    end %ixY
    
end %ixA

fprintf('Passed period %d of %d.\n',T, T)


%% ------------------------------------------------------------------------ 
% SOLVE RECURSIVELY THE CONSUMER'S PROBLEM, BACKWARDS FROM T-1 TO ZERO

for ixt=(T-1):-1:1                              % Loop from time T-1 to 1

    Agrid1 = Agrid(ixt + 1, :);                 % The grid on assets tomorrow

    % solve problem for each grid point in assets
    for ixA = 1:1:numPtsA                       % Loop through points on the asset grid

        % -----------------------------------------------------------------
        % step 1. solve problem for each grid point in income today
        for ixY = 1:1:numPtsY                   % Loop through points on the income grid

            % Value of income and information for optimisation
            A = Agrid(ixt, ixA);                % assets today
            Y = Ygrid(ixt, ixY);                % income today
            lbA1 = Agrid(ixt + 1, 1);           % lower bound: assets tomorrow
            ubA1 = (A + Y - minCons)*(1+r);     % upper bound: assets tomorrow
            bndForSol = [lbA1, ubA1];           % if the Euler equation has a soluton it will be within these bounds
            Edu1 = EdU(ixt + 1,:, ixY);         % relevant section of Edu matrix (in assets tomorrow)     
            if linearise == 1                   % get 'linearised' marginal utility tomorrow
                  linEdU1 = getinversemargutility(Edu1);
            end
           
            % Compute solution 
            signoflowerbound = sign(eulerforzero(A, lbA1, Y));
            if (signoflowerbound == 1) || (ubA1 - lbA1 < tol)        % if liquidity constrained 
                 policyA1(ixt, ixA, ixY) = lbA1;
            else                                                     % if interior solution                              
                signofupperbound = sign(eulerforzero(A, ubA1, Y));
                if (signoflowerbound*signofupperbound == 1)
                    error('Sign of lower bound and upperbound are the same - no solution to Euler equation. Bug likely')
                end
                [policyA1(ixt, ixA, ixY)] = fzero(@(A1) eulerforzero(A, A1, Y), bndForSol, optimset('TolX',tol));
            end

            % Store solution and its value          
            policyC(ixt,ixA,ixY) = A + Y - policyA1(ixt,ixA,ixY)/(1+r);
            dU(ixt,ixA,ixY)      = getmargutility(policyC(ixt,ixA,ixY));
            EV1                  = EV(ixt + 1,:, ixY);                % Relevant part of continuation value matrix given income today - as a fc of assets tomorrow
            V(ixt,ixA,ixY)       = -objectivefunc(policyA1(ixt,ixA,ixY), A, Y);

        end %ixY


        % -----------------------------------------------------------------
        % step 2. integrate out income today conditional on income 
        % yesterday to get EV and EdU 
   
        realisedV(:,:)  = V(ixt,ixA,:);        
        realiseddU(:,:) = dU(ixt,ixA,:);
        for ixY = 1:1:numPtsY                                        % for each point on the income grid (last income)
            EV(ixt,ixA,ixY)  =  incTransitionMrx(:,ixY)'*realisedV;  % continuation value at T-1
            EdU(ixt,ixA,ixY) =  incTransitionMrx(:,ixY)'*realiseddU; % expect marginal utility at T
        end %ixY
        
    end %ixA

    fprintf('Passed period %d of %d.\n',ixt, T)
end %ixt

%--------------------------------------------------------------------------
end

