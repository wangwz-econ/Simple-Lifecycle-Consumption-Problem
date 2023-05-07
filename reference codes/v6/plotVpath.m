function plotVpath( vpath )

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function plots the simulated value function over the course of life

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global plotNumber T

%% ------------------------------------------------------------------------ 
% Draw and format graph
plotNumber = plotNumber + 1;
figure(plotNumber)
plot(vpath,'LineWidth',2)
xlabel('Age');
ylabel('Value');
title('Time path of value')

% ------------------------------------------------------------------------- 
end

% function plotVpath( vpath )
% 
% global plotNumber T
% 
% plotNumber = plotNumber + 1;
% figure(plotNumber)
% plot(vpath,'LineWidth',2)
% xlabel('Age');
% ylabel('Value');
% title('Time path of value')
% 
% 
% end
% 
