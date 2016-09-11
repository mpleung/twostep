function f = en_stat_slow(g, Xest, Z, lambda)
% Same as function en_stat, except certain memory-intensive vectorized
% calculations are replaced with slow for-loops.

N = size(g,1) - 1;
fprintf('    en_stat_slow, N=%d\n',N);

tempX = dataset({Xest,'pid','drop','age','gender','HOH','hindu','caste2','caste3','educ_primary','educ_secondary','educ_puc','educ_ideg','educ_deg','educ_oth','hindi','kannada','malayalam','marati','tamil','telugu','urdu','english'});
tempID = dataset({g(2:(N+1))','pid'});
Xg = double(join(tempID, tempX, 'Type', 'leftouter'));
%Xg = Xg(:,3:size(Xg,2));% omit pid, drop
Xg = Xg(:,[4:8 15:size(Xg,2)]);% omit pid, drop, age, educ
Z = Z(2:size(Z,1),2:size(Z,2)); % strip pids

%% Create vectors of endogenous statistics

disp('        Create endogenous stats.');
G = g(2:(N+1),2:(N+1)); % strip away pids
hphil_relig = repmat(Xg(:,4),[1 N]) == repmat(Xg(:,4)',[N 1]); % [N x N] i hindu == j hindu
hphil_caste = prod(double(repmat(permute(Xg(:,5:6),[1 3 2]),[1 N 1]) == repmat(permute(Xg(:,5:6),[3 1 2]),[N 1 1])), 3); % [N x N] i caste == j caste
supp_trust = 1/N * sum(repmat(permute(G,[2 3 1]), [1 N 1]) .* repmat(permute(G,[3 2 1]), [N 1 1]), 3);

in_deg = 1/N * sum(repmat(permute(G,[2 3 1]), [1 N 1]) .* repmat(permute(1-eye(N),[3 2 1]), [N 1 1]), 3); % i's j-excluded in-degree
in_deg_c = 1/N * sum(repmat(permute(G,[2 3 1]), [1 N 1]) .* repmat(permute(1-eye(N),[3 2 1]), [N 1 1]) .* repmat(hphil_caste,[1 1 N]), 3); % people who share j's religion who link to i, excluding j
in_deg_r = 1/N * sum(repmat(permute(G,[2 3 1]), [1 N 1]) .* repmat(permute(1-eye(N),[3 2 1]), [N 1 1]) .* repmat(hphil_relig,[1 1 N]), 3);
out_deg = 1/N * sum(repmat(permute(G,[1 3 2]), [1 N 1]) .* repmat(permute(1-eye(N),[3 2 1]), [N 1 1]), 3); % i's j-excluded out-degree
out_deg_c = 1/N * sum(repmat(permute(G,[1 3 2]), [1 N 1]) .* repmat(permute(1-eye(N),[3 2 1]), [N 1 1]) .* repmat(hphil_caste,[1 1 N]), 3); % people who share j's religion to whom i links, excluding j
out_deg_r = 1/N * sum(repmat(permute(G,[1 3 2]), [1 N 1]) .* repmat(permute(1-eye(N),[3 2 1]), [N 1 1]) .* repmat(hphil_relig,[1 1 N]), 3);


%% Create first-step estimators

categ = cat(3, repmat(permute(Xg(:,2:size(Xg,2)),[1 3 2]),[1 N 1]), repmat(permute(Xg(:,2:size(Xg,2)),[3 1 2]),[N 1 1])); % [N x N x (d-1)*2] where d is the dimension of X_1. ijth element is the categorical components of vector (X_i,X_j)
ordrd = cat(3, repmat(permute(Xg(:,1),[1 3 2]),[1 N 1]), repmat(permute(Xg(:,1),[3 1 2]),[N 1 1])); % [N x N x 2] ijth element is (age_i, age_j), the only ordered components of (X_i,X_j)
clear tempX tempID Xg 

f = zeros(N,N,8);

for i=1:N
    for j=1:N
        if(i==j)
            continue;
        end;
        
        weight = lambda .^ (sum(categ ~= repmat(categ(i,j,:),[N N 1]),3) + sum(abs(ordrd - repmat(ordrd(i,j,:),[N N 1])),3) + sum(Z ~= repmat(Z(i,j,:),[N N 1]),3)); % [N x N] ijth entry = number of differences between categorical components of (X_k,X_l) and (X_i,X_j) + |age_i - age_k| + |age_j - age_l| + 1{Z_ij ~= Z_kl}
        f(j,i,1) = sum(sum(G .* weight,1),2) ./ sum(sum(weight,1),2); % = \hat\E[G_{ji} | X, \sigma]
        f(j,i,2) = sum(sum(supp_trust .* weight,1),2) ./ sum(sum(weight,1),2);
        f(j,i,3) = sum(sum(in_deg .* weight,1),2) ./ sum(sum(weight,1),2);
        f(j,i,4) = sum(sum(in_deg_c .* weight,1),2) ./ sum(sum(weight,1),2);
        f(j,i,5) = sum(sum(in_deg_r .* weight,1),2) ./ sum(sum(weight,1),2);
        f(j,i,6) = sum(sum(out_deg .* weight,1),2) ./ sum(sum(weight,1),2);
        f(j,i,7) = sum(sum(out_deg_c .* weight,1),2) ./ sum(sum(weight,1),2);
        f(j,i,8) = sum(sum(out_deg_r .* weight,1),2) ./ sum(sum(weight,1),2);
    end;
end;
