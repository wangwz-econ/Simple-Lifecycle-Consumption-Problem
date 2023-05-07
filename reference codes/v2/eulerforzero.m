function [ euler ] = eulerforzero(A0, A1)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function returns the following quantity:
% u'(c_t) - b(1+r)u'(c_t+1) 
% This quantity equals 0 if the Euler equation u'(c_t) = b(1+r)u'(c_t+1) is 
% satified at c_t

%% ------------------------------------------------------------------------ 
% Declare globals we need this file have access to
global r beta interpMethod 
global dU1 lindU1 linearise
global Agrid1


%% ------------------------------------------------------------------------ 
% Get marginal utility at consumption tomorrow
if linearise == 0
    duAtA1 = interp1(Agrid1, dU1, A1, interpMethod, 'extrap');
elseif linearise == 1
    invDuAtA1 = interp1(Agrid1, lindU1, A1, interpMethod, 'extrap');
    duAtA1    = getmargutility(invDuAtA1);
end    


%% ------------------------------------------------------------------------ 
% Check whether tomorrow's (expected) marginal utility is negative 
% If so throw an error
if (duAtA1 < 0)    
   error('approximated marginal utility in negative')
end


%% ------------------------------------------------------------------------ 
% Get consumption today and the required output
todaycons = A0 - A1/(1+r);
euler     = getmargutility(todaycons) - (beta * (1+r) * duAtA1) ;

end

