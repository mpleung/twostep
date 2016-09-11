function gendirected(vils)
% This is a slightly altered portion of the code from Support06_26_2011.m, 
% taken from ``Social Capital and Social Quilts: Network Patterns of Favor
% Exchange'' by Matthew O. Jackson, Tomas Rodriguez-Barraquer, and Xu Tan,
% American Economic Review, 2012.

% This code generates directed adjacency matrices for lending and family
% networks. Members of the same household are automatically coded as being
% linked in the family network. Lending is directed while family relations
% are undirected.

% Adjacency matrices are saved as csv files in the folder 
% 'directed_adjacency_matrices/gendirected_output'.

% The lending matrix comes with person IDs for each row and column. For
% networks 1-9, a person ID is a 6-digit number. The first digit is the
% village. The next three digits are the household ID. The last digit is
% the person ID, as defined in for village1.csv. For networks 10-77, a
% person ID is a 7-digit number, where now the first two digits is the
% village number.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in the data about the village so we can build the full mapping
% between internal ID and HHIDPID

% only use villages with at least 10% non-hindus
vils = [6 12 29 34 35 46 71 74 76];

for x=vils
	% two missing villages
	if x==13||x==22
		continue;
    end
    
    w=x
    
    % The folder 'raw data' contains the contents of the zip file at
	% http://www.stanford.edu/~jacksonm/IndianVillagesDataFiles.zip
    village = csvread(['raw_data/Data/Raw_csv/village',num2str(w),'.csv']);

	persons = 100*village(:,1) + village(:,2);
	numPersons = length(persons);

	% vids = floor( village(:,1) / 1000 );
	% vid = vids(1); % This is the village id. We only use one at a time

	% Household ID's and Person ID's
	hhids = mod( village(:,1), 1000 );
	pids = village(:,2);
	numHouseholds = max(hhids);
	
	% These structures will map between the "person ID" (as given in the cells of the file)
	% and their "ID"  (as used in the adjacency matrix)
	% Since "person ID" could look like 500124, and we don't want an adjacency matrix that is 500K x 500K,
	% each person wil be associated wtih an ID that counts from 1, so that row ID(person) and col ID(person)
	% of the adjacency matrix will define the links for that person
	personToID = {};
	IDtoPerson = zeros(1,numPersons);
	
	% This structure will be used to show that members within a household have a relationship
	% households(i,j) = ID( v i j ) if household i has pid j (in village v), 0 otherwise
	households = zeros(numHouseholds,9);
	
	% Populate the mappings and household structures
	for curID=1:numPersons
		person = persons(curID);
	  	hhid = hhids(curID);
	  	pid = pids(curID);
	  
	  	% It turns out that octave/matlab will not let the field of a structure begin with a number
	  	% So we add letters before the numbers
	  	personField = ['P',num2str(person)];
	  
	  	% Update the maps
	  	personToID.(personField) = curID;
	  	IDtoPerson(curID) = person;
	  
  		% Update the household structure
  		households(hhid,pid) = curID;
  
    end

	% Now we will build the "base" adjacency matrix, in which nodes which belong
	% to the same household are connected
	baseAdjMat = zeros(numPersons,numPersons);

	housesize=zeros(numHouseholds,1);
	% Look through the households 
	for h = 1:numHouseholds
  
  		% Within the household, we want all the pairs of PID's
  		% (i,j) for i != j
  		for i = 1:max(village(:,2))
    
    			% No more ID's left in this household
    			if ~households(h,i)
      				housesize(h,1)=i-1;
      				break;
    			end
    
    			basePerson = households(h,i);
    
    			% Match i with its pairing, j
    			for j = i+1:max(village(:,2))
      
      				% No more ID's to pair with
      				if ~households(h,j)
        				break;
      				end
      
      				curPerson = households(h,j);
      
      				% Add vertices
      				baseAdjMat(basePerson,curPerson) = 1;
      				baseAdjMat(curPerson,basePerson) = 1;
      
    			end
    
  		end
  		if i==max(village(:,2))&&housesize(h,1)==0
      			housesize(h,1)=max(village(:,2));
  		end

    end

	% Now we build adjacency matrices for every lending and family relation

	relationships = ...
  	{
    	strcat('lendmoney',num2str(w));
    	strcat('rel',num2str(w));
  	};

	numRelationships = size(relationships,1);

	villageRelationships = zeros(numPersons,numPersons,numRelationships);

	% Walk through each relationship
	for relationshipID=1:numRelationships
  		curRelationship = relationships{relationshipID};
  
  		% Read in the relationship info as a List of Lists (LoL)
  		LoL = csvread(['raw_data/Data/Raw_csv/',curRelationship,'.csv']);
  
  		% Start building the Adjacency Matrix
        if(strcmp(curRelationship,'rel'))
            adjMat = baseAdjMat; % those in the same household are considered family
        else
            adjMat = zeros(numPersons,numPersons); % those in the same household aren't assume to lend to each other
        end;
  
  		for i = 1:size(LoL,1)
    
    		% The first cell in a row is the ID of the base person
    			basePerson = LoL(i,1);
    			if (basePerson == 0)
      				continue;
    			end
    
    		% Find the ID mapping
    			basePersonField = ['P',num2str(basePerson)];
    			if ~isfield(personToID,basePersonField)
      				continue;
    			end
    
    			baseID = personToID.(basePersonField);

    			% The remaining cells in the row are the links to other people that were
    			% given by the base person
    			for j = 2:size(LoL,2)

      				curPerson = LoL(i,j);
      			if curPerson==0 % If it's a zero there is nothing to process
        			continue
		        end	
      
      			% Find the ID mapping for the person
     				 curPersonField = ['P',num2str(curPerson)];
      			if ~isfield(personToID,curPersonField)
        			continue;
      			end
      			curID = personToID.(curPersonField);
      
      			% Make the relevant updates to the adjacency matrix
      			adjMat(baseID,curID) = 1;
      
                end

        end
  
  	% Put the matrix into the village relationships structure
  	villageRelationships(:,:,relationshipID) = adjMat;
    
  	% Now let's make a CSV file of this, for viewing purposes
    
  	% Add row labels
  	adjMat = [ IDtoPerson', adjMat ];
  	% Add column labels
  	adjMat = [ [0,IDtoPerson]; adjMat ];
    
  	dlmwrite(['directed_adjacency_matrices/gendirected_output/',num2str(w),'-',curRelationship,'.csv'],adjMat,'precision','%d');
  	
    end
    
end