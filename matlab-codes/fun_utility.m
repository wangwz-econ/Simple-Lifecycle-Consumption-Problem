function [ utils ] = fun_utility (consum, gamma)

% DESCRIPTION
% This function takes consumption as an argument and returns utility. The utility function is CRRA
% with CRRA coefficient gamma.

if consum<=0
  error('Error in utility. Consumption is <=0');
end

if gamma == 1
  utils = log(consum);
else
  utils = ((consum).^(1-gamma))./(1-gamma);
end

end