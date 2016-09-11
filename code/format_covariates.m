function format_covariates()

% This creates two matrices of node attributes, saved into a MatLab workspace
% file.

[pid hhid resp_gend resp_status age religion caste subcaste mothertongue kannada tamil telugu hindi urdu english educ res_time_yrs work_freq work_freq_type shgparticipate savings] = textread('ind_char_subset.tab', '%d %d %d %d %d %d %d %s %s %d %d %d %d %d %d %d %d %d %s %d %d', 'delimiter', '\t', 'emptyvalue', NaN);
% Note: res_time_yrs and work_freq have too many missing values, and
% shgparticipate has one unknown value and one missing.

% There's a data entry error in the individual characteristics data - one
% agent is duplicated in village 61, so I manually removed one of the
% entries.

gender = resp_gend - 1; % 1 if female, 0 if male
HOH = resp_status==1;
hindu = religion==1;
islam = religion==2;
christian = religion==3;
caste(caste==1) = 2; % group 1 and 2 into same category
caste1 = caste==4; % "well off" castes
caste2 = caste==3; % OBC castes
caste3 = caste==2; % historically disadvantaged castes
drop = isnan(caste)+(caste==-999)+isnan(religion); % keep track of those missing caste and religion data (61 total)
hindi = round(((strcmp(mothertongue,'"HINDI"')==1)+(hindi==1))/2);
kannada = round(((strcmp(mothertongue,'"KANNADA"')==1)+(kannada==1))/2);
malayalam = strcmp(mothertongue,'"MALAYALAM"')==1;
marati = strcmp(mothertongue,'"MARATI"')==1;
tamil = round(((strcmp(mothertongue,'"TAMIL"')==1)+(tamil==1))/2);
telugu = round(((strcmp(mothertongue,'"TELUGU"')==1)+(telugu==1))/2);
urdu = round(((strcmp(mothertongue,'"URDU"')==1)+(urdu==1))/2);
educ_primary = educ > 0 & educ < 6;
educ_secondary = educ > 5 & educ < 11;
educ_puc = educ == 11 | educ == 12;
educ_ideg = educ == 13;
educ_deg = educ == 14;
educ_oth = educ == 15;

% main covariates matrix
X = [pid age gender HOH hindu islam christian caste1 caste2 caste3 hindi kannada malayalam marati tamil telugu urdu english educ_primary educ_secondary educ_puc educ_ideg educ_deg educ_oth];
% pid1 age2 gender3 HOH4 hindu5 islam6 christian7 caste18 caste29 caste310
% hindi11 kannada12 malayalam13 marati14 tamil15 telugu16 urdu17 english18 
% educ19

% this matrix is used for the first-step estimator and to drop missing data
Xest = [pid drop age gender HOH hindu caste2 caste3 educ_primary educ_secondary educ_puc educ_ideg educ_deg educ_oth hindi kannada malayalam marati tamil telugu urdu english];
save('X.mat', 'X', 'Xest');