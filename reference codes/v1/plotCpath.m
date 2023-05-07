function plotCpath( cpath )

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function plots the simulated path of consumption over the entire set
% of periods

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global plotNumber

%% ------------------------------------------------------------------------ 
% Draw and format graph

plotNumber = plotNumber + 1;
figure(plotNumber)
plot(cpath,'LineWidth',2)
xlabel('Age')
ylabel('Consumption')
title('Time path of consumption')

end

