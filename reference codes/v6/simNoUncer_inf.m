function [ y, c, a, v ] = simNoUncer_inf(policyA1,EV,startingA)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function takes the starting assets, the policy function and the 
% value function and simulates paths of consumption, assets and value in an 
% environment where there is no uncertainty

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to

global TForSims r 
global Agrid Ygrid numSims interpMethod numPtsA


%% ------------------------------------------------------------------------
% Initialise arrays that will hold the paths of income consumption, value
% and assets

% Arguments for output
y = NaN(TForSims, numSims);            % income
c = NaN(TForSims, numSims);            % consumption
v = NaN(TForSims, numSims);            % value
a = NaN(TForSims + 1,numSims);         % this is the path at the start of each period, so we include the 'start' of death

%% ------------------------------------------------------------------------
% Simulate paths using the initial condition and the policy and value
% functions

for s = 1:1:numSims                   % loop through individuals
    
    a(1, s) = startingA;   
    
    for t = 1:1:TForSims              % loop through time periods for a particular individual
        
        y(t  , s) = Ygrid;                        
        v(t  , s) = interp1(Agrid, EV, a(t, s),interpMethod, 'extrap');                               
        a(t+1, s) = interp1(Agrid, policyA1, a(t, s),interpMethod, 'extrap');
        
        % With infinite horizon we cap assets at the top of the grid
        if (a(t+1, s) > Agrid(numPtsA))
            a(t+1, s) = Agrid(numPtsA);
        end                
        
        c(t  , s) = a(t, s)  + y(t, s) - (a(t+1, s)/(1+r));
        
    end %t      
end     %s
  
 
% ------------------------------------------------------------------------- 
end