%% The Cake-Eating Problem and Its Numerical Solution
% See more details in Part 1 and 2 of the corresponding replication file.

% DESCRIPTION
% This program solves and simulates a finite period consumption and saving problem. 
% There is no income or uncertainty. 
% The consumer starts with an amount of assets and chooses how to allocate consumption over time. 

% Numerical Algorithm
% The problem is solved by backward induction using the Euler equation 
% linking this period consumption and next period consumption to locate the choice that 
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
policy = cell(1, T);
for t = 1:T
  policy{t}(:,1) = assetGrid(:, t);
end

%% Step 3: Solve the Model using Euler Equation

% Step 3.1: Set up the value function and policy function correspondences

% All infomation is stored in a cell variable policy. 
% In the {1,t}'e entry of policy, it stores a matrix (gridN by 4) that contains the asset grids, 
% the value funcion, and two policy functions in period t.

% The fist col is asset grid points, the second col is the value function, the third col is the 
% optimal consumption funcion, and the fourth col is the optimal next period asset holdings.

for t = 1:T
  policy{t}(:,2)  = NaN(gridN, 1);
  policy{t}(:,3)  = NaN(gridN, 1);
  policy{t}(:,4)  = NaN(gridN, 1);
end

% Step 3.2: Solve recursively the consumer's problem, starting at time T and stepping backward
% The most important step is to solve the Euler equation for any given start-of-period asset values.
% Here, I first define the Euler Residual Function, then use fzero to find its root.

for t=T:-1:1
  if t == T
    policy{t}(:,2) = fun_utility(policy{t}(:,1), gamma);
    policy{t}(:,3) = policy{t}(:,1);
    policy{t}(:,4) = zeros(gridN, 1);
  else  

%     alpha = beta^(1/gamma) * R^((1-gamma)/gamma);
%     policy{t}.consum = (1-alpha)/(1-alpha^(T-t+1)) .* policy{t}.asset;
%     policy{t}.A_tplus1 = R .* (policy{t}.asset - policy{t}.consum);
%     policy{t}.value = fun_utility(policy{t}.consum, gamma) + ...
%           beta.*interp1(policy{t+1}.asset, policy{t+1}.value, policy{t}.A_tplus1, interpMethod, 'extrap');

    for itx = 1:gridN
      A = policy{t}(itx, 1);                    % state variable: start-of-period asset holdings
      lbc = minCons;                            % lower bound for choice variable: consumption this period
      ubc = A - minCons*((1-1/R^(T-t))/(R-1));  % upper bound for choice variable: consumption this period
      Euler_residual = @(c) fun_utility_D(c, gamma) - ...
        beta*R*fun_utility_D(interp1(policy{t+1}(:, 1), policy{t+1}(:,3), R*(A-c), interpMethod, "extrap"), gamma);
      if ubc<= lbc
        policy{t}(itx,3) = minCons;
      end
      if (sign(Euler_residual(ubc)) * sign(Euler_residual(lbc)) == -1)
        policy{t}(itx,3) = fzero(Euler_residual, [lbc ubc], optimset('TolX',tol));
      else
        warning('In period %d, asset grid number %d calculation, the function values at the interval endpoints must differ in sign.', t, itx);
        if itx==1
          policy{t}(itx,3) = minCons;
        else
          policy{t}(itx,3) = fzero(Euler_residual, ubc, optimset('TolX',tol));
        end
      end
      policy{t}(itx,4) = R * (A - policy{t}(itx,3));
      policy{t}(itx,2) = fun_utility(policy{t}(itx,3), gamma) + ...
        beta*interp1(policy{t+1}(:,1), policy{t+1}(:,2), policy{t}(itx,4), interpMethod, 'extrap');
    end % end the loop for all discretized state space
  end % end if t==T or t~=T
end % end the loop for all t from T backwards to 1

%% Step 4: Simulate the Consumption and Asset Path

consum = NaN(1, T);   % consumption
value  = NaN(1, T);   % value
asset  = NaN(1, T+1); % column j value is the asset level at start of each period j-1

asset(1, 1) = a0;   
for t = 1:1:T                     % loop through time periods for a particular individual
    value(1, t)   = interp1(policy{t}(2:end,1), policy{t}(2:end,2), asset(1, t), interpMethod, 'extrap');                               
    asset(1, t+1) = interp1(policy{t}(2:end,1), policy{t}(2:end,4), asset(1, t), interpMethod, 'extrap'); 
    consum(1, t)  = interp1(policy{t}(2:end,1), policy{t}(2:end,3), asset(1, t), interpMethod, 'extrap'); 
end   

figure(1)
assetplot = plot(asset,'LineWidth',2);
xlabel('Age')
ylabel('Assets')
title('Time path of assets')
saveas(assetplot, 'm2 _ assetplot.jpg')
hold on

figure(2)
consumptionplot = plot(consum,'LineWidth',2);
xlabel('Age')
ylabel('Consumption')
title('Time path of consumption')
saveas(consumptionplot, 'm2 _ consumptionplot.jpg')
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
saveas(fig5, 'm2 _ Numerical versus Analytical Consumption Path.jpg')
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
saveas(fig6, 'm2 _ Numerical versus Analytical Asset Path.jpg')


toc;