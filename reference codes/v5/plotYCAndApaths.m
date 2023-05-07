function plotYCAndApaths( ypath, cpath, apath )

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function plots the simulated paths of assets, consumption and income
% over the course of life. Does so for each simulated individual 
% separately.

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global plotNumber

plotNumber = plotNumber + 1;
figure(plotNumber)
plot(ypath(:,1),'r','LineWidth',2)
hold on;
plot(cpath(:,1),'g','LineWidth',2)
hold on;
plot(apath(:,1),'b','LineWidth',2)
hold on;
legend('Income','Consumption','Assets');
xlabel('Age');
title('Time path of income, consumption and assets - individual 1')

plotNumber = plotNumber + 1;
figure(plotNumber)
plot(ypath(:,2),'r','LineWidth',2)
hold on;
plot(cpath(:,2),'g','LineWidth',2)
hold on;
plot(apath(:,2),'b','LineWidth',2)
legend('Income','Consumption','Assets');
xlabel('Age');
title('Time path of income, consumption and assets- individual 2')

% ------------------------------------------------------------------------- 
end

