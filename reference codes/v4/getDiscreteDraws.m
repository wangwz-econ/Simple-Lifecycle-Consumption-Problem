function [ draws, drawsIndex ] = getDiscreteDraws( values, pdf , dim1, dim2, seed )

% ------------------------------------------------------------------------
% This function draws randomly dim1 x dim2 realisations from a discrete 
% distribution given a seed and stores the draws in 'draws(dim1,dim2)' and
% their indexes in the distribution in 'drawsIndex(dim1,dim2)'

%% ------------------------------------------------------------------------
% Check inputs. In particular, the function assumes values and pdf are
% column vectors. Transpose if not. Also check that they are the same
% size.

if (size(values, 1) == 1) && (size(values, 2) ~= 1); 
    values = values';
end

if (size(pdf, 1) == 1) && (size(pdf, 2) ~= 1) 
    pdf = pdf';
end

if (size(pdf) ~= size(values))
    error('values and pdf must be the same size')
end


%% ------------------------------------------------------------------------
% Initialise the two arrays for output. These will hold respectively the
% random draws and the index of these (i.e. their location in vector
% 'values')
draws      = NaN(dim1, dim2);
drawsIndex = NaN(dim1, dim2);


%% ------------------------------------------------------------------------
% Obtain the cdf and the number of discrete outcomes
cdf       = cumsum(pdf);        % Calculate the cdf from the pdf
numValues = size(values, 1);    % Find the number of possible values


%% ------------------------------------------------------------------------
% Get random draws from a uniform distribution
stream1 = RandStream('mt19937ar','Seed',seed);
RandStream.setGlobalStream(stream1);
reset(stream1);
randUniform = rand(dim1, dim2);


%% ------------------------------------------------------------------------
% Map the draws from the continuous uniform distribution into discret draws
% from a distribution with the provided pdf

draws(      randUniform<cdf(1)) = values(1);     
drawsIndex( randUniform<cdf(1)) = 1;

for ix = 2:1:numValues
	draws(     randUniform>cdf(ix-1) & randUniform<cdf(ix)) = values(ix);
    drawsIndex(randUniform>cdf(ix-1) & randUniform<cdf(ix)) = ix;
end

%see http://blogs.mathworks.com/loren/2008/11/05/new-ways-with-random-numbers-part-i/


% ------------------------------------------------------------------------
end

