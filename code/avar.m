function avar(lambda, vils, yes_en)
% Outputs an estimate of the asymptotic variance when the sample of networks
% is vils, under a linear utility specification.
%
% theta_hat is the parameter estimate, lambda is the smoothing parameter
% used in en_stat, vils is the vector of village labels, and yes_en is an
% indicator for whether or not the specification includes engoenous statistics.

load('X.mat');
load(['dMU/exstat_vil',num2str(vils(1)),'.mat']);
if(yes_en == 1)
    load(['results/theta_hat',num2str(lambda),'.mat']);
    load(['dMU/enstat_vil',num2str(vils(1)),'_lam',num2str(lambda),'.mat']);
    p = size(stat_en,3) + size(stat_ex,3); % number of parameters 
else
    disp('Running dyadic regression.');
    load('results/theta_hat_dyadic.mat');
    p = size(stat_ex,3); % somehow the size of the 3rd dimension of an empty matrix is 1
end;

V = zeros(p,p);
Psi = zeros(p,p);

for w=vils
    
    fprintf('        village %d\n',w);
    g = csvread(['directed_adjacency_matrices/lendmoney',num2str(w),'.csv']);
    load(['dMU/exstat_vil',num2str(w),'.mat']);
    if(yes_en ~= 1)
        stat_en = [];
        [V_new, Psi_new] = avar_1net(g, stat_en, stat_ex, theta_hat, Xest, 0);
    else
        load(['dMU/enstat_vil',num2str(w),'_lam',num2str(lambda),'.mat']);
        [V_new, Psi_new] = avar_1net(g, stat_en, stat_ex, theta_hat, Xest, 1);
    end;
    V = V + V_new;
    Psi = Psi + Psi_new;
    
end;

if(yes_en == 1)
    av = V\Psi/V;
    save(['results/avar',num2str(lambda),'.mat'], 'av');
else
    av = inv(V);
    save('results/avar_dyadic.mat', 'av');
end;
