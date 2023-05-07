% ------------------------------------------------------------------------- 
% DESCRIPTION
% This script checks that various inputs have possible values and are
% compatible

%% ------------------------------------------------------------------------
% Check only one of solveUsingValueFunction and solveUsingEulerEquation is
% equal to 1
if (solveUsingValueFunction * solveUsingEulerEquation ~= 0 && solveUsingValueFunction + solveUsingEulerEquation  ~= 1)
    error('Exactly 1 of solveUsingValueFunction and solveUsingEulerFunction must be set equal to 1')
end

%% ------------------------------------------------------------------------
% Check a number of inputs that need to be either 0 or 1
if (linearise ~= 0) && (linearise ~=1)
    error('linearise should be either 0 or 1')
end
