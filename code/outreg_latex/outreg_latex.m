function [latex_code] = outreg_latex(results,names,more_results,more_results_names,model_names,table_opts);

%
% Function outreg_latex.m written by
% Rob Hicks
% Department of Economics
% The College of William and Mary
% rob.hicks _at_ wm.edu
% http://rlhick.people.wm.edu
%

% This function is an implementation of some of the features of the 
% ado routines outreg and outreg2 found in stata.  These routines make it
% easy to put statistical results into a latex table.  This function tries
% to do the same.

% Given the structs results,names,more_results,more_results_names
% this function prints standard regression output for journal articles in
% latex format for easy incorporation into your latex document.  

% Models are placed as columns in the table with standard errors for each
% variable in results put in parenthesis below the coefficient estimate.
% Significance results are p<=.05 is ** and .05<p<=.1 is *.  These are
% not user definable at present.

% The function also adds metadata as comments preceding your table code
% (name and path of calling function and outreg_latex.m and the date).
% I find this information useful to include in the tex document for going
% back to replicate results after some time has passed.

% To be assured of proper tex table syntax be sure to copy from the 
% matrix/cell view (click on the cell in the matlab workspace window) and 
% copy the code from there.  Unfortunately matlab surrounds each line of tex
% code with '.  Remove these from within your tex document.

% ****
% Remember to remove the ' character at the beginning and end of each line 
% after you paste the copied code into your tex document.
% ****

% The sample file 'sample_frontend.m' demonstrates most of the
% functionality of this function.

% Notes:
% 
% 1. You will need to create the following matlab structures/matrices/cells: 
%    A. The structure results contains:
%       M matrices (one for each of M models) with variables in rows with 
%         the following columns: parameter estimate, standard error,
%         perhaps other columns of data, and the p-value in the final
%         column.
%         -The matrices comprising the structure results need not be of the
%          same dimension.
%         -The function works if M=1 (you only want to build a table for
%          one model).
%    B. The structure names contains:
%       M cells containing variable names for each row of each corresponding matrix found
%         in results.  The variable names need not be the same across the M
%         models.  However, this function uses these variable names to
%         match results across columns, so take care in labeling your
%         variables appropriately.
%         -Variable names given in names and more_results_names should be latex
%          compliant  (e.g. my_variable_name is not latex compliant, use
%          my\_variable\_name instead.  R^2 is not latex compliant, whereas $R^2$
%          is.)
%    C. The structure more_results contains:
%       M vectors containing model statistics that do not have standard
%       errors.
%         -e.g., sample size, r-squared, chi-squared stats.  If you need to 
%          include standard errors, include the parameters of interest in results!!!
%    D. The structure more_results_names contains:
%       M cells with variable names for each row of each matrix in the
%       structure more results.
%         -Again, make your names latex compliant
%         -Again, you may have different statistics/names for each of the M
%          models, but when building the table, matching occurs by name.
%    E. The cell model_names contains column headers for your table:
%       An M x 1 cell containing model names as text.  To use generic model 
%       names (Model 1, Model 2, etc.) set model_names=[].
%    F. The cell, table_opts (1 x 1) contains one of the following latex 
%       table environment variables: table, longtable, 
%       sidewaystable (not yet tested)
%       
% 2. The function matches results across models by common variable names
%    and sorts them alphabetically.  At present there is no sort order
%    capability.  A crude way to order your results is to include a leading
%    integer value (e.g. variable Z becomes variable 1Z if you want Z to
%    appear first in the table) and then remove these in your latex
%    document before the final compilation of the pdf.
%
% 3. At present there is no multicolumn or other fancy functionality.
%
% 4. At present there is no error checking.  If, for example, the
%    dimensions of names is different from results for a model this code
%    will crash.  If you get crashes, check your input structs to make
%    sure it is in line with the requirements set out above.


%
%  Gather information about number of models
%

fn_results = fieldnames(results);
fn_names=fieldnames(names);

fn_more_results=fieldnames(more_results);
fn_more_results_names=fieldnames(more_results_names);

