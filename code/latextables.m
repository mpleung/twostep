clear all

cd('[PATH]/snf_code');
addpath('code/outreg_latex'); % http://www.mathworks.com/matlabcentral/fileexchange/38564-outreglatex

%% Set up data

vils = [6 12 29 34 35 46 71 74 76];
%vils = [6 12 34 35 74];
lambdas = [0 0.1 0.2];

numlambdas = length(lambdas)+1; % including dyadic regression
load('results/theta_hat0.mat')
theta = ones(size(theta_hat,1),numlambdas); 
se = ones(size(theta_hat,1),numlambdas); 
pvals = ones(size(theta_hat,1),numlambdas); 

i = 1;
for L=lambdas
    load(['results/theta_hat',num2str(L),'.mat'])
    theta(:,i) = theta_hat; % estimates for each lambda
    
    load(['results/avar',num2str(L),'.mat'])
    se(:,i) = sqrt(diag(av)); % SEs for each lambda
    
    pvals(:,i) = 2*(1-normcdf(abs(theta(:,i))./se(:,i))); % pvals for each lambda
    
    i = i + 1;
end;

load('results/theta_hat_dyadic.mat')
theta(9:(length(theta_hat)+8),4) = theta_hat;
load('results/avar_dyadic.mat')
se(9:(length(theta_hat)+8),4) = sqrt(diag(av));
pvals(:,4) = 2*(1-normcdf(abs(theta(:,4))./se(:,4)));

% total number of nodes
N = 0;
for w=vils
    
    g = csvread(['directed_adjacency_matrices/lendmoney',num2str(w),'.csv']);
    N = N + size(g,1) - 1;
    
end;

%% Homophily parameters and constant

load('dMU/exstat_vil6.mat');
load('dMU/enstat_vil6_lam0.mat');
%indices = [size(stat_en,3)+1 (size(stat_en,3)+size(stat_ex,3)-4):(size(stat_en,3)+size(stat_ex,3))];
indices = [size(stat_en,3)+1 (size(stat_en,3)+16-4):(size(stat_en,3)+16)];

for i=1:numlambdas
    
    names.(['n',num2str(i-1)]) = {'constant'; 'same religion'; 'same sex'; 'same caste'; 'same language'; 'same family'};
    
    results.(['r',num2str(i-1)]) = [theta(indices,i) se(indices,i) pvals(indices,i)];
    more_results.(['m',num2str(i-1)]) = [];
    more_results_names.(['m',num2str(i-1)]) = [];
    
end;

more_results.m0 = N;
more_results_names.m0 = {'N'};

model_names = {'$\lambda=0$'; '$\lambda=0.1$'; '$\lambda=0.2$'; 'dyadic'};

table_opts = 'table';

[table_exo]=outreg_latex(results,names,more_results,more_results_names,model_names,table_opts);

%% Endogenous statistics

load('dMU/enstat_vil6_lam0.mat');
indices = 1:size(stat_en,3);

for i=1:(numlambdas-1)
    
    names2.(['n',num2str(i-1)]) = {'reciprocation'; 'supported trust'; ...
        'in degree'; 'in degree, caste'; 'in degree, relig'; ...
        'out degree'; 'out degree, caste'; 'out degree, relig'};
    
    results2.(['r',num2str(i-1)]) = [theta(indices,i) se(indices,i) pvals(indices,i)];
    more_results2.(['m',num2str(i-1)]) = [];
    more_results_names2.(['m',num2str(i-1)]) = [];
    
end;

more_results2.m0 = N;
more_results_names2.m0 = {'N'};

model_names2 = {'$\lambda=0$'; '$\lambda=0.1$'; '$\lambda=0.2$'};

table_opts2 = 'table';

[table_endo]=outreg_latex(results2,names2,more_results2,more_results_names2,model_names2,table_opts2);

%% All statistics

for i=1:numlambdas
    
    names.(['n',num2str(i-1)]) = {'recip'; ...
        'supp'; 'ideg'; 'idegc'; 'idegr'; ...
        'odeg'; 'odegc'; 'odegr'; 'cons'; 'igender'; 'iHOH'; 'ihindu'; ...
        'icaste2'; 'icaste3'; 'jgender'; ...
        'jHOH'; 'jhindu'; 'jcaste2'; ...
        'jcaste3'; 'srel'; 'ssex'; 'scst'; 'slng'; 'fam'};
    
    results.(['r',num2str(i-1)]) = [theta(:,i) se(:,i) pvals(:,i)];
    more_results.(['m',num2str(i-1)]) = [];
    more_results_names.(['m',num2str(i-1)]) = [];
    
end;

more_results.m0 = N;
more_results_names.m0 = {'N'};

model_names = {'$\lambda=0$'; '$\lambda=0.1$'; '$\lambda=0.2$'; ...
    'dyadic'};

table_opts = 'table';

[table_full]=outreg_latex(results,names,more_results,more_results_names,model_names,table_opts);
