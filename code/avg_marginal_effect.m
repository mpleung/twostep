function f = avg_marginal_effect(lambda, vils)
% Computes average marginal effects for the endogenous statistics and 
% homphily in family. 
% (This is distinguished from marginal effects at the average.)
%
% Nine marginal effects are computed for a given smoothing parameter 
% lambda. We average over all pairs of nodes in a village and all villages 
% in vils.

load(['dMU/enstat_vil',num2str(vils(1)),'_lam',num2str(lambda),'.mat']);
effects = zeros(size(stat_en,3) + 1,1);
N_tot = 0; % total number of node pairs that are able to form a link

load(['results/theta_hat',num2str(lambda),'.mat']);

for w=vils
    
    load(['dMU/exstat_vil',num2str(w),'.mat']);
    load(['dMU/enstat_vil',num2str(w),'_lam',num2str(lambda),'.mat']);
    N = size(stat_ex, 1);
    N_tot = N_tot + N*(N-1);
    
    effects(1) = effects(1) + sum(sum(normcdf(multiprod(cat(3, ones(N,N), ...
        stat_en(:,:,2:size(stat_en,3)), stat_ex), theta_hat, [2 3], ...
        [1 2])) - normcdf(multiprod(cat(3, zeros(N,N), stat_en(:,:, ...
        2:size(stat_en,3)), stat_ex), theta_hat, [2 3], [1 2])), 1), 2); % reciprocation
    
    effects(2:8) = effects(2:8) + sum(sum(normpdf(multiprod(cat(3, ones(N,N), ...
        stat_en(:,:,2:size(stat_en,3)), stat_ex), theta_hat, [2 3], ...
        [1 2])), 1), 2) * theta_hat(2:8) / 100; % effect of 1 pp increase
    
    effects(9) = effects(9) + sum(sum(normcdf(multiprod(cat(3, ...
        stat_en, stat_ex(:,:,1:size(stat_ex,3)-1), ones(N,N)), theta_hat, [2 3], ...
        [1 2])) - normcdf(multiprod(cat(3, stat_en, ...
        stat_ex(:,:,1:size(stat_ex,3)-1), zeros(N,N)), theta_hat, [2 3], ...
        [1 2])), 1), 2);
    
end;

f = effects / N_tot;
