%% The Cake-Eating Problem and Its Numerical Solution
% See more details in Part 1 and 2 of the corresponding replication file.

% DESCRIPTION
% This program solves and simulates a finite period consumption and saving problem. 
% There is no income or uncertainty. 
% The consumer starts with an amount of assets and chooses how to allocate consumption over time. 

% Numerical Algorithm
% The problem is solved by backward induction using a search algorithm to locate the choice that 
% maximises the value function in each period.

%% Step 1: Set up Parameters

tic;        % start the clock
clear all;  % clear memory
close all;  % close any graphs

% Economic environment
T = 80;                      % Number of time periods
R = 1.01;                    % Interest rate
beta = 0.9;                  % Discount factor
gamma = 1.5;                 % Coefficient of relative risk aversion
a0 = 1;                      % Assets people start life with

%% Step 2: Discretize the State Space
% The column t of assetGrid (gridN by T matrix) stores all potential assets level in time period t.
% The lower and upper bound of the asset grid in time t is contrained by natural borrowing limit 
% and minimum consumption level.

% To discretize a continuous variable, certain computational constants are necessary.
% Among those, the most important one is the number of grid points in asset space!

% Computational constants
gridN = 100;                  % number of points in the discretised asset grid
gridMethod = '10logsteps';   % method to construct grid. 
                             % One of equalsteps, logsteps, 3logsteps, 5logsteps or 10logsteps
interpMethod = 'linear';     

tol = 1e-10;                 % max allowed error
minCons = 1e-5;              % min allowed consumption

% Discretize the asset space
assetInterval = NaN(2, T);
for t = 1:T
  [assetInterval(1,t), assetInterval(2,t)] = fun_AssetInterval(t, a0, T, minCons, R);
end
assetGrid = NaN(gridN, T);
for t = 1:T
  assetGrid(:, t) = fun_GetGrid(assetInterval(1,t), assetInterval(2,t), gridN, gridMethod);
end

%% Step 3: Solve the Model with Search Algorithm

% Step 3.1: Set up the value function and policy function correspondences
% V (gridN by T+1) matrix's entry (j,t) stores the value function in period t 
% with corresponding asset level assetGrid(j, t).
% A_tplus1 (gridN by T+1) matrix's entry (j,t) stores the optimal policy function of next period 
% assets a_{t+1} in period t given the start-of-period asset level is assetGrid(j, t).
% C_t (gridN by T) matrix's entry (j,t) stores the optimal policy function of this period consumption
% in period t given the start-of-period asset level is assetGrid(j, t).

V                = NaN(gridN, T+1);
V(:,T+1)         = 0;
A_tplus1         = NaN(gridN, T);
C_t              = NaN(gridN, T);        


% Step 3.2: Solve recursively the consumer's problem, starting at time T and stepping backward
% The most important step is to search all possible a_{t+1} to maximize RHS in the Bellman equation.
% Here, I incorporate linear interpolation of the value function and fminbnd function in matlab.

for t=T:-1:1
  if t == T
    V(:, t)   = fun_utility(assetGrid(:, t), gamma);
    C_t(:, t) = assetGrid(:, t);
    A_tplus1(:, t) = 0;
  else 
    for ixA = 1:1:gridN
      A_t = assetGrid(ixA, t);
      lb = assetGrid(1,t+1);
      ub = R * A_t;
      neg_obj_func = @(A1) -fun_utility(A_t - A1/R, gamma) - ...
                       beta * interp1(assetGrid(:,t+1), V(:,t+1) , A1, interpMethod, 'extrap');
      [A_tplus1(ixA, t), neg_V] = fminbnd(neg_obj_func, lb, ub, optimset('TolX',tol));
      V(ixA, t) = -neg_V;
      C_t(ixA, t) = A_t - A_tplus1(ixA, t);
    end % end the loop for all possible start-of-period asset values 
  end % end if t==T or t~=T
end % end the loop for all t from T backwards to 1

%% Step 4: Simulate the Consumption and Asset Path

consum = NaN(1, T);   % consumption
value  = NaN(1, T);   % value
asset  = NaN(1, T+1); % column j value is the asset level at start of each period j-1

asset(1, 1) = a0;   
for t = 1:1:T                     % loop through time periods for a particular individual
    value(1, t)   = interp1(assetGrid(:, t), V(:, t), asset(1, t), interpMethod, 'extrap');                               
    asset(1, t+1) = interp1(assetGrid(:, t), A_tplus1(:, t), asset(1, t), interpMethod, 'extrap'); 
    consum(1, t)  = interp1(assetGrid(:, t), C_t(:, t), asset(1, t), interpMethod, 'extrap'); 
end   

figure(1)
assetplot = plot(asset,'LineWidth',2);
xlabel('Age')
ylabel('Assets')
title('Time path of assets')
saveas(assetplot, 'm1 _ assetplot.jpg')
hold on

figure(2)
consumptionplot = plot(consum,'LineWidth',2);
xlabel('Age')
ylabel('Consumption')
title('Time path of consumption')
saveas(consumptionplot, 'm1 _ consumptionplot.jpg')
hold on

figure(3)
valueplot = plot(assetGrid(:, 3), V(:, 3), 'LineWidth', 2);
xlabel('Asset Level at Time t=3')
ylabel('Value Function')
title('Time path of consumption')
title('Value function')
saveas(valueplot, 'm1 _ valueplot in time t=3.jpg')
hold on

%% Step 5: Compare with the Analytical Answer

% The formulas for analytical solutions is in the Part 1 of the corresponding replication notes.

alpha = beta^(1/gamma) * R^((1-gamma)/gamma);
consum_anal = NaN(1, T);
for t = 1:T
  consum_anal(1, t) = ((1-alpha)/(1-alpha^T)) * (beta*R)^((t-1)/gamma) * a0;
end

fig5 = figure(5);
consum_comp_nvsa = plot(1:T,consum, 1:T,consum_anal);
xlabel('Age')
ylabel('Consumption')
title('Time path of consumption')
legend('numerical consumption path','analytical consumption path')
saveas(fig5, 'm1 _ Numerical versus Analytical Consumption Path.jpg')
hold on

asset_anal = NaN(1, T+1);
asset_anal(1,1) = a0;
for t=2:(T+1)
  asset_anal(1, t) = R * (asset_anal(1, t-1) - consum_anal(1, t-1)); 
end

fig6 = figure(6);
asset_comp_nvsa = plot(1:T+1,asset, 1:T+1,asset_anal);
xlabel('Age')
ylabel('Asset Levels')
title('Time path of Asset Holding')
legend('numerical assets path','analytical assets path')
saveas(fig6, 'm1 _ Numerical versus Analytical Asset Path.jpg')


toc;