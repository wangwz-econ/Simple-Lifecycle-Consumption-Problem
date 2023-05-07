function [ marg_utils ] = fun_utility_D(consum, gamma)
% DESCRIPTION
% This function returns the marginal utility, i.e., the derivative of u. 
% The utility function is CRRA with CRRA coefficient gamma.

if consum<0
  error('Error in marginal utility function. Consumption is <=0');
end

if gamma == 1
  marg_utils = 1./consum;
else
  marg_utils = (consum).^(-gamma);
end

end