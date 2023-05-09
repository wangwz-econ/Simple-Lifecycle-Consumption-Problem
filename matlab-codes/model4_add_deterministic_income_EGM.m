%% The Cake-Eating Problem with a Deterministic Income Process and Its Numerical Solution
% See more details in Part 4 of the corresponding replication file.

% DESCRIPTION
% This program solves and simulates a finite period consumption and saving problem.
% There is a income process but there is no uncertainty.
% The consumer starts with an amount of assets and chooses how to allocate consumption over time.

% Numerical Algorithm
% The problem is solved by backward induction using the standard method of endogenous grid points.
% See more numerical details in Part 1 of
% https://lumbar-tick-4a3.notion.site/Tutorial-for-the-Endogenous-Grid-Method-c3ac8463386c43d69149984f741fbc25.

%% Step 1: Set up Parameters

tic;        % start the clock
clear all;  % clear memory
close all;  % close any graphs

% Economic environment
T = 80;                      % Number of time periods
R = 1.01;                    % Interest rate
beta = 0.98;                 % Discount factor
gamma = 1.5;                 % Coefficient of relative risk aversion
a1 = 0;                      % Assets people start life with

% Add Income Process
Tretire = 81;                % Age at which retirement happens (1 for always retired)
mu = 0.06;                      % Constant income growth rate
y1 = 1;

% Computational constants
gridN = 1000;                 % Number of points in the discretised asset grid
gridMethod = 'equalsteps';    % Method to construct grid.
%   One of equalsteps, logsteps, 3logsteps, 5logsteps or 10logsteps
interpMethod = 'linear';

tol = 1e-10;                 % Max allowed error
minCons = 1e-5;              % Min allowed consumption

% Add Model Complexity
borrowingAllowed = 0;        % Whether borrowing is allowed
solveUsingValueFunction = 0; % Solution method: set to 1 to solve using value function, else =0
solveUsingEulerEquation = 0; % Solution method: set to 1 to solve using Euler equation, else =0
solveUsingEGM = 1;           % Solution method: set to 1 to solve using endogenous gridpoints method, else=0

%% Step 2: Discretize the State Space
% The column t of assetGrid (gridN by T matrix) stores all potential assets level in time period t.
% The lower and upper bound of the asset grid in time t is contrained by natural borrowing limit
% and minimum consumption level.

% To discretize a continuous variable, certain computational constants are necessary.
% Among those, the most important one is the number of grid points in asset space!


% Get the income grid
income = NaN(T+1, 1);
for t = 1:T
  income(t) = (1+mu)^t * y1;
end
income(T+1)=0;
income(Tretire:T, :) = 0;

% Discretize the state space
% Because we want to use EGM, we make S_t = a_t + y_t - c_t our exogenous grid points (cash-on-hand).
% The original state variable is Y_t = a_t + y_t.
% In each period t, we need to obtain the minimum and maximum on the exogenous grid.
% The minimum satisfies natural borrowing constraint, i.e., given the income process, the agent's
%   per-period minimum consumption in all following periods, his end-of-last-period asset is 0.
% The maximum is how much would one have if saving everything except for minimum consumption in each
%   former period, conditional on initial assets and income process.

min_saving = NaN(T, 1);
max_saving = NaN(T, 1);
for t = 1:1:T
  if t==1
    max_saving(t) = a1 + income(t) - minCons;
  else
    max_saving(t) = (R * max_saving(t-1)) + income(t) - minCons;
  end
end
for t = T:-1:1
  if borrowingAllowed == 1 % we allow negative assets
    if t == T
      min_saving(t) = minCons - income(t);
    else
      min_saving(t) = minCons + min_saving(t+1)/R - income(t);
    end
  else % In the following case, negative assets in each period is not allowed
    if t == T
      min_saving(t) = 0;
      if min_saving(t)<minCons; min_saving(t)=minCons; end
    else
      min_saving(t) = (minCons + min_saving(t+1) - income(t)) /R;
      if min_saving(t)<minCons; min_saving(t)=minCons; end
    end
  end % end the if-else statement to check whether borrowing is allowed
end % end the for loop to go through T to 1

policy = cell(T, 1);
for t = 1:T
  policy{t}(:, 1) = fun_GetGrid(min_saving(t), max_saving(t), gridN, gridMethod);
end
% 
% max_saving = NaN(T, 1);
% for t = 1:1:T
%   if t==1
%     max_saving(t) = a1 + income(t) - minCons;
%   else
%     max_saving(t) = (R * max_saving(t-1)) + income(t) - minCons;
%   end
% end
% policy = cell(T, 1);
% for t = 1:T
%   policy{t}(:, 1) = fun_GetGrid(minCons, max_saving(t), gridN, gridMethod);
% end
%% Step 3: Solve the Model using the Endogenous Gridpoints Method

