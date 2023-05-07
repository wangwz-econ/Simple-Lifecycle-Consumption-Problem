function [ inv_marg_utils ] = fun_utility_D_inv(mu, gamma)
% DESCRIPTION
% This function returns the inverst of marginal utility, i.e., the inverst of u'. 
% The utility function is CRRA with CRRA coefficient gamma.
% Inputs: mu and gamma (CRRA coefficient)

if gamma == 1
  inv_marg_utils = 1./mu;
else
  inv_marg_utils = (mu.^(-1/gamma));
end

end

