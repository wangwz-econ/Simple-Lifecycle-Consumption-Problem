function [ policyA1, policyC] = getPolicy_analytical

% ------------------------------------------------------------------------- 
% DESCRIPTION
% This function gets analytical policy functions in a world where
% a) there is no uncertainty;
% b) borrowing is allowed up to the natural borrowing constraint

%% ------------------------------------------------------------------------ 
% Declare global we need this file have access to
global T beta r gamma 
global numPtsA Agrid Ygrid 


%% ------------------------------------------------------------------------ 
% Initialise output arrays
policyC  = NaN(T, numPtsA);
policyA1 = NaN(T, numPtsA);


%% ------------------------------------------------------------------------ 
% The folowing is best read with the notes

alpha = (beta^(1/gamma))*((1+r)^((1-gamma)/gamma));

for ixt = 1:1:T
    
    periodsLeft = T - ixt + 1;
    indexVec = (0:(periodsLeft-1))';                            % vector [ 0 1       2           ... (periodsLeft-1) ]'
    RtoThePowerOft = ((1+r) .* ones(periodsLeft,1)).^indexVec;  % vector [ 1 (1+r)  (1+r)^2      ... (1 + r)^(periodsLeft-1) ]'
    invRtoThePowerOft = 1./RtoThePowerOft;                      % vector [ 1 1/(1+r) 1/((1+r)^2) ... 1/((1 + r)^(periodsLeft-1)) ]'

    inc = Ygrid(ixt:T, 1);                                      % income from today until death
    discountedInc = inc' * invRtoThePowerOft;                   % present value at time ixt of present and future income 
    
    for ixA = 1:1:numPtsA
        W =  Agrid(ixt, ixA) + discountedInc;                   % total wealth at time ixt
        
        if (abs(alpha - 1) < 1e-5) 
            policyC(ixt,ixA) =  W / periodsLeft;
        else           
            policyC(ixt,ixA) = ((1-alpha) / (1- (alpha^periodsLeft))) * W;
        end
                   
        policyA1(ixt,ixA) = (1 + r) * (Agrid(ixt,ixA) + Ygrid(ixt) - policyC(ixt,ixA));
    end    
end


end

