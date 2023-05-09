function plotApath( apath, borrowingconstraints )

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function plots the simulated path of assets over the entire set
% of periods

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global plotNumber

%% ------------------------------------------------------------------------ 
% Draw and format graph
plotNumber = plotNumber + 1;
figure(plotNumber)
plot(apath,'LineWidth',2)
hold on
% plot(borrowingconstraints, '--g','LineWidth', 2)
% hold on
legend('Assets', 'Borrowing con.');
xlabel('Age')
title('Time path of assets')


end

