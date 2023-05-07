function [ value ] = objectivefunc(A1, A0, Y)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function returns the following quantity:
% - (u(c) +  b V(A1))
% where c is calculated from today's assets and tomorrow's assets and the
% continuation value is obtained by interpolating EV1 over assets tomorrow

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global beta r interpMethod           % structural model parameters
global Agrid1 EV1                    % tomorrow's asset grid and tomorrow's expected value function

%% ------------------------------------------------------------------------ 
% Get tomorrow's consumption (cons), the value of left over assets (VA1)
% and total value (u(c) + beta * VA1)

cons  = A0  + Y - (A1)/(1+r);
VA1   = interp1(Agrid1, EV1, A1, interpMethod, 'extrap');
value = utility(cons) + beta * VA1;

%% ------------------------------------------------------------------------ 
% The optimisation routine that we use searches for the minimum of the
% function. To obtain the maximum that we are looking for, we multiply the 
% maximising function by -1.

value = - value;

% ------------------------------------------------------------------------- 
end


