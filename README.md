This repository contains code used in the paper "Two-Step Estimation of Network-Formation Models with Incomplete Information" by Michael Leung. 

NOTE: Line 12 of en\_stat.m and line 26 of en\_stat\_slow.m contain an error. They should both be replaced with

Xg = Xg(:,[4:9 16:size(Xg,2)]); % omit pid, drop, educ

As an aside, the text of the published paper neglects to mention that homophily in age is included in the specification. The numbers in the published paper are incorrect due to this slicing error, which erroneously drops a caste indicator ('caste3' in the code) and replaces it with an education indicator ('educ\_oth'). I thank Margherita Comola and Amit Dekel for bringing this to my attention.

The sections below explain some of what you see in this directory. Some of the files described only appear after running main.m. Before using the code, you will need to change [PATH] in main.m, latextables.m, misc.m, and visualizenetwork.r to the actual directory path of this folder. 

Prior to running the code, create the following folders in the current directory: 'raw\_data', 'directed\_adjacency\_matrices', 'dMU', 'lendmoney\_graphs', and 'results'.

1. __'raw\_data' folder:__ Obtain data from http://www.stanford.edu/~jacksonm/IndianVillagesDataFiles.zip. After unzipping, put the contents of the folder '2010-0760\_Data' directly into this folder.
2. __'code' folder:__
   * Run main.m to generate data, estimate the model, and compute the asymptotic variance. 
   * misc.m contains code for creating summary statistics and exporting characteristics for use in visualizenetwork.r
   * visualizenetwork.r generates visual representations of the networks. Its output is saved in 'lendmoney graphs'.
   * latextables.m is used to generate the tables of parameter estimates in the paper.
3. __'directed\_adjacency\_matrices' folder:__ This contains 'lendmoney' and 'rel' csvs generated from drop\_notype\_all.m in the 'code' folder. It also contains adjacency matrix csvs generated by gendirected.m.
4. __'dMU' folder:__ This contains output from dMU.m.
5. __'lendmoney\_graphs' folder:__ This contains output from visualizenetwork.r.
6. __'results' folder:__ This contains output from twostepest.m and avar.m.
7. __other files:__
   * X.mat in the root folder is generated by format\_covariates.m.
   * ind\_char\_subset.tab is a custom zip file taken from the microfinance project website http://economics.mit.edu/faculty/eduflo/social. Its columns are pid hhid resp\_gend resp\_status age religion caste subcaste mothertongue kannada tamil telugu hindi urdu english educ res\_time\_yrs work\_freq work\_freq\_type shgparticipate savings.


ACKNOWLEDGEMENTS

Data and much of the gendirected.m file used here are taken from data and code used in the following papers.
* Abhijit Banerjee, Arun Chandrasekhar, Esther Duflo, Matthew O. Jackson (2013) ``The Diffusion of Microfinance,'' _Science_, 341 (6144)
* Matthew O. Jackson, Tomas Rodriguez-Barraquer, Xu Tan (2012) ``Social Capital and Social Quilts: Network Patterns of Favor Exchange,'' _American Economic Review_, 102 (5).

