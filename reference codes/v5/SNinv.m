function [ x ] = SNinv(p)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This routines returns the inverse of the standard normal distribution, 
% ie the deviate associated with a particular value p of the cdf

boundforzero = [-5, 5];
x = fzero(@(t) SNcdf(t) - p, boundforzero, optimset('TolX',1e-12));

% ------------------------------------------------------------------------- 
end
