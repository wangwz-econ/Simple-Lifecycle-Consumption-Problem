function [ y, c, a, v ] = simWithUncer_inf(policyA1,EV,startingA)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function takes the starting assets, the policy function and the 
% value function and simulates paths of consumption, assets and value when
% income in random

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global mu sigma rho r
global Agrid Ygrid numSims TForSims numPtsA
global Nbnd


%% ------------------------------------------------------------------------
% Initialise arrays that will hold the paths of income consumption, value
% and assets

% Arrays for output
y = NaN(TForSims, numSims);            % income
c = NaN(TForSims, numSims);            % consumption
v = NaN(TForSims, numSims);            % value
a = NaN(TForSims + 1,numSims);         % this is the path at the start of each period, so we include the 'start' of death

% Other arrays that will be used below
e          = NaN(TForSims, numSims);   % the innovations to log income
logy1      = NaN(1, numSims);          % draws for initial income
ly         = NaN(TForSims, numSims);   % log income
ypathIndex = NaN(TForSims, numSims);   % holds the index (location) in the vector 


%% ------------------------------------------------------------------------
% Construct path of income

% First draw randomly from the distribution of initial income and income 
% innovations using function getNormalDraws

seed1 = 1223424; % For the innovations
seed2 = 234636;  % For initial income

sigmaInc  = sigma/ ((1-rho^2)^0.5);
[ e ]     = getNormalDraws( 0, sigma, TForSims, numSims, seed1);  % normal random draws for the innovation
[ logy1 ] = getNormalDraws( mu, sigmaInc, 1, numSims, seed2);     % normal random draw for initial income

% Now construct stream of income by iterating over the law of motion for
% income
for s = 1:1: numSims                          % loop through individuals
    
    % Get starting income
    ly(1, s) = truncate(logy1(1, s), -Nbnd*sigmaInc, Nbnd*sigmaInc );
    y(1, s)  = exp(ly(1, s));
        
    % Get income in each other period
    for t = 1:1:TForSims-1                    % loop through time periods for a particular individual               
        ly(t+1, s) = (1 -rho) * mu + rho * ly(t, s) + e(t + 1, s);
        ly(t+1, s) = truncate(ly(t+1, s), -Nbnd*sigmaInc, Nbnd*sigmaInc );
        y(t+1, s) = exp( ly(t+1, s) );                
    end % t
 
end % s
    

%% ------------------------------------------------------------------------
% Construct paths of consumption, asset and value profiles

for s = 1:1: numSims                  % loop through individuals

    a(1, s) = startingA;              % initial assets                   
    
    for t = 1:1:TForSims              % loop through time periods for a particular individual               
            
        % Get optimal asset next period and value
        a(t+1, s) = interp2D(Agrid', Ygrid', policyA1, a(t, s), y(t, s));                    
        v(t  , s) = interp2D(Agrid', Ygrid', EV , a(t, s), y(t, s));                           

        % Check whether next period's asset is below the lowest
        % permissable
        if ( a(t+1, s) < Agrid(1) )
        	[ a(t+1, s) ] = checkSimExtrap_inf( Agrid(1),y(t, s)); 
        end
            
        % In the infinite horizon we cap assets at the top of the grid
        if (a(t+1, s) > Agrid(numPtsA))
        	a(t+1, s) = Agrid(numPtsA);
        end                

        % Get consumption from today's assets, today's income and
        % tomorrow's optimal assets           
        c(t, s) = a(t, s)  + y(t, s) - (a(t+1, s)/(1+r));
    end   %t      
end % s


%--------------------------------------------------------------------------
end