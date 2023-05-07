function plotCZoomedOut( cpath )

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function plots the silumated path of consumption over the entire set
% of periods, using a fixed range of variation

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global plotNumber T

%% ------------------------------------------------------------------------ 
% Draw and format graph
lowerboundforyaxis = 0; % min(cpath)*0.9;
upperboundforyaxis = 0.12; % max(cpath)*1.1;
 
plotNumber = plotNumber + 1;
figure(plotNumber)
plot(cpath,'LineWidth',2)
axis([1 T lowerboundforyaxis upperboundforyaxis])
xlabel('Age')
ylabel('Consumption')
title('Time path of consumption')

end
