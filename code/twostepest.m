function twostepest(Q_grad, lambda, vils, yes_en)
% Outputs and saves estimates of structural parameter theta under a linear  
% utility specification.
%
% lambda is the smoothing parameter.
% Q_grad is a function that outputs first and second derivatives of the
% quasi-likelihood.
% If yes_en = 1, then we include endogenous statistics. Otherwise, we run a
% dyadic regression.
% Vils is a vector of village labels.
%
% The order of parameters is the eight endogenous statistics first,
% followed by the exogenous statistics. See en_stat.m and ex_stat.m for the
% order of their respective components.

load(['dMU/exstat_vil',num2str(vils(1)),'.mat']);
if(yes_en == 1)
    load(['dMU/enstat_vil',num2str(vils(1)),'_lam',num2str(lambda),'.mat']);
    p = size(stat_en,3) + size(stat_ex,3); % number of parameters 
else
    disp('Running dyadic regression.');
    p = size(stat_ex,3); % somehow the size of the 3rd dimension of an empty matrix is 1
end;


%% Newton-Raphson

e_tol = 1e-6;
error = 1;
maxiters = 1000;
count = 0;
theta0 = zeros(p,1);
theta_hat = theta0;

tstart=tic;

while(error > e_tol && count < maxiters)
    
    dQ = zeros(p,1); % first derivative of quasi-likelihood
    d2Q = zeros(p,p); % second deriative
    
    % assemble derivatives, sum over villages
    for w=vils
        
        if w==13||w==22
            continue;
        end;
        
        g = csvread(['directed_adjacency_matrices/lendmoney',num2str(w),'.csv']);
        load(['dMU/exstat_vil',num2str(w),'.mat']);
        if(yes_en ~= 1)
            stat_en = [];
        else
            load(['dMU/enstat_vil',num2str(w),'_lam',num2str(lambda),'.mat']);
        end;
        
        [A,B] = Q_grad(g, stat_en, stat_ex, theta_hat);
        dQ = dQ + A;
        d2Q = d2Q + B;
        
    end;
    
    % NR updating
    theta_new = theta_hat - d2Q\dQ;
    error = max(abs(theta_new - theta_hat));
    theta_hat = theta_new;
    
    count = count + 1;
	fprintf('    Iteration %d, error = %.3g.\n', count, error);
    
end;

telapsed = toc(tstart);
fprintf('Time elapsed: %.3g.\n', telapsed);

if(yes_en == 1)
    save(['results/theta_hat',num2str(lambda),'.mat'], 'theta_hat');
else
    save('results/theta_hat_dyadic.mat', 'theta_hat');
end;
