function f = drop_notype(g, X)
% Drops rows and columns from g corresponding to individuals with no entry
% in X (i.e. no data on characteristics). These are the individuals who
% weren't surveyed.

N = size(g,1);
exists = ones(N,1); % will set entry to 0 if the corresponding row/column of g should be dropped

for i=2:N
    
    if(sum(X(:,1)==g(i,1))==0) % if the hhid g(i,1) doesn't appear anywhere in the hhid column of X, then drop
        exists(i,1) = 0;
    end;
    
    % Those with no caste or religion data will be dropped.
    nocaste = X(X(:,1)==g(i,1),2); % second column of X (the 'drop' variable) tells us which to drop
    if(nocaste>0)
        exists(i,1) = 0;
    end;
    
end;

exists = logical(exists);
f = g(exists,exists);