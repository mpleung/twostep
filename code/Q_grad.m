function [dQ,d2Q] = Q_grad(g, stat_en, stat_ex, theta_hat)
% Outputs the first and second derivatives of the empirical log-likelihood 
% under a linear utility specification.
%
% g is the network, stat_en is the vector of endogenous statistics (the 
% output of en_stat.m), stat_ex is the vector of exogenous statistics (the
% output of ex_stat.m), theta_hat is the structural parameter.
%
% If there are no endogenous statistics, pass the empty matrix [].
%
% This function uses the multiprod function.

N = size(g,1)-1; % number of agents

ES_ij = cat(3, stat_en, stat_ex); % [N x N x p] ijth entry = \hat E[S_{ij} | X, sigma]
signG = (-1).^(1-g(2:size(g,1),2:size(g,1))); % [N x N]
V_ij = multiprod(ES_ij, theta_hat, [2 3], [1 2]); % [N x N] ijth entry = \hat E[S_{ij} | X, \sigma]' \theta
Phi = normcdf(signG .* V_ij); % the log of these form the summands of the quasi-likelihood, equation (7)
phi = normpdf(V_ij);
phi(1:(size(phi,1)+1):end) = 0; % zero out diagonal elements

% First derivative of the log-likelihood.
dQ_summands = multiprod(ES_ij, phi./Phi.*signG, 3); % [N x N x p]
dQ = squeeze(sum(sum(dQ_summands,1),2))/N/(N-1); % [p x 1]

% Second derivative of the log-likelihood.
ESESt = multiprod(ES_ij, permute(ES_ij, [1 2 4 3]), [3 4]); % [N x N x p x p] equals E[S | X, \sigma] * E[S | X, \sigma]'
d2Q_summands = multiprod(ESESt, (Phi.*phi.*(-signG.*V_ij) - phi.^2)./Phi.^2, [3 4], 3); % [N x N x p x p]
d2Q = squeeze(sum(sum(d2Q_summands,1),2))/N/(N-1); % [p x p]
