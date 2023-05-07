% ------------------------------------------------------------------------- 
% DESCRIPTION
% This script checks that various inputs have possible values and are
% compatible


%% ------------------------------------------------------------------------
% Check beta is not greater than equal to 1 - and warn if it is close to 1

if (beta>0.99)
    warning('beta is close to 1, convergence may be very slow; the closer to one the greater the chance convergence will not be achieved.')
    if (beta>=1)
        error('beta needs to be less than 1 for a solution to exist')
    end
end

if (beta*(1 + r) > 1)
    warning('beta*(1 + r) is greater than 1. A solution exists as long as beta<1 - however, in the optimum, assets will go to infinity.')
end

if (r <1e-2) && (borrowingAllowed == 1)
    if (r == 0)
        error('r is zero and borrowing is allowed. The natural borrowing constraint is not defined. Consider disallowing borrowing.')
    else
        warning('r is very low and borrowing is allowed. The natural borrowing constraint will be very lax (as the formula involves dividing by r). Numerical instability possible')
    end
    
end

%% ------------------------------------------------------------------------
% Check only one of solveUsingValueFunction and solveUsingEulerEquation is
% equal to 1
if (solveUsingValueFunction * solveUsingEulerEquation ~= 0 && solveUsingValueFunction + solveUsingEulerEquation  ~= 1)
    error('Exactly 1 of solveUsingValueFunction and solveUsingEulerFunction must be set equal to 1')
end

%% ------------------------------------------------------------------------
% Check if uncertainty is off that numPtsY is set equal to 1
if (numPtsY~=1) && (uncertainty == 0)
    error('There is no uncertainty but numPtsY was not set to 1.')
end

%% ------------------------------------------------------------------------
% Check that the value of rho is not greater than 1. Warn if close to 1
if (rho>0.999) || (rho <-0.999)
    if (rho>1)  || (rho < 1)     
    error('rho is greater than 1. This code solves a stationary income process. rho greater than 1 implies a non-stationary process.')
    else
    warning('rho is greater than 0.99. This code solves a stationary income process. As rho gets closer to 1 the process approaches nonstationary - possibility of numerical instability.')        
    end
end

%% ------------------------------------------------------------------------
% Check that the standard deviation is not too small
if (sigma<1e-10) && (uncertainty == 1)
    if (sigma<=0) 
        error('sigma is less than or equal to zero')
    else
        warning('sigma is very small and close to zero - possibility of numerical instability. Consider turning uncertainty off.')
    end
end



%% ------------------------------------------------------------------------
if (linearise ~= 0) && (linearise ~=1)
    error('linearise should be either 0 or 1')
end


if (borrowingAllowed ~= 0) && (borrowingAllowed ~=1)
    error('borrowingAllowed should be either 0 or 1')
end

if (uncertainty ~= 0) && (uncertainty ~=1)
    error('uncertainty should be either 0 or 1')
end

