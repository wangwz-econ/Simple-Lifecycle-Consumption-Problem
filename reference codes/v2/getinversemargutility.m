function [ invmargut ] = getinversemargutility (margut)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function calculates the inverse marginal utility, recovering
% consumption

%% ------------------------------------------------------------------------ 
% Declare globals we need this file have access to
global gamma

%% ------------------------------------------------------------------------ 
% Invert marginal utility
if gamma == 1
    invmargut = 1./margut;
else
    invmargut = margut.^(-1/gamma);
end

end
