% ------------------------------------------------------------------------- 
% DESCRIPTION
% This script plots the policy and value functions against assets for a 
% given time period and value of income

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global plotNumber                                   % for graphing

%% ------------------------------------------------------------------------ 
% PLOT POLICY FUNCTION: CONSUMPTION
% numerical and analytical solutions: consumption as a function of assets 
% in period 'whichyear'

plotNumber = plotNumber + 1;
figure(plotNumber);
plot(Agrid(plotNode1:plotNodeLast), policyC(plotNode1:plotNodeLast,numPtsY), 'g', 'LineWidth', 2)
hold on;
plot(Agrid(plotNode1:plotNodeLast), policyC(plotNode1:plotNodeLast,1), 'r', 'LineWidth', 2)
hold on;
xlabel('Asset');
ylabel('Policy function (consumption function)');
legend('Higest income', 'Lowest income');
title('Policy function (consumption function)')


%% ------------------------------------------------------------------------ 
% PLOT VALUE FUNCTION

plotNumber = plotNumber + 1;
figure(plotNumber);
plot(Agrid(plotNode1:plotNodeLast), val(plotNode1:plotNodeLast,numPtsY), 'g', 'LineWidth', 2)
hold on;
plot(Agrid(plotNode1:plotNodeLast), val(plotNode1:plotNodeLast,1), 'r', 'LineWidth', 2)
hold on;
xlabel('Asset');
ylabel('Value');
legend('Value for highest inc.','Value for lowest inc.');
title('Value function')

% ------------------------------------------------------------------------- 

  
% global plotnumber
% 
% %%
% % GRAPH THE POLICY FUNCTION    
%  plotNumber = plotNumber + 1;
%     figure(plotNumber);
%     plot(Agrid( plotNode1:plotNodeLast),policyC(plotNode1:plotNodeLast, numPtsY),'g','LineWidth',2)
%     hold on;
%     plot(Agrid(plotNode1:plotNodeLast),policyC(plotNode1:plotNodeLast, 1),'r','LineWidth',2)
%     hold on;
%     xlabel('Asset');
%     ylabel('Policy function (consumption function)');
%     legend('Highest income','Lowest income');
%     title('Policy function (consumption function)')
%  
% %%
%  % GRAPH THE VALUE FUNCTION 
%   plotNumber = plotNumber + 1;
%     figure(plotNumber);
%     plot(Agrid(plotNode1:plotNodeLast),val(plotNode1:plotNodeLast, numPtsY),'g','LineWidth',2)
%     hold on;
%     plot(Agrid(plotNode1:plotNodeLast),val(plotNode1:plotNodeLast, 1),'r','LineWidth',2)
%     hold on;
%     xlabel('Asset');
%     ylabel('Value');
%     legend('Val. cond. on highest inc.','Val. cond. on lowest inc.');
%     title('Value function')
