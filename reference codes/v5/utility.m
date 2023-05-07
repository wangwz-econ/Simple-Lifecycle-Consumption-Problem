function [ utils ] = utility (cons)

% ------------------------------------------------------------------------- 
% DESCRIPTION
%This function takes consumption as an argument and returns utility. The
%utility function is CRRA.

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global gamma 

%% ------------------------------------------------------------------------ 
% Check for errors and return error message
if cons<=0 
   error('Error in utility. Consumption is <=0');
end
                                
%% ------------------------------------------------------------------------ 
% Calculate utility of consumption: constant relative risk aversion
if gamma == 1
    utils = log(cons);
else
    utils = ((cons)^(1-gamma)  )/(1-gamma);
end

% ------------------------------------------------------------------------- 
end

