function [ policyA1, policyC, V, EV, EdU ] = solveValueFunction_inf

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function constructs the value function and the policy function (i.e. 
% optimal next-period asset choice) for each time period. It then
% integrates the value and marginal utility functions over income to get 
% their expected value at t as seen from period t-1.
% 
% The problem is solved by backwards recursion. The choice of the optimal 
% level of savings is calculated in each period using 'fminbnd'. This is an 
% in-built optimiser in Matlab, a routine that combines two methods,
% 'golden section search' and 'parabolic interpolation'.

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to

global r tol minCons
global numPtsA numPtsY Agrid Ygrid incTransitionMrx 
global Agrid1 EV1
global tolForFixedPoint

%% ------------------------------------------------------------------------ 
% GENERATE MATRICES TO STORE NUMERICAL APPROXIMATIONS AND INITIATE AS NAN
% Matrices to hold the policy, value and marginal utility functions and the
% expected value of the latter two
% Set dimension of output matrices to equal number of periods x number of
% points in grid for assets

% Matrices to hold the policy, value and marginal utility functions 
V        = NaN(numPtsA, numPtsY);
policyA1 = NaN(numPtsA, numPtsY);
policyC  = NaN(numPtsA, numPtsY);        
dU       = NaN(numPtsA, numPtsY);

%Matrices to hold expected value and marginal utility functions 
EV  = NaN(numPtsA, numPtsY);
EdU = NaN(numPtsA, numPtsY);


%% ------------------------------------------------------------------------ 
% INITIAL GUESS FOR THE EXPECTED UTILITY FUNCTION
EV(:,:)  = 0;          % initial guess


%% ------------------------------------------------------------------------ 
% SOLVE THE MODEL BY ITERATING ON THE VALUE FUNCTION UNTIL WE REACH A FIXED
% POINT
diff = 1;
ixiter = 0;

while diff > tolForFixedPoint          % Iterate until we've found a fixed point
    
    ixiter = ixiter + 1;               % Augment iteration index
    EV0 = EV;                          % Store previous approximation to EV as EV0
    Agrid1 = Agrid;

    % Solve problem at grid points in assets 
    % --------------------------------------
    for ixA = 1:1:numPtsA

        % Step 1: Solve problem at grid points in income
        % ----------------------------------------------
        for ixY = 1:1:numPtsY
                        
            % Value of income and information for optimisation
            A    = Agrid(ixA);               % assets today
            Y    = Ygrid(ixY);               % income today
            lbA1 = Agrid(1);                 % lower bound: assets tomorrow
            ubA1 = (A + Y - minCons)*(1+r);  % upper bound: assets tomorrow
            EV1  = EV(:, ixY);               % relevant section of EV matrix (in assets tomorrow)
            
            % Compute solution 
            if (ubA1 - lbA1 < tol)                    % if liquidity constrained
                negV = objectivefunc(lbA1, A, Y); 
                policyA1(ixA,ixY) = lbA1;
            else                                      % if interior solution
                [policyA1(ixA,ixY), negV] = ...
                    fminbnd(@(A1) objectivefunc(A1, A, Y), lbA1, ubA1, optimset('TolX',tol));                                                                                                                                      
            end

            % Store solution and its value
            policyC(ixA, ixY) = A + Y - policyA1(ixA, ixY)/(1+r);
            V(ixA, ixY)       = -negV; 
            dU(ixA, ixY)      = getmargutility(policyC(ixA, ixY));
            
        end %ixY


        % STEP 2. integrate out income today conditional on income
        % yesterday to get EV and EdU
        % --------------------------------------------------------
        for ixY = 1:1:numPtsY
            EV(ixA, ixY)  = incTransitionMrx(ixY,:)*V(ixA, :)';
            EdU(ixA, ixY) = incTransitionMrx(ixY,:)*dU(ixA, :)';
        end %ixY
                   
    end %ixA

    diff = max(max(abs(EV - EV0)));
    fprintf('Iteration: %d. Diff %d.\n',ixiter, diff)
    
end %while diff > 1e-10 


% ------------------------------------------------------------------------- 
end %function

