function [V,Psi] = avar_1net(g, stat_en, stat_ex, theta_hat, Xest, yes_en)
% Outputs an estimate of the asymptotic variance for a single network under 
% a linear utility specification.
%
% g is the network, stat_en is the vector of endogenous statistics (the 
% output of en_stat.m), stat_ex is the vector of exogenous statistics (the
% output of ex_stat.m), theta_hat is the structural parameter, Xest is from
% X.mat, and yes_en is an indicator for whether or not the specification
% includes engoenous statistics.
%
% This function uses multiprod.m.

G = g(2:size(g,1),2:size(g,1));
N = size(G,1); % number of agents
p = length(theta_hat);

tempX = dataset({Xest,'pid','drop','age','gender','HOH','hindu','caste2', ...
    'caste3','educ_primary','educ_secondary','educ_puc','educ_ideg', ...
    'educ_deg','educ_oth','hindi','kannada','malayalam','marati', ...
    'tamil','telugu','urdu','english'});
tempID = dataset({g(2:(N+1))','pid'});
Xg = double(join(tempID, tempX, 'Type', 'leftouter'));
Xg = Xg(:,[4:8 15:size(Xg,2)]);% omit pid, drop, age, educ

ES_ij = cat(3, stat_en, stat_ex); % [N x N x p] ijth entry = \hat E[S_{ij} | X, sigma]
signG = (-1).^(1-G); % [N x N]
V_ij = multiprod(ES_ij, theta_hat, [2 3], [1 2]); 
    % [N x N] ijth entry = \hat E[S_{ij} | X, \sigma]' \theta
Phi = normcdf(signG .* V_ij); % the log of these form the summands of the quasi-likelihood, equation (7)
phi = normpdf(V_ij);
phi(1:(size(phi,1)+1):end) = 0; % zero out diagonal elements

%% V_n (second derivative of the log-likelihood)
ESESt = multiprod(ES_ij, permute(ES_ij, [1 2 4 3]), [3 4]); 
    % [N x N x p x p] equals E[S | X, \sigma] * E[S | X, \sigma]'
V_summands = multiprod(ESESt, phi.^2 ./ (Phi.*(1-Phi)), [3 4], 3);
V = squeeze(sum(sum(V_summands,1),2)); % [p x p]
clear ESESt V_summands

%% Psi_n
if(yes_en == 1)
    
    % M
    ES_theta_t = multiprod(ES_ij, repmat(permute(theta_hat(1:8), [4 2 3 1]), [N N]), [3 4]); % [N x N x p x 8] equals theta_hat * E[en_ij | X, \sigma]'
    M = multiprod(ES_theta_t, phi.^2 ./ (Phi.*(1-Phi)), [3 4], 3); % [N x N x p x 8]
    clear ES_theta_t

    % Psi_n 
    q = 1:N; r = q(ones(1,N),:); % G(q,r) more efficient than kron(G,ones(1,N))

    Psi_1 = sum(multiprod(ES_ij, phi./Phi.*signG, 3), 2); 
        % [N x 1 x p] first element of Z_{n,i}, first derivative of log likelihood
    Psi_2 = sum(permute(M(:,:,:,1), [2 1 3 4]) .* repmat(G, [1 1 p]), 2); 
        % second element of Z_{n,i}, corresponds to recip
    Psi_3 = 1/N * sum(repmat(reshape(M(:,:,:,2),1,N^2,p), [N 1 1]) .* ...
        repmat(G, [1 N p]) .* repmat(G(q,r), [1 1 p]), 2); % corresponds to supp_trust

    hphil_relig = repmat(Xg(:,4),[1 N]) == repmat(Xg(:,4)',[N 1]); % [N x N] i hindu == j hindu
    hphil_caste = prod(double(repmat(permute(Xg(:,5:6),[1 3 2]),[1 N 1]) == ...
        repmat(permute(Xg(:,5:6),[3 1 2]),[N 1 1])), 3); % [N x N] i caste == j caste

    Psi_4 = 1/N * sum(repmat(G, [1 N p]) .* multiprod(repmat(reshape(permute(M(:,:,:,3:5), ...
        [2 1 3 4]),1,N^2,p,3), [N 1 1 1]), cat(3, ones(N,N^2), ...
        hphil_caste(q,r), hphil_relig(q,r)), [3 4], [3 4]), 2); % corresponds to in_deg's
    Psi_5 = 1/N * sum(repmat(G(q,r), [1 1 p]) .* multiprod(repmat(permute(M(:,:,:,6:8), ...
        [2 1 3 4]), [1 N 1 1]), cat(3, ones(N,N^2), repmat(hphil_caste(:)', [N 1]), ...
        repmat(hphil_relig(:)', [N 1])), [3 4], [3 4]), 2); % corresponds to out_deg's
 
    Z_n = squeeze(Psi_1 + Psi_2 + Psi_3 + Psi_4 + Psi_5); % [N x p]
    clear Psi_1 Psi_2 Psi_3 Psi_4 Psi_5
    Psi = Z_n' * Z_n + sum(Z_n,1)' * sum(Z_n,1); % [p x p]
else
    Psi = zeros(p,p);
end;
