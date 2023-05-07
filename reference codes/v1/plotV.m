% ------------------------------------------------------------------------ 
% DESCRIPTION
% This script plots the numerical approximation of the value function in a
% for period 'whichyear' and between grid points plotNode1 and 
% plotNodeLast

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global plotNumber 

%% ------------------------------------------------------------------------ 
% Draw and format graph

plotNumber = plotNumber + 1;
figure(plotNumber);
plot( Agrid(whichyear,plotNode1:plotNodeLast), ...
      val(whichyear,plotNode1:plotNodeLast), 'r', 'LineWidth',2)
hold on;
xlabel('Assets');
ylabel('Value');
legend('Value function');
title('Value function')