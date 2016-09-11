clear all
format short g

cd('[PATH]/snf_code');
addpath('[PATH]/snf_code');

%% variability of first-stage estimates

for lambda=[0 0.1 0.2]
    
    fprintf('lambda=%.2g, mean and stdev\n',lambda);
    estimates = [];
    
    for w=[6 12 29 34 35 46 71 74 76]
        
        load(['dMU/enstat_vil',num2str(w),'_lam',num2str(lambda),'.mat']);
        tmp = reshape(stat_en, size(stat_en,1)^2, size(stat_en,3), 1);
        estimates = cat(1, estimates, tmp);
        
    end;
    
    disp([mean(estimates)' std(estimates)']);
    if(lambda == 0)
        subplot(1,3,1);
    elseif(lambda == 0.1)
        subplot(1,3,2);
    elseif(lambda == 0.2)
        subplot(1,3,3);
    end;
    hist(estimates);
    legend('recip', 'supp', 'id', 'idc', 'idr', 'od', 'odc', 'odr');
    title(['lambda=',num2str(lambda)]);
    
end;

%% summary statistics
load('X.mat');

vils = [6 12 29 34 35 46 71 74 76];

stats = zeros(length(vils),6);

for i=1:length(vils)
    
    g = csvread(['directed_adjacency_matrices/lendmoney',num2str(vils(i)),'.csv']);
    stats(i,1) = size(g,1)-1;
    Xs = zeros(size(g,1)-1,5);
    for k=1:size(g,1)-1
        Xs(k,:) = X(X(:,1)==g(k+1,1),[2:3 5 9:10]);
    end;
    stats(i,2) = mean(Xs(:,1)); % average age
    stats(i,3) = mean(Xs(:,2)); % pct female
    stats(i,4) = mean(Xs(:,3)); % pct hindu
    stats(i,5) = mean(Xs(:,4)); % pct OBC
    stats(i,6) = mean(Xs(:,5)); % pct sched

end;

disp([mean(stats)' std(stats)' min(stats)' max(stats)']);

%% export religion, caste, and sex characteristics for use in R
load('X.mat');

vils = [6 12 29 34 35 46 71 74 76];

for w=vils
    
    g = csvread(['directed_adjacency_matrices/lendmoney',num2str(w),'.csv']);
    N = size(g,1); % N = # agents + 1
    X = zeros(N-1,3);
    for k=1:N-1
        X(k,:) = Xbeliefs(Xbeliefs(:,1)==g(k+1,1),[4 6:7]);
    end;
    dlmwrite(['lendmoney_graphs/Xcrs',num2str(w),'.csv'],X,'precision','%d');

end;
