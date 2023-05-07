function [ y, c, a, v ] = simWithUncer(policyA1,EV,startingA)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function takes the starting assets, the policy function and the 
% value function and simulates paths of consumption, assets and value when
% income in random

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global mu sigma rho T r Tretire
global Agrid Ygrid numSims 
global Nbnd

%% ------------------------------------------------------------------------
% Initialise arrays that will hold the paths of income consumption, value
% and assets

% Arguments for output
y = NaN(T, numSims);            % income
c = NaN(T, numSims);            % consumption
v = NaN(T, numSims);            % value
a = NaN(T + 1,numSims);         % assets at the start of each period, so we include the 'start' of death

% Other arrays that will be used below
e          = NaN(T, numSims);   % the innovations to log income
logy1      = NaN(1, numSims);   % draws for initial income
ly         = NaN(T, numSims);   % log income
ypathIndex = NaN(T, numSims);   % holds the index (location) in the vector 


%% ------------------------------------------------------------------------
% Construct path of income

% First draw randomly from the distribution of initial income and income 
% innovations using function getNormalDraws

seed1 = 1223424; % For the innovations
seed2 = 234636;  % For initial income

sigmaInc = sigma/ ((1-rho^2)^0.5);
[ e ]     = getNormalDraws( 0, sigma, T, numSims, seed1);     % normal random draws for the innovation
[ logy1 ] = getNormalDraws( mu, sigmaInc, 1, numSims, seed2); % normal random draw for initial income

% Now construct stream of income by iterating over the law of motion for
% income
for s = 1:1: numSims                           % loop through individuals

    ly(1,s) = truncate( logy1(1,s), -Nbnd*sigmaInc, Nbnd*sigmaInc );
    y(1,s)  = exp( ly(1,s) );
    
    for t = 1:1:T-1                            % loop through time periods for a particular individual
        ly(t+1,s) = mu + rho * (ly(t,s)-mu) + e(t+1,s);
        ly(t+1,s) = truncate(ly(t+1,s), -Nbnd*sigmaInc, Nbnd*sigmaInc );
        y(t+1,s)  = exp( ly(t+1,s) );                
    end

    y(Tretire:T, s) = 0;                       % no income after retirement

end % s

%% ------------------------------------------------------------------------
% Construct paths of consumption, asset and value profiles

for s = 1:1: numSims           

    a(1, s) = startingA;                       % initial assets
    
    for t = 1:1:T                              % loop through time periods for a particular individual               
        
        if (t < Tretire)                       % first for the before retirement periods
        
            clear tA1 tV;                      % auxilliary matrices to hold policy and value functions
            tA1(:,:) = policyA1(t, :, :);      % the relevant part of the policy function
            tV(:,:)  = EV(t, :, :);            % the relevant part of the value function                
            a(t+1, s) = interp2D(Agrid(t,:)', Ygrid(t, :)', tA1, a(t, s), y(t, s));                    
            v(t  , s) = interp2D(Agrid(t,:)', Ygrid(t, :)', tV , a(t, s), y(t, s));
            
        else                                   % next for the post retirement periods
            
            clear tA1 tV;
            tA1 = policyA1(t, :, 1);           % the relevant part of the policy function 
            tV  = EV(t, :, 1);                 % the relevant part of the value function                
            a(t+1,s) = interp1(Agrid(t,:)', tA1, a(t, s), 'linear', 'extrap');
            v(t,  s) = interp1(Agrid(t,:)', tV , a(t, s), 'linear', 'extrap');
        
        end
            
        % Check whether next period's asset is below the lowest permissable
        if ( a(t+1, s) < Agrid(t+1, 1) )
        	a(t+1, s) = Agrid(t+1, 1); 
        end
        
        % Get consumption from today's assets, today's income and
        % tomorrow's optimal assets
        c(t, s) = a(t, s)  + y(t, s) - (a(t+1, s)/(1+r));
        if c(t, s)<=0
            error('Simulated consumption is <=0');
        end
        
    end   %t      
    
end % s


%-------------------------------------------------------------------------% 
end