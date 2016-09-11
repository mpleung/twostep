clear all

cd('[PATH]/snf_code');
addpath('[PATH]/snf_code');
addpath('[PATH]/snf_code/code');
 
% Deriatives of the objective are computed using the multiprod function to 
% multiply 2d submatrices of 4d matrices. The function is obtainable at 
% http://www.mathworks.com/matlabcentral/fileexchange/8773
 
addpath('[PATH]/snf_code/code/Multiprod_2009');

% villages with at least 10% non-hindus
vils = [6 12 29 34 35 46 71 74 76];

%% Create adjacency matrices

gendirected(vils) % generate adjacency matrices
format_covariates(); % generate matrix of individual characteristics
drop_notype_all(vils); % drop individuals with no characteristics (weren't surveyed) or missing crucial characteristics

%% Estimate Model

lambdas = [0 0.1 0.2];

disp('Storing statistics.');
dMU([6 12 34 35 74], lambdas, 0); % villages with < 220 people
dMU([29 46 71 76], lambdas, 0); % if insufficient memory, change '0' to '1' to use en_stat_slow instead

disp('Estimating parameters.');
for L=lambdas
    fprintf('    lambda=%.2g\n',L);
    twostepest(@Q_grad, L, vils, 1);
end;

%% Asymptotic variance

disp('Computing asymptotic variances.');
for L=lambdas
    fprintf('    lambda=%.2g\n',L);
    avar(L, vils, 1);
end;

%% Dyadic Regression

disp('Dyadic regression.');
twostepest(@Q_grad, 0, vils, 0);
avar(0, vils, 0);

%% Compute Average Marginal Effects

disp('Computing marginal effects.');
effects = zeros(9, length(lambdas));
count = 1;
for L=lambdas
    fprintf('    lambda=%.2g\n',L);
    effects(:,count) = avg_marginal_effect(L, vils);
    count = count + 1;
end;
save('results/marginal_effects.mat', 'effects');
