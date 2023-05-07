function [ margut ] = getmargutility (cons)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function calculates the marginal utility of consumption.

%% ------------------------------------------------------------------------ 
% Declare globals we need this file have access to
global gamma

%% ------------------------------------------------------------------------ 
% Calculate marginal utility

if cons<=0
   error('Consumption is <=0');
end
                                
if gamma == 1
    margut = 1./(cons);
else
    margut = (cons).^(-gamma);
end

end

