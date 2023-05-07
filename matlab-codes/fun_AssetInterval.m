function [min_asset, max_asset] = fun_AssetInterval(t, a0, T, c_min, R)

% This function returns the possbile asset values in time t with initial assets a0.
% The minimum asset amount is the natural borrowing limit, that is, the case in which the agent 
% consumes the minimum consumption in all later periods until the terminal period T.
% The maximum assets is the amount in the case that the agent with initial assets a0 consumes 
% the minimum consumption in all former periods.

% Inputs: present period t, initial assets a0, number of total periods T,
%         minimum allowed consumption c_min, and gross interest rate R
% Outputs: the lower bound and upper bound of possible assets amount in period t+1

if t > T
  error(fprintf('%d needs to be less than %d', t, T))
elseif t==T
  min_asset = c_min;
  max_asset = R^t * a0 - c_min*(R - R^(t+1)/(1-R));
else
  min_asset = c_min * (R - 1/R^(T-t))/(R-1);
  max_asset = R^t * a0 - c_min*((R-R^(t+1))/(1-R));
end

end