model_number=length(fn_results); % This dictates columns in your latex table

%%
% This creates column headers for all results
%

% does generic model names
label=[];
   for i=1:model_number
     label=[label,' & Model ',num2str(i)];
   end  
 
% does custom model names
if ~isempty(model_names)
    label=[];
    for i=1:model_number
       label=strcat(label,'&',model_names(i,:));
    end
end

label=strcat(label,' \\');  

%%
% Creates set of unique variable names
%
all_names=[];
for i=1:model_number
  this_data=['names.',char(fn_names(i))]; 
  all_names=[all_names;eval(this_data)];
end

unique_names=unique(all_names);

all_more_names=[];
for i=1:model_number
  this_data=['more_results_names.',char(fn_more_results_names(i))]; 
  all_more_names=[all_more_names;eval(this_data)];
end

unique_more_names=unique(all_more_names);


%%
%
%
% Loop over variables with standard errors found in results
%
%

% now start the loop across unique variable names and assemble text values
% to go in each row across all models


oparen='(';
cparen=')';

count=1;

for i=1:length(unique_names)
    row_name=unique_names(i);
  %  
  % Loop over models  
  %
  
  for j=1:model_number
    this_data_n=['results.',char(fn_results(j))];
    this_data=eval(this_data_n);
    this_name_n=['names.',char(fn_names(j))];
    this_name=eval(this_name_n);
  % Find the information in this_data that matches with this_name  
    rel_data=this_data(strcmp(row_name,this_name)==1,:);
    
     % Now output data for this row of latex code
     if ~isempty(rel_data)
      
         % Set *'s for this row of data (significance level)
          
          if rel_data(1,end)<=.01
              star='$^{***}$';
          elseif rel_data(1,end) > .01 && rel_data(1,end)<=.05
             star='$^{**}$';
          elseif rel_data(1,end) > .05 && rel_data(1,end)<=.1
             star='$^{*}$';
          else 
             star=''; 
          end   
      if j==1
         latex_model{count,1}=strcat(unique_names{i},'&',num2str(rel_data(1,1)),star,'&');
         latex_model{count+1,1}=strcat('&',oparen,num2str(rel_data(1,2)),cparen,'&');
      elseif j>1 & j<model_number
         latex_model{count,1}=strcat(latex_model{count,1},num2str(rel_data(1,1)),star,'&');
         latex_model{count+1,1}=strcat(latex_model{count+1,1},oparen,num2str(rel_data(1,2)),cparen,'&');
      else % this one if i==rows(unique_names)
         latex_model{count,1}=strcat(latex_model{count,1},num2str(rel_data(1,1)),star,'\\');
         latex_model{count+1,1}=strcat(latex_model{count+1,1},oparen,num2str(rel_data(1,2)),cparen,'\\');
      end
     else
     % if the model didn't have this particular variable, just put placeholder &'s    
      if j==1
         latex_model{count,1}=strcat(unique_names{i},'&','&');
         latex_model{count+1,1}=strcat('&','&');
      elseif j>1 & j<model_number
         latex_model{count,1}=strcat(latex_model{count,1},'&');
         latex_model{count+1,1}=strcat(latex_model{count+1,1},'&');
      else % this one if i==rows(unique_names)
         latex_model{count,1}=strcat(latex_model{count,1},'\\');
         latex_model{count+1,1}=strcat(latex_model{count+1,1},'\\');
      end   
     end 
  end
   
  count=count+2;

end

