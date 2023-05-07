function plotYAndCpaths( ypath, cpath )

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function plots the simulated paths of consumption and income over
% the course of life. Does so for each simulated individual separately.

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global plotNumber

%% ------------------------------------------------------------------------ 
% Draw and format graph

plotNumber = plotNumber + 1;
figure(plotNumber)
plot(ypath(:,1),'r','LineWidth',2)
hold on;
plot(cpath(:,1),'g','LineWidth',2)
hold on;
legend('Income','Consumption');
xlabel('Age');
title('Time path of income and consumption - individual 1')

plotNumber = plotNumber + 1;
figure(plotNumber)
plot(ypath(:,2),'r','LineWidth',2)
hold on;
plot(cpath(:,2),'g','LineWidth',2)
hold on;
legend('Income','Consumption');
xlabel('Age');
title('Time path of income and consumption - individual 2')

% ------------------------------------------------------------------------- 
end

