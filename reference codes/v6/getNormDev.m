function [ Z, EVbetweenZ ] = getNormDev(mu, se, trunc, N )
    
% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function returns two vectors:
% Z - a vector of (N+1) normal deviates (numbers) that divide a truncated 
%     normal distribution with mean mu and standard deviation se into N 
%     segments, each of which are equiprobable
% EVbetweenZ - the expected value of the random variables between those
%              two points

%% -------------------------------------------------------------------------   
% Initialise the output
    
Z          = NaN(N + 1, 1);
EVbetweenZ = NaN(N, 1);


%% -------------------------------------------------------------------------   
% Find the points that divide the standard normal into N segments 

% The first and last of these should be minus and plus infinity if we were 
% using an actual normal distribution.  In reality we use a truncated 
% normal distribution and the truncation points bound the domain of the 
% distribution that we are considering
stdZ(1)     = -trunc;
stdZ(N + 1) =  trunc;

% calculate mass below the lower bound
ptrunc = SNcdf(-trunc);

% calculate mass bounded by truncation points
mass = (1-2*ptrunc);

% Now iterate to get the rest of the points
for ixi = 2:1:N
	stdZ(ixi) = SNinv( (ixi-1)*mass/N + ptrunc );
end

% calculate Z
Z = se * stdZ + mu;

%Find the expected value within each interval (Adda & Cooper, pp 58)
PDF = SNpdf(stdZ);
for ixi = 1:1:N
	EVbetweenZ(ixi) = N * se * (PDF(ixi) - PDF(ixi+1)) + mu;
end 

% -------------------------------------------------------------------------
end