%%
%
%
% This part builds the more_results part of the table, things like R2, N,
% and other model statistics not having standard errors.
%
%
%
count=1;
for i=1:length(unique_more_names)
    row_name=unique_more_names(i);
  %  
  % Loop over models  
  %
  
  for j=1:model_number
    this_data_n=['more_results.',char(fn_more_results(j))];
    this_data=eval(this_data_n);
    this_name_n=['more_results_names.',char(fn_more_results_names(j))];
    this_name=eval(this_name_n);
  % Find the information in this_data that matches with this_name  
    rel_data=this_data(strcmp(row_name,this_name)==1,:);
     % Now output data for this row of latex code
     % Check if parameter is missing for this model and if not put results
     % in table
     if ~isempty(rel_data)
   
      if j==1
         latex_more_model{count,1}=strcat(unique_more_names{i},'&',num2str(rel_data(1,1)),'&');

      elseif j>1 && j<model_number
         latex_more_model{count,1}=strcat(latex_more_model{count,1},num2str(rel_data(1,1)),'&');
      else % this one if i==rows(unique_names)
         latex_more_model{count,1}=strcat(latex_more_model{count,1},num2str(rel_data(1,1)),'\\');
      end
     
     % if the model didn't have this particular variable, just put placeholder &'s 
     else    
      if j==1
         latex_more_model{count,1}=strcat(unique_more_names{i},'&','&');
      elseif j>1 && j<model_number
         latex_more_model{count,1}=strcat(latex_more_model{count,1},'&');
      else % this one if i==rows(unique_names)
         latex_more_model{count,1}=strcat(latex_more_model{count,1},'\\');
      end   
     end 
  end
   
  count=count+1;

end    


%%
%
%  Set tabular environment variables
%
%

  tabvar='\begin{tabular}{r|';
  for i=1:model_number
     tabvar=[tabvar,'r']; 
  end
  tabvar=[tabvar,'}'];

  longtabvar='{r|';
  for i=1:model_number
     longtabvar=[longtabvar,'r']; 
  end
  longtabvar=[longtabvar,'}'];
  
%%
%
%
% Put it all together with headers
%
%

if strcmp(table_opts,'sidewaystable')==1
latex_code_temp=['\begin{sidewaystable}[ht]';'\centering';'\caption{Insert Title Here}';tabvar; ...
                      '\hline \hline';label;'\hline';latex_model;'\hline'; latex_more_model ;'\hline \hline'; ...
                      '\end{tabular}';'\label{tab:addlabel}';'\end{sidewaystable}'];

elseif strcmp(table_opts,'longtable')==1
% longtable adds spaces at end of table
latex_more_model(end) = strrep(latex_more_model(end), '\\', '');    

latex_code_temp=[strcat('\begin{longtable}',longtabvar);'\caption{Insert Title Here}\\'; ...
                   '\hline \hline';label;'\hline';'\endfirsthead'; '\caption[]{(continued)}\\ \hline\hline';...
                   label;'\hline';'\endhead';'\hline';strcat('\multicolumn{',num2str(model_number+1),'}{|c|}{Continued $\ldots$}\\'); ...
                   '\hline';'\endfoot';'\hline \hline';'\endlastfoot'; ...
                   latex_model;'\hline'; latex_more_model;'\label{tab:addlabel}';'\end{longtable}'];

else % the default is table
latex_code_temp=['\begin{table}[ht]';'\centering';'\caption{Insert Title Here}';tabvar; ...
                      '\hline \hline';label;'\hline';latex_model;'\hline'; latex_more_model ;'\hline \hline'; ...
                      '\end{tabular}';'\label{tab:addlabel}';'\end{table}'];    
end

%%
%
%  Embed metadata into latex code
% 

c=clock;
time_char=strcat(num2str(c(2)),'/',num2str(c(3)),'/',num2str(c(1)),'-',num2str(c(4)),':',num2str(c(5)),':',num2str(c(6)));

%mystack = dbstack;
ThisFileNameWithPath = 'h';
CallerFileNameWithPath = 'i';

latex_code=['%   This table generated by the matlab function outreg_latex.m';'%   Written by Rob Hicks, Department of Economics';'%   The College of Wiliam and Mary (rob.hicks _at_ wm.edu)';'%   Found in:'; ...
                  strcat('%   ',ThisFileNameWithPath) ; '%   It was run from the calling file:'; strcat('%   ',CallerFileNameWithPath); ...
                  strcat('%   On:',' ', time_char);'% ';latex_code_temp ] ;
              
fprintf('Copy your latex code from the cell latex_code found in the matlab workspace window\n');              

