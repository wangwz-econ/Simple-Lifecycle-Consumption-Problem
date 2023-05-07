function truncy = truncate(y, negtrunc, postrunc)

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function truncates random draws.

%% ------------------------------------------------------------------------ 

if (y < negtrunc) % If y is less than the value negtrunc
	truncy = negtrunc;
elseif (y > postrunc)
    truncy= postrunc; % If y is greater than the value postrunc
else
    truncy = y;
end                                

% ------------------------------------------------------------------------- 
end

                 