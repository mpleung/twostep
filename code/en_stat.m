function f = en_stat(g, Xest, Z, lambda)
% Outputs a [N x N x 8] matrix. For each pair of agents (i,j), we get an
% 8-dimensional vector of smoothed frequency estimators for the conditional 
% expectation of the endogenous statistics, which include
%   G_{ji} (reciprocation)
%   supported trust
%   j's in-degree (weighted by homophily in caste, in religion, and unweighted)
%   j's out-degree (weighted by homophily in caste, in religion, and
%   unweighted).
% These are in order of concatenation.
%
% Xest is the matrix created in format_covariates.
% Z is the family adjacency matrix, including person ids (pids).
% g is the directed adjacency matrix.
% lambda is the smoothing parameter.
%
% Works for villages under 220 people with around 10gb memory.

N = size(g,1) - 1;
fprintf('    en_stat, N=%d\n',N);

tempX = dataset({Xest,'pid','drop','age','gender','HOH','hindu','caste2','caste3','educ_primary','educ_secondary','educ_puc','educ_ideg','educ_deg','educ_oth','hindi','kannada','malayalam','marati','tamil','telugu','urdu','english'});
tempID = dataset({g(2:(N+1))','pid'});
Xg = double(join(tempID, tempX, 'Type', 'leftouter'));
%Xg = Xg(:,3:size(Xg,2));% omit pid, drop
Xg = Xg(:,[4:8 15:size(Xg,2)]);% omit pid, drop, age, educ
Z = Z(2:size(Z,1),2:size(Z,2)); % strip pids

%% Create weights

icat = repmat(permute(Xg(:,2:size(Xg,2)),[1 3 2]),[1 N 1]); % categorical attributes of i
jcat = repmat(permute(Xg(:,2:size(Xg,2)),[3 1 2]),[N 1 1]); % categorical attributes of j
cat_diff = sum(icat~=jcat,3); % [N x N] number of disagreeing categorical components between X_i, X_j
iord = repmat(permute(Xg(:,1),[1 3 2]),[1 N 1]); % ordered attributes of i
jord = repmat(permute(Xg(:,1),[3 1 2]),[N 1 1]); % ordered attributes of j
ord_diff = sum(abs(iord-jord),3); % [N x N] sum of absolute differences between ordered components of X_i, X_j

fprintf('        Create diffs_X. ');
tstart=tic;
q = 1:N; q = q(ones(1,N),:);
tmp = cat_diff + ord_diff;
clear tempX tempID icat jcat cat_diff iord jord ord_diff
diffs_X = repmat(tmp, [N N]) + tmp(q,q); % [N^2 x N^2] first memory bottleneck.
    % (ij,kl)th entry:
    % First component of the sum is number of disagreeing components between the 
    % categorical components of X_i and X_k, plus the absolute difference
    % between the ordered components.
    % Second component is the same thing for X_j and X_l.
clear tmp q
telapsed = toc(tstart);
fprintf('Time elapsed: %.3g.\n', telapsed);

fprintf('        Create diffs. ');
tstart=tic;
tmp = repmat(Z(:),[1 size(Z,1)^2]);
diffs_fam = tmp ~= tmp'; % [N^2 x N^2] matrix of indicators for whether or not Z_{ij}, Z_{kl} disagree
diffs = diffs_X + diffs_fam;
clear diffs_X diffs_fam tmp
telapsed = toc(tstart);
fprintf('Time elapsed: %.3g.\n', telapsed);

fprintf('        Create weight. ');
tstart=tic;
weight = lambda .^ diffs;
clear diffs
telapsed = toc(tstart);
fprintf('Time elapsed: %.3g.\n', telapsed);

%{
disp('        create diffs_Xs');
tstart=tic;
diffs_X = sparse(triu(cat_diff + ord_diff)); % [N x N] upper triangular 
diffs_X_ik = sparse(triu(repmat(cat_diff + ord_diff, [N N])));
diffs_X_jl = kron(diffs_X,ones(N,N));
clear tempX tempID Xg icat jcat cat_diff iord jord ord_diff diffs_X nonsparse diffs_X
diffs_X_2 = diffs_X_ik + diffs_X_jl;
clear diffs_X_ik diffs_X_jl
telapsed = toc(tstart);
fprintf('        Time elapsed: %.3g.\n', telapsed);


disp('        exponentiate diffs_X_2');
tstart=tic;
nonzero = logical(diffs_X_2);
weight_X = sparse(zeros(size(diffs_X_2)));
weight_X(nonzero) = lambda .^ diffs_X_2(nonzero); % [N^2 x N^2] exponentiates the upper triangular part of diffs_X by lambda. the rest is zeros
clear diffs_X_2 nonzero
telapsed = toc(tstart);
fprintf('        Time elapsed: %.3g.\n', telapsed);

disp('        weight transpose');
tstart=tic;
weight = weight_X + weight_X';
telapsed = toc(tstart);
fprintf('        Time elapsed: %.3g.\n', telapsed);
%}

%% Create vectors of endogenous statistics

disp('        Create endogenous stats.');
G = g(2:(N+1),2:(N+1)); % strip away pids
hphil_relig = repmat(Xg(:,4),[1 N]) == repmat(Xg(:,4)',[N 1]); % [N x N] i hindu == j hindu
hphil_caste = prod(double(repmat(permute(Xg(:,5:6),[1 3 2]),[1 N 1]) == repmat(permute(Xg(:,5:6),[3 1 2]),[N 1 1])), 3); % [N x N] i caste == j caste
supp_trust = 1/N * sum(repmat(permute(G,[2 3 1]), [1 N 1]) .* repmat(permute(G,[3 2 1]), [N 1 1]), 3); % supported trust for (i,j)

in_deg = 1/N * sum(repmat(permute(G,[2 3 1]), [1 N 1]) .* repmat(permute(1-eye(N),[3 2 1]), [N 1 1]), 3); % i's j-excluded in-degree
in_deg_c = 1/N * sum(repmat(permute(G,[2 3 1]), [1 N 1]) .* repmat(permute(1-eye(N),[3 2 1]), [N 1 1]) .* repmat(hphil_caste,[1 1 N]), 3); % people who share j's religion who link to i, excluding j
in_deg_r = 1/N * sum(repmat(permute(G,[2 3 1]), [1 N 1]) .* repmat(permute(1-eye(N),[3 2 1]), [N 1 1]) .* repmat(hphil_relig,[1 1 N]), 3);
out_deg = 1/N * sum(repmat(permute(G,[1 3 2]), [1 N 1]) .* repmat(permute(1-eye(N),[3 2 1]), [N 1 1]), 3); % i's j-excluded out-degree
out_deg_c = 1/N * sum(repmat(permute(G,[1 3 2]), [1 N 1]) .* repmat(permute(1-eye(N),[3 2 1]), [N 1 1]) .* repmat(hphil_caste,[1 1 N]), 3); % people who share j's religion to whom i links, excluding j
out_deg_r = 1/N * sum(repmat(permute(G,[1 3 2]), [1 N 1]) .* repmat(permute(1-eye(N),[3 2 1]), [N 1 1]) .* repmat(hphil_relig,[1 1 N]), 3);

%% Create first-step estimators

disp('        Create denom.');
denom = ones(1,N^2) * weight; % denominator of the smoothed frequency estimator
disp('        Create estimators.');
recip_est = reshape(G(:)' * weight ./ denom, N, N); % [N x N] ijth entry = \hat\E[G_{ij} | X, \sigma]
supp_trust_est = reshape(supp_trust(:)' * weight ./ denom, N, N); % ijth entry = \hat\E[t_{ij} | X, \sigma]
in_deg_est = reshape(in_deg(:)' * weight ./ denom, N, N); % ijth entry = \hat\E[d_{ij} | X, \sigma]
in_deg_c_est = reshape(in_deg_c(:)' * weight ./ denom, N, N);
in_deg_r_est = reshape(in_deg_r(:)' * weight ./ denom, N, N);
out_deg_est = reshape(out_deg(:)' * weight ./ denom, N, N);
out_deg_c_est = reshape(out_deg_c(:)' * weight ./ denom, N, N);
out_deg_r_est = reshape(out_deg_r(:)' * weight ./ denom, N, N);

f = cat(3, recip_est', supp_trust_est, in_deg_est', in_deg_c_est', in_deg_r_est', out_deg_est', out_deg_c_est', out_deg_r_est');
