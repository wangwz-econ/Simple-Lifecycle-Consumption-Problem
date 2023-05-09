%% The Cake-Eating Problem and Its Numerical Solution
% See more details in Part 1, 2 and 3 of the replication file.

% DESCRIPTION
% This program solves and simulates a finite period consumption and saving problem. 
% There is no income or uncertainty. 
% The consumer starts with an amount of assets and chooses how to allocate consumption over time. 

% Numerical Algorithm
% The problem is solved by backward induction using the standard method of endogenous grid points.
% See more numerical details in Part 1 of 
%   https://lumbar-tick-4a3.notion.site/Tutorial-for-the-Endogenous-Grid-Method-c3ac8463386c43d69149984f741fbc25.

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
gridMethod = 'equalsteps';   % method to construct grid. 
                             % One of equalsteps, logsteps, 3logsteps, 5logsteps or 10logsteps
interpMethod = 'linear';     

tol = 1e-10;                 % max allowed error
minCons = 1e-5;              % min allowed consumption

% Discretize the asset space
% assetInterval = NaN(2, T);
% for t = 1:T
%   [assetInterval(1,t), assetInterval(2,t)] = fun_AssetInterval(t, a0, T, minCons, R);
% end
% assetGrid = NaN(gridN, T);
% for t = 1:T
%   assetGrid(:, t) = fun_GetGrid(assetInterval(1,t), assetInterval(2,t), gridN, gridMethod);
% end
policy = cell(T, 1);
for t = 1:T
  policy{t}(:,1) = fun_GetGrid(minCons, a0*R^T, gridN, gridMethod);
%   policy{t}(:,1) = assetGrid(:, t);

end

%% Step 3: Solve the Model using the Endogenous Gridpoints Method

% Step 3.1: Set up the value function and policy function correspondences

% All infomation is stored in a cell variable policy. 
% In the {1,t}'s entry of policy, it stores a matrix (gridN by 4) that contains the 
% exogenous end-of-period asset grid (a_{t+1}/R), the endogenous start-of-period asset grid points, 
% the value funcion, and two policy functions in period t.

% The fist col is the exogenous end-of-period asset grid points, 
% the second col is the value function, the third col is the optimal consumption funcion, 
% and the fourth col is the endogenous start-of-period asset grid.

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
    policy{t}(:,2) = fun_utility(policy{t}(:,1), gamma);
    policy{t}(:,3) = policy{t}(:,1); % we only need the two vectors policy{t}(:,3) and policy{t}(:,4)
    policy{t}(:,4) = policy{t}(:,1); %   are equal in each corresponding element!
  else  
    Asset_tplus1 = R * policy{t}(:,1); % next-period start-of-period asset holdings
    consum_tplus1 = interp1(policy{t+1}(:,4), policy{t+1}(:,3), Asset_tplus1, interpMethod, 'extrap');
    rhs = beta * R * fun_utility_D(consum_tplus1, gamma);
    policy{t}(:, 3) = fun_utility_D_inv(rhs, gamma); 
%     marg_u_tplus1 = interp1(policy{t+1}(:,4), fun_utility_D(policy{t+1}(:,3), gamma), Asset_tplus1, interpMethod, 'extrap');
%     policy{t}(:,3) = fun_utility_D_inv(beta*R.*marg_u_tplus1, gamma);
    policy{t}(:,4) = policy{t}(:,3) + policy{t}(:,1);
    policy{t}(:,2) = fun_utility(policy{t}(:,3), gamma) + beta * interp1(policy{t+1}(:,4), policy{t+1}(:,2), Asset_tplus1, interpMethod, 'extrap');
  end
end % end the loop for all t from T backwards to 1

%% Step 4: Simulate the Consumption and Asset Path

consum = NaN(1, T);   % consumption
value  = NaN(1, T);   % value
asset  = NaN(1, T+1); % column j value is the asset level at start of each period j-1

asset(1, 1) = a0;   
for t = 1:1:T                     % loop through time periods for a particular individual                           
    asset(1, t+1) = interp1(policy{t}(2:end,4), R*policy{t}(2:end,1), asset(1, t), interpMethod, 'extrap'); 
    consum(1, t)  = asset(1,t) - asset(1, t+1)/R; 
end   

figure(1)
assetplot = plot(asset,'LineWidth',2);
xlabel('Age')
ylabel('Assets')
title('Time path of assets')
saveas(assetplot, 'm3 _ assetplot.jpg')
hold on

figure(2)
consumptionplot = plot(consum,'LineWidth',2);
xlabel('Age')
ylabel('Consumption')
title('Time path of consumption')
saveas(consumptionplot, 'm3 _ consumptionplot.jpg')
hold on

%% Step 5: Compare with the Analytical Answer

% The formulas for analytical solutions is in the Part 1 of the corresponding replication notes.

alpha = beta^(1/gamma) * R^((1-gamma)/gamma);
consum_anal = NaN(1, T);
for t = 1:T
  consum_anal(1, t) = ((1-alpha)/(1-alpha^T)) * (beta*R)^((t-1)/gamma) * a0;
end

fig5 = figure(5);
consum_comp_nvsa = plot(1:T,consum,'b--o', 1:T,consum_anal,'LineWidth',1);
xlabel('Age')
ylabel('Consumption')
title('Time path of consumption')
legend('numerical consumption path','analytical consumption path')
saveas(fig5, 'm3 _ Numerical versus Analytical Consumption Path.jpg')
hold on

asset_anal = NaN(1, T+1);
asset_anal(1,1) = a0;
for t=2:(T+1)
  asset_anal(1, t) = R * (asset_anal(1, t-1) - consum_anal(1, t-1)); 
end

fig6 = figure(6);
asset_comp_nvsa = plot(1:T+1, asset,'b--o', 1:T+1, asset_anal,'LineWidth',1);
xlabel('Age')
ylabel('Asset Levels')
title('Time path of Asset Holding')
legend('numerical assets path','analytical assets path')
saveas(fig6, 'm3 _ Numerical versus Analytical Asset Path.jpg')


toc;