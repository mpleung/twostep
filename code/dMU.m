function dMU(vils,lambdas,slow)
% Outputs and saves an [N x N x p] matrix for each village, where the ijth
% element is the vector \hat E[S_{ij} | X, \sigma]. Thus, this is the
% matrix of of derivatives of the marginal utilities V_{ij}, where the
% derivative is taken with respect to the structural parameter \theta.
%
% 'slow' is an indicator for whether or not to use en_stat_slow in place of
% en_stat

load('X.mat');

for w=vils
        
    if w==13||w==22
        continue;
    end;
    fprintf('dMU, village=%d\n',w);
    
    g = csvread(['directed_adjacency_matrices/lendmoney',num2str(w),'.csv']);
    Z = csvread(['directed_adjacency_matrices/rel',num2str(w),'.csv']);
    fprintf('    ex_stat, N=%d', size(g,1)-1);
    stat_ex = ex_stat(X, Z, g(2:size(g,1))');
    save(['dMU/exstat_vil',num2str(w),'.mat'], 'stat_ex');
    
    for L=lambdas
        tstart=tic;
        fprintf('    lambda=%.2g\n',L);
        if(slow ~= 1)
            stat_en = en_stat(g, Xest, sparse(Z), L);
        else
            stat_en = en_stat_slow(g, Xest, Z, L);
        end;
        telapsed = toc(tstart);
        fprintf('    Time elapsed: %.3g.\n', telapsed);
        save(['dMU/enstat_vil',num2str(w),'_lam',num2str(L),'.mat'], 'stat_en');
    end;

end;
