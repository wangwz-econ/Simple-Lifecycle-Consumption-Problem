function [ value ] = objectivefunc(A1, A0)

% This function returns the following quantity:
% - ( u(c) +  b V( A1) )
% where c is calculated from today's assets and tomorrow's assets

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global beta r interpMethod      % structural model parameters
global Agrid1 V1                % tomorrow's asset grid and value function

%% ------------------------------------------------------------------------ 
% Get tomorrow's consumption (cons), the value of left over assets (VA1) 
% and total value (u(c) + beta * VA1)

% VA1 is obtained by interpolating tomorrow's value function over
% tomorrow's assets grid using 'interp1'. This is a built in interpolation
% routine that is programmed to use various interpolation methods. Can
% allow (or not) for extrapolation outside grid boundaries.

cons  = A0 - (A1)/(1+r);
VA1   = interp1(Agrid1, V1 , A1, interpMethod, 'extrap');
value = utility(cons) + beta * VA1;


%% ------------------------------------------------------------------------ 
% The optimisation routine that we use searches for the minimum of the
% function. To obtain the maximum that we are looking for, we multiply the 
% maximising function by -1.

value = - value;

end

