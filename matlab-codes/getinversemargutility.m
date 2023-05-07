function [ invmargut ] = getinversemargutility (margut, gamma)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function calculates the inverse marginal utility, recovering
% consumption


%% ------------------------------------------------------------------------ 
% Invert marginal utility
if gamma == 1
    invmargut = 1./margut;
else
    invmargut = margut.^(-1/gamma);
end

end

