% ------------------------------------------------------------------------- 
% DESCRIPTION
% This script contrasts graphically the policy and value functions obtained 
% numerically and analytically

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global plotNumber                                   % for new graph


%% ------------------------------------------------------------------------ 
% PLOT POLICY FUNCTION: SAVINGS
% numerical and analytical solutions: savings as a function of assets in
% period 'whichyear'

plotNumber = plotNumber + 1;
figure(plotNumber);
    plot( Agrid(whichyear,plotNode1:plotNodeLast), ...
          policyA1(whichyear,plotNode1:plotNodeLast), 'r', 'LineWidth', 2)
    hold on;
    plot( Agrid(whichyear,plotNode1:plotNodeLast), ...
          policyA1_analytic(whichyear,plotNode1:plotNodeLast), 'g', 'LineWidth', 2)
    hold on;
    xlabel('Assets at t');
    ylabel('Policy function: assets at t+1');
    legend('Numerical', 'Analytical');
    title('Comparing numerical and analytical savings functions')   


%% ------------------------------------------------------------------------ 
% PLOT POLICY FUNCTION: CONSUMPTION
% numerical and analytical solutions: consumption as a function of assets
% in period 'whichyear'

plotNumber = plotNumber + 1;
figure(plotNumber);
    plot( Agrid(whichyear,plotNode1:plotNodeLast), ...
          policyC(whichyear,plotNode1:plotNodeLast), 'r', 'LineWidth', 2)
    hold on;
    plot( Agrid(whichyear,plotNode1:plotNodeLast), ...
          policyC_analytic(whichyear,plotNode1:plotNodeLast), 'g', 'LineWidth', 2)
    hold on;
    xlabel('Assets');
    ylabel('Policy function: consumption)');
    legend('Numerical', 'Analytical');
    title('Comparing numerical and analytical consumption functions')   

    
%% ------------------------------------------------------------------------ 
% PLOT RATIO OF NUMERICAL AND ANALYTICAL SOLUTIONS

plotNumber = plotNumber + 1;
figure(plotNumber);
    plot( Agrid(whichyear,plotNode1:plotNodeLast), ...
          ratioOfPolicyA(whichyear,plotNode1:plotNodeLast), 'r', 'LineWidth', 2)
    hold on;
    plot( Agrid(whichyear,plotNode1:plotNodeLast), ...
          ratioOfPolicyC(whichyear,plotNode1:plotNodeLast), 'g', 'LineWidth', 2)
    hold on;
    xlabel('Assets at t');
    ylabel('Ratio');
    legend('Savings', 'Consumption');
    title('Ratio of numerical and analytical solutions: consumption and savings')   


% ------------------------------------------------------------------------ 
% ------------------------------------------------------------------------ 


