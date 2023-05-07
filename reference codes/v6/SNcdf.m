function [ cdf ] = SNcdf(x)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function returns the cdf of a standard normal at point x

approxforminusinf = - 20;
cdf = quad(@(t) SNpdf(t), approxforminusinf, x, 1e-12);

% ------------------------------------------------------------------------- 
end

