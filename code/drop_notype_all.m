function drop_notype_all(vils)

% Drop links associated with nodes lacking attributes.
% Runs drop_notype.m for all villages. Saves result of each village in new
% csv in directed_adjacency_matrices.

load('X.mat');
cd('directed_adjacency_matrices');
addpath('../code');

for w=vils
    
    relationships = ...
    {
        strcat('lendmoney',num2str(w));
        strcat('rel',num2str(w));
    };
    numRelationships = size(relationships,1);
    
    if w==13||w==22 % data for these villages don't exist
        continue;
    end;

	for relationshipID=1:numRelationships
        
  		curRelationship = relationships{relationshipID};
        
        g = csvread(['gendirected_output/',num2str(w),'-', curRelationship,'.csv']);
        Nbefore = size(g,1) - 1;
        g = drop_notype(g, Xest);
        g = g - diag(diag(g)); % make sure there are no self links
        fprintf('%d of %d entries dropped from village %d.\n', Nbefore-(size(g,1)-1), Nbefore, w);
        dlmwrite([curRelationship,'.csv'],g,'precision','%d');
        
    end;
    
end;
fprintf('\n');
cd('..');