% Step 3.1: Set up the value function and policy function correspondences
% All infomation is stored in a cell variable policy.
% In the {t,1}'s entry of policy, it stores a matrix (gridN by 4) that contains the
% exogenous end-of-period asset grid (a_{t+1}/R), the endogenous start-of-period asset grid points,
% the value funcion, and two policy functions in period t.

% The fist col is the exogenous end-of-period asset grid points,
% the second col is the value function, the third col is the optimal consumption funcion,
% and the fourth col is the endogenous start-of-period Y_t grid.
for t = 1:T
  policy{t}(:,2)  = NaN(gridN, 1);
  policy{t}(:,3)  = NaN(gridN, 1);
  policy{t}(:,4)  = NaN(gridN, 1);
end

% Step 3.2: Solve recursively the consumer's problem, starting at time T and stepping backward
% The most important step is to solve the Euler equation for any given end-of-period asset values.
% The remarkable thing here is that there is no root-finding process in this algorithm.

for t=T:-1:1
  if t == T
    % In the last period, we only need Y_T = c_T to ensure maximum, that is, policy{t}(:,3)==policy{t}(:,4).
    % Note that we need to build up the right correspondence between the value function,
    %   optimal consumption, and endogenous Y_T grid.
    % policy{t}(:,2) = fun_utility(policy{t}(:,1), gamma);
    policy{t}(:,3) = policy{t}(:,1);
    policy{t}(:,4) = policy{t}(:,1);
  else
    Y_tplus1 = R * policy{t}(:,1) + income(t+1); % next-period state variable
    consum_tplus1 = interp1(policy{t+1}(:,4), policy{t+1}(:,3), Y_tplus1, interpMethod, 'extrap');
    consum_tplus1(consum_tplus1<minCons) = minCons;
    rhs = beta * R * fun_utility_D(consum_tplus1, gamma);
    policy{t}(:,3) = fun_utility_D_inv(rhs, gamma);
    policy{t}(:,4) = policy{t}(:,3) + policy{t}(:,1);
    policy{t}(:,2) = fun_utility(policy{t}(:,3), gamma) + beta * interp1(policy{t+1}(:,4), policy{t+1}(:,2), Y_tplus1, interpMethod, 'extrap');
%     if borrowingAllowed~=1
%       policy{t}(1,4) = 0;
%       policy{t}(1,3) = 0;
%     end
  end % end the if-else statement to check the terminal period
end % end the loop for all t from T backwards to 1

%% Step 4: Simulate the Consumption and Asset Path
consum = NaN(1, T);
consum_interp = NaN(1, T);
asset  = NaN(1, T+1);
asset_interp  = NaN(1, T+1);
asset(1, 1) = a1;
asset_interp(1, 1) = a1;
Y = NaN(1, T);
Y(1, 1) = a1 + income(1);

for t = 1:1:T                     % loop through time periods for a particular individual
  Y(1, t+1) = R*interp1(policy{t}(:,4), policy{t}(:,1), asset(1,t)+income(t), interpMethod, 'extrap') + income(t+1);
  asset(1, t+1) = Y(1, t+1) - income(t+1);
  asset_interp(1, t+1) = interp1(policy{t}(:,4), R*policy{t}(:,1), asset(1,t)+income(t), interpMethod, 'extrap');
  consum(1, t)  = asset_interp(1,t) + income(t) - asset_interp(1, t+1)/R;
  consum_interp(1, t) = interp1(policy{t}(:,4), policy{t}(:,3), asset(1,t)+income(t), interpMethod, 'extrap');
end

fig1 = figure(1);
plot(1:T+1, asset,'r-*', 1:T+1, asset_interp, 'g-o','LineWidth',1);
legend('asset by indirect calculation','asset by direct interpolation','Location','best')
xlabel('Age')
ylabel('Assets')
title('Time path of assets')
saveas(fig1, 'm4 _ asset path.jpg')
hold on

fig2 = figure(2);
plot(1:T, consum,'r-*', 1:T, consum_interp, 'g-o', 1:T, income(1:T),'LineWidth',1);
legend('consumption by indirect calculation','consumption by direct interpolation', 'income','Location','best')
xlabel('Age')
ylabel('Consumption and Income')
title('Time path of consumption and income')
saveas(fig2, 'm4 _ consumption and income path.jpg')
hold on

toc;

