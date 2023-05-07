%% ------------------------------------------------------------------------ 
% Dynamic Economics in Practice
% Monica Costa Dias
% Institute for Fiscal Studies
% January 2018
%
% Acknowledgement: this code was originally developed jointly with Cormac
% O'Dea, to whom I am very grateful.
%
% ------------------------------------------------------------------------- 
% DESCRIPTION
% This program solves and simulates an infinite period consumption and  
% savings problem. It allows for uncertainty in income. The income process 
% can be hardcoded by the user to assume values out of a discrete 
% distibution, or it can be set to follow a log normal autoregessive law of 
% motion. 
%
% The problem is solved by backward induction. It uses one of two options 
% to select the optimal policy in each period: a search algorithm to locate 
% the maximum of the value function or it the solves for the first order 
% conditions (Euler equation).

%% ------------------------------------------------------------------------ 
% PREAMBLE
% Ensure that all storage spaces variables, matrices, memory, globals are 
% clean from information stored in past runs

tic;        % start the clock
clear all;  % clear memory
close all;  % close any graphs

%% ------------------------------------------------------------------------ 
% DECLARE VARIABLES AND MATRICES THAT WILL BE 'GLOBAL'
% explicitly set variables and matrices to be shared throughout the routine
% as globals

global beta gamma r sigma mu rho                    % structural model parameters (1)
global uncertainty                                  % whether allowing for uncertainty in income
global numPtsA Agrid                                % assets grid and dimension
global numPtsY Ygrid incTransitionMrx               % income grid, dimension, and transition matrices 
global interpMethod linearise                       % numerical methods to be used
global tol minCons numSims Nbnd tolForFixedPoint    % numerical constants
global plotNumber                                   % for graphing
global TForSims                                     % time periods to show on graph

%% ------------------------------------------------------------------------ 
% NUMERICAL METHODS
% select solution, interpolation and integration methods

interpMethod = 'pchip';      % interpolation method - choose from 'linear', 'nearest', 'spline', 'pchip'
solveUsingValueFunction = 0; % solution method: set to 1 to solve using value function, else =0
solveUsingEulerEquation = 1; % solution method: set to 1 to solve using Euler equation, else =0
linearise = 1;               % whether to linearise the slope of EV when using EE - set linearise=1 to do this, else = 0


%% ------------------------------------------------------------------------ 
% NUMERICAL CONSTANTS
% set constants needed in numerical solution and simulation

% precision parameters
tol = 1e-10;                 % max allowed error
minCons = 1e-5;              % min allowed consumption
tolForFixedPoint  = 1e-1;    % Tolerance in search for fixed point

% where to truncate the normal distributions
Nbnd = 3;                   % draw only from interval [ mu-Nbnd*sigma , mu+ Nbnd*sigma ] 

% maximum assets on the asset grid
maxSavMult = 100;           % The maximum point on the asset grid will be this times maximum income + starting asset.
                            % If simulations go above this, the programme will crash

% information for simulations
numSims = 2;                % How many individuals to simulate
TForSims = 200;             % How many time periods to simulate


%% ------------------------------------------------------------------------ 
% THE ECONOMIC ENVIRONMENT
% Set values of structural economic parameters

r = 0.01;                    % Interest rate
beta = 0.97;                 % Discount factor
gamma = 1.5;                 % Coefficient of relative risk aversion
mu = 0;                      % mean of initial log income
sigma = 0.25;                % variance of innoviation log income 
rho = 0.75;                  % persistency of log income
borrowingAllowed = 1;        % Is borrowing allowed
uncertainty = 1;             % Is income uncertain?
startA = 0;                  % How much asset do people start life with


%% ------------------------------------------------------------------------ 
% GRIDS
% choose dimensions, set matrices and select methods to construct grids

%The grid for assets
numPtsA = 15;                % number of points in the discretised asset grid
gridMethod = '3logsteps';    % method to construct grid. One of equalsteps, logsteps, 3logsteps, 5logsteps or 10logsteps

%The grid for income shocks
numPtsY = 5;                 %  points in grid for income (should be 2 if hard-coded)


%% ------------------------------------------------------------------------ 
% Check inputs
checkInputs_inf;


%% ------------------------------------------------------------------------ 
% Get income grid
[Ygrid, incTransitionMrx, minInc, maxInc] = getIncomeGrid_inf;


%% ------------------------------------------------------------------------ 
% GET ASSET GRID
% populate grid for assets using 'gridMethod'
% populate matrix borrowingCon

maxAss        = startA + maxInc * maxSavMult;
[ borrowCon ] = getMinAndMaxAss_inf(borrowingAllowed, minInc);
Agrid         = getGrid(borrowCon, maxAss, numPtsA, gridMethod);


%% ------------------------------------------------------------------------ 
% SOLVE CONSUMER'S PROBLEM
% Get policy function and value function 

if solveUsingValueFunction == 1
    [ policyA1, policyC, val, exVal, exDU ] = solveValueFunction_inf;
elseif solveUsingEulerEquation == 1
    [ policyA1, policyC, val, exVal, exDU ] = solveEulerEquation_inf;
end


%% ------------------------------------------------------------------------ 
% SIMULATE CONSUMER'S PATHS
% start from initial level of assets and simulate optimal consumption and
% savings profiles over lifecycle

if uncertainty == 0
    [ ypath, cpath, apath, vpath ] = simNoUncer_inf(policyA1, exVal, startA);
else
    [ ypath, cpath, apath, vpath ] = simWithUncer_inf(policyA1,exVal, startA);
end

%% ------------------------------------------------------------------------ 
% PLOTS
% Plots some features of the simulation and simulation

% Plot paths of consumption, income and assets 
plotNumber = 0;
plotVpath(vpath)
plotApath(apath, borrowCon)
plotYAndCpaths( ypath, cpath );
plotYCAndApaths( ypath, cpath, apath );

% Now plot value and policy functions
plotNode1 = 1;
plotNodeLast = numPtsA-2; 
plotSln; 

toc;     % Stop the clock
% ------------------------------------------------------------------------ 
% ------------------------------------------------------------------------ 
