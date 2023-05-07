%% ------------------------------------------------------------------------ 
% Dynamic Economics in Practice 
% Monica Costa Dias
% Institute for Fiscal Studies
% January 2018

% Acknowledgement: this code was originally developed jointly with Cormac
% O'Dea, to whom I am extremely grateful.


%% ------------------------------------------------------------------------ 
% DESCRIPTION
% This program solves and simulates a finite period consumption and saving 
% (cake-eating problem) problem. There is no income or uncertainty. The
% consumer starts with an endowmnent of assets and chooses how to allocate
% consumption over time. The problem is solved by backward induction using
% a search algorithm to locate the choice that maximises the value function
% in each period.


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

global beta gamma r T        % structural model parameters 
global numPtsA Agrid         % assets grid and dimension
global interpMethod          % numerical interpoation method to be used
global tol minCons           % numerical constants
global plotNumber            % for graphing


%% ------------------------------------------------------------------------ 
% NUMERICAL METHODS
% select solution, interpolation and integration methods
% interpolation method - choose from 'linear', 'nearest', 'spline', 'pchip'
% 'spline' and 'pchip' use piecewise cubic polynomials, latter is shape
% preserving; 'linear' is default option

interpMethod = 'linear';     


%% ------------------------------------------------------------------------ 
% NUMERICAL CONSTANTS
% set constants needed in numerical solution and simulation

% precision parameters
tol = 1e-10;                 % max allowed error
minCons = 1e-5;              % min allowed consumption


%% ------------------------------------------------------------------------ 
% THE ECONOMIC ENVIRONMENT
% Set values of structural economic parameters and initial values for
% simulations

T = 80;                      % Number of time periods
r = 0.01;                    % Interest rate
beta = 1/(1+r);              % Discount factor
gamma = 1.5;                 % Coefficient of relative risk aversion
startA = 1;                  % Assets people start life with


%% ------------------------------------------------------------------------ 
% GRIDS
% choose dimension and select methods to construct grids

% grid for assets
numPtsA = 20;                % number of points in the discretised asset grid
gridMethod = 'equalsteps';   % method to construct grid. One of equalsteps, logsteps, 3logsteps, 5logsteps or 10logsteps


%% ------------------------------------------------------------------------ 
% GET ASSET GRID
% populate assets' grid for each period using 'gridMethod'

[ MinAss, MaxAss ] = getMinAndMaxAss(startA);

Agrid = NaN(T+1, numPtsA);
for ixt = 1:1:T+1
    Agrid(ixt,:) = getGrid(MinAss(ixt), MaxAss(ixt), numPtsA, gridMethod);
end


%% ------------------------------------------------------------------------ 
% SOLVE CONSUMER'S PROBLEM
% Get policy function and value function in all periods and for all grid
% points

[ policyA1, policyC, val] = solveValueFunction;


%% ------------------------------------------------------------------------ 
% SIMULATE CONSUMER'S PATHS
% start from initial level of assets and simulate optimal consumption and
% savings profiles over lifecycle

[ cpath, apath, vpath ] = simNoUncer(policyA1, val, startA);


%% ------------------------------------------------------------------------ 
% PLOTS
% Plots some features of the simulations

% Plot paths of consumption and assets 
plotNumber = 0;
plotApath(apath)
plotCpath(cpath)
%plotCZoomedOut(cpath)

% Plot value function
whichyear = 1;
plotNode1 = 3;
plotNodeLast = numPtsA; 
plotV;


%% ------------------------------------------------------------------------
% COMPARE NUMERICAL AND ANALYTICAL SOLUTIONS

% Get the analytical policy functions: can do this in the absence of 
% uncertainty and borrowing constraints
[ policyA1_analytic, policyC_analytic] = getPolicy_analytical;

% Get the ratio of numerical policy function to analytic policy functions
ratioOfPolicyC = policyC./policyC_analytic;
ratioOfPolicyA = policyA1./policyA1_analytic;

% Now plot value and policy functions
whichyear = 1;
plotNode1 = 3;
plotNodeLast = numPtsA; 
plotNumericError;


%% ------------------------------------------------------------------------
% STOP THE CLOCK
toc;

% ------------------------------------------------------------------------ 
% ------------------------------------------------------------------------ 
