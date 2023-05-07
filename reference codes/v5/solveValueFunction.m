function [ policyA1, policyC, V, EV, EdU ] = solveValueFunction

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
global T r tol minCons
global numPtsA numPtsY Agrid Ygrid incTransitionMrx 
global Agrid1 EV1


%% ------------------------------------------------------------------------ 
% GENERATE MATRICES TO STORE NUMERICAL APPROXIMATIONS AND INITIATE AS NAN
% Matrices to hold the policy, value and marginal utility functions and the
% expected value of the latter two
% Set dimension of output matrices to equal number of periods x number of
% points in grid for assets

% Matrices to hold the policy, value and marginal utility functions 
V        = NaN(T+1, numPtsA, numPtsY);
policyA1 = NaN(T,   numPtsA, numPtsY);
policyC  = NaN(T,   numPtsA, numPtsY);        
dU       = NaN(T,   numPtsA, numPtsY);

%Matrices to hold expected value and marginal utility functions 
EV  = NaN(T+1, numPtsA, numPtsY);
EdU = NaN(T,   numPtsA, numPtsY);


%% ------------------------------------------------------------------------ 
% Set the terminal value function and expected value function to 0
EV(T + 1, :,:)  = 0;                          % continuation value at T-1
V(T + 1,:,:) = 0; 


%% ------------------------------------------------------------------------ 
% SOLVE RECURSIVELY THE CONSUMER'S PROBLEM, STARTING AT TIME T-1 AND MOVING
% BACKWARDS TO ZERO, ONE PERIOD AT A TIME

for ixt=T:-1:1                                % Loop from time T-1 to 1

    Agrid1 = Agrid(ixt + 1, :);               % The grid on assets tomorrow
    
    % Solve problem at grid points in assets 
    % --------------------------------------
    for ixA = 1:1:numPtsA                     % points on asset grid
        
        % Step 1: Solve problem at grid points in income
        % ----------------------------------------------
        for ixY = 1:1:numPtsY                 % points on income grid
                       
            % Value of income and information for optimisation
            A    = Agrid(ixt, ixA);           % assets today
            Y    = Ygrid(ixt, ixY);           % income today
            lbA1 = Agrid(ixt + 1, 1);         % lower bound: assets tomorrow
            ubA1 = (A + Y - minCons)*(1+r);   % upper bound: assets tomorrow
            EV1  = EV(ixt + 1,:, ixY);        % relevant section of EV matrix (in assets tomorrow)
            
            % Compute solution 
            if (ubA1 - lbA1 < minCons)                 % if liquidity constrained
                negV = objectivefunc(lbA1, A, Y); 
                policyA1(ixt,ixA,ixY) = lbA1;
            else                                       % if interior solution
                [policyA1(ixt,ixA,ixY), negV] = ...
                    fminbnd(@(A1) objectivefunc(A1,A,Y), lbA1, ubA1, optimset('TolX',tol));                                                                                                                                      
            end 

            % Store solution and its value
            policyC(ixt, ixA, ixY) = A + Y - policyA1(ixt, ixA, ixY)/(1+r);
            V(ixt, ixA, ixY)       = -negV; 
            dU(ixt, ixA, ixY)      = getmargutility(policyC(ixt, ixA, ixY));
            
        end %ixY


        % STEP 2. integrate out income today conditional on income
        % yesterday to get EV and EdU
        % --------------------------------------------------------
        realisedV(:,:)  = V(ixt, ixA, :);
        realiseddU(:,:) = dU(ixt, ixA, :);
        for ixY = 1:1:numPtsY
            EV(ixt, ixA, ixY)  = incTransitionMrx(ixY,:)*realisedV;
            EdU(ixt, ixA, ixY) = incTransitionMrx(ixY,:)*realiseddU;
        end %ixY
                   
    end %ixA

    fprintf('Passed period %d of %d.\n',ixt, T)
    
end %ixt


% ------------------------------------------------------------------------ 
end %function

