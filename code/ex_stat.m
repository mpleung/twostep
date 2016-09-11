function f = ex_stat(X, Z, IDs)
% Outputs [N x N x 18] matrix. For each pair of agents (i,j), we get a
% 18-dimensional vector of exogenous statistics, which include
%   attributes of i (age, gender, HOH, religion, caste, educ)
%   attributes of j
%   homophily in religion, gender, caste, and language
%   pair-specific attributes Z_{ij}.
% These are in order of concatenation.
%
% X is the matrix created in format_covariates.
% Z is the matrix of family relationships, which is assumed to include row 
% and column labels.
% IDs is a vector (NOT HORIZONTAL ARRAY) of person IDs in the network, 
% obtained from, say, the first column of one of the adjacency matrices.

N = size(IDs,1);

% create attribute matrix for only agents in network g, including person ID 
% in first column
tempX = dataset({X,'pid','age','gender','HOH','hindu','islam','christian','caste1','caste2','caste3','hindi','kannada','malayalam','marati','tamil','telugu','urdu','english','educ_primary','educ_secondary','educ_puc','educ_ideg','educ_deg','educ_oth'});
tempID = dataset({IDs,'pid'});
Xg = double(join(tempID, tempX, 'Type', 'leftouter'));
Xg = Xg(:,2:size(Xg,2));

% individual characteristics: age, gender, HOH, religion, caste.
%Xg_indiv = [Xg(:,2:5) Xg(:,9:10)]; % omit islam, christian (group those two in intercept - there are too few christians in data), and caste1
Xg_indiv = [Xg(:,3:5) Xg(:,9:10)]; % omit age, islam, christian (group those two in intercept - there are too few christians in data), and caste1

% include education too
%Xg_indiv = [Xg(:,2:5) Xg(:,9:10) Xg(:,19:size(Xg,2))]; 

cons = ones(N, N); % constant term

ichar = repmat(permute(Xg_indiv,[1 3 2]),[1 N 1]); % attributes of i
jchar = repmat(permute(Xg_indiv,[3 1 2]),[N 1 1]); % attributes of j

srel = prod(double(repmat(permute(Xg(:,5:7),[1 3 2]),[1 N 1]) == repmat(permute(Xg(:,5:7),[3 1 2]),[N 1 1])),3); % indicator for having the same religion
ssex = double(repmat(permute(Xg(:,3),[1 3 2]),[1 N 1]) == repmat(permute(Xg(:,3),[3 1 2]),[N 1 1])); % same gender
scst = prod(double(repmat(permute(Xg(:,8:10),[1 3 2]),[1 N 1]) == repmat(permute(Xg(:,8:10),[3 1 2]),[N 1 1])),3); % same caste
slng = sum((repmat(permute(Xg(:,11:18),[1 3 2]),[1 N 1]) + repmat(permute(Xg(:,11:18),[3 1 2]),[N 1 1]) == 2) > 0, 3); % share common language

fam = Z(2:size(Z,1),2:size(Z,1)); % i and j related

f = cat(3, cons, ichar, jchar, srel, ssex, scst, slng, fam);
% cons1 iage2 igender3 iHOH4 ihindu5 icaste2_6 icaste3_7 iprimary_8
% isecondary_9 ipuc_10 iideg_11 ideg_12 ioth_13
% jage14 jgender15 jHOH16 jhindu17 jcaste2_18 jcaste3_19 jprimary_20
% jsecondary_21 jpuc_22 jideg_23 jdeg_24 joth_25
% srel_26 ssex_27 scst_28 slng_29 
% fam_30
