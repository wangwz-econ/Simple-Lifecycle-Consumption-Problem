function [ x ] = SNinv(p)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This routines returns the inverse of the standard normal distribution, 
% ie the deviate associated with a particular value p of the cdf

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global Nbnd

%% ------------------------------------------------------------------------ 
% Compute inverse of normal distribution

if (p<SNcdf(-Nbnd))
	x = -Nbnd;
elseif  (p>SNcdf(Nbnd))
	x = Nbnd;
else
    boundforzero = [-Nbnd, Nbnd];
    x = fzero(@(t) SNcdf(t) - p, boundforzero, optimset('TolX',1e-12));
end

% ------------------------------------------------------------------------- 
end
