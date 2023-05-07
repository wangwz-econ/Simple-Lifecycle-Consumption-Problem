function [ euler ] = eulerforzero(A0, A1, Y)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function returns the following quantity:
% u'(c_t) - b(1+r)Eu'(c_t+1) 
% This quantity equals 0 if the Euler equation u'(c_t) = b(1+r)u'(c_t+1) is 
% satified at c_t

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to

global r beta interpMethod 
global Edu1 linEdU1 linearise numPtsA
global Agrid1

%% ------------------------------------------------------------------------ 
% Get marginal utility at consumption tomorrow. 
if linearise == 0
    duAtA1 = interp1(Agrid1, Edu1, A1, interpMethod, 'extrap');
elseif linearise == 1
    invDuatA1 = interp1(Agrid1, linEdU1, A1, interpMethod, 'extrap');
    duAtA1    = getmargutility(invDuatA1);
end    
    
%% ------------------------------------------------------------------------ 
% Check whether tomorrow's (expected) marginal utility is negative 
% If so throw an error
if (duAtA1 < 0)    
   error('approximated marginal utility in negative')
end

%% ------------------------------------------------------------------------
% Check whether tomorrow's (expected) marginal utility is negative . 
% With a standard utility function it should never be negative, but since 
% we allow extrapolation in the approximation, we can get negative marginal 
% utility. If we are extrapolating and we get a negative MU - set MU equal
% to very small number (half the marginal utility of the greatest assets on 
% the grid tomorrow). If we are not extrapolating, return an error message

if (duAtA1 < 0)    
    if (A1 > Agrid1(numPtsA)) 
    	if linearise == 0
        	duAtA1 = Edu1(numPtsA) / 2;
        else 
        	duAtA1 = linEdU1(numPtsA) / 2;
        end
    else %we're not extrapolating
    	error('approximated marginal utility in negative - bug likely');
    end
end
      
%% ------------------------------------------------------------------------ 
% Get consumption today and the required output
todaycons = A0 + Y - A1/(1+r);
euler     = getmargutility(todaycons) - (beta * (1+r) * duAtA1) ;


%--------------------------------------------------------------------------
end

