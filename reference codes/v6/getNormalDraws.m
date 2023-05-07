function [ normalDraws ] = getNormalDraws( mu, sigma, dim1, dim2, seed)

% ------------------------------------------------------------------------- 
% This function returns a dim1 * dim2 matrix of pseudo random draws from
% a tuncated normal distribution with mean mu and standard deviation sigma. 
% A seed is also inputted as well as a truncation point for symmetric
% truncation.

%% ------------------------------------------------------------------------ 
% Set the seed
stream1 = RandStream('mt19937ar','Seed',seed);
RandStream.setGlobalStream(stream1);
reset(stream1);

%% ------------------------------------------------------------------------ 
% Draw standard normal draws, and transform them so they come from a
% distribution with our desired mean and stdev
% Not entirely correct, but does the job quickly
StdRandNormal = randn(dim1, dim2);
normalDraws   = mu .* ones(dim1, dim2) + sigma .* StdRandNormal; 


% ------------------------------------------------------------------------- 
end
