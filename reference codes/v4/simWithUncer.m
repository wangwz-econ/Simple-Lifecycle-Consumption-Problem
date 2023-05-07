function [ y, c, a, v ] = simWithUncer(policyA1,EV,startingA)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function takes the starting assets, the policy function and the 
% value function and simulates paths of consumption, assets and value when
% income in random

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global T r Tretire
global Agrid Ygrid numSims interpMethod hcIncPDF;


%% ------------------------------------------------------------------------
% Initialise arrays that will hold the paths of income consumption, value
% and assets

% Arguments for output
y = NaN(T, numSims);            % income
c = NaN(T, numSims);            % consumption
v = NaN(T, numSims);            % value
a = NaN(T + 1,numSims);         % assets at the start of each period, so we include the 'start' of death

% Other arrays that will be used below
ypathIndex = NaN(T, numSims);   % holds the index (location) of income in the vector 


%% ------------------------------------------------------------------------
% Obtain paths using the initial condition and the policy and value
% functions

% First get random discrete draws from the income distribution using 
% subroutine getDiscreteDraws: given a seed (which we set equal to the time 
% period), it draws randomly from vector Ygrid(t,:) with pdf hcIncPDF
for t = 1:1:T 
	seed = t;
    [ y(t, :), ypathIndex(t, :) ] = getDiscreteDraws( Ygrid(t, :), hcIncPDF , 1, numSims, seed );
end

% Now simulate the choices of numSims individuals over the course of their
% life, given initial assets and realised income
for s = 1:1: numSims              % loop through individuals
	
    a(1, s) = startingA;          % initial assets
    
    for t = 1:1:T                 % loop through time periods, from beginning of life onwards
        
        if (t >= Tretire)
        	ixY = 1;              %  any point will do as income after retirment is zero in all grid points!!
        else 
        	ixY = ypathIndex(t, s);
        end

        tA1      = policyA1(t, :, ixY);    % the relevant part of the policy function
        tV       = EV(t, :, ixY);          % the relevant part of the value function
        a(t+1,s) = interp1(Agrid(t,:), tA1 , a(t, s), interpMethod, 'extrap');
        v(t,s)   = interp1(Agrid(t,:), tV , a(t, s), interpMethod, 'extrap');                                         
        c(t,s)   = a(t,s)  + y(t,s) - (a(t+1,s)/(1+r));
    end   %t      

end % s


% ------------------------------------------------------------------------- 
end

