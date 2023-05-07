function [ pdf ] = SNpdf(x)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function returns the pdf of a standard normal at point x

pdf = ((sqrt(2.*pi)).^-1) * (exp( - ((x).^2)/(2)));

% ------------------------------------------------------------------------- 
end

