function options = ga_options(method,pret_type)

% define options for Genetic Algorithms (GA)
% ga_options creates a structure with all the settings needed to calculate GA
% default options can be changed by editing the options structure fields
%
% options = ga_options(method,pret_type)
%
% INPUT:            
% method:           method of analysis
%                   'pls', 'ols', 'pcr', 'knn', 'bnn', 'ridge'
% pret_type:         data pretreatment, only for pls, pcr, knn, bnn
%                   'none' no scaling
%                   'cent' centering
%                   'auto' autoscaling (centering + variance scaling)
% other options have default values that can be changed in the options structure 
%
% OUTPUT:
% options is a structure containing the following fields:
% method            modelling method
% pret_type         data pretreatment
% cv_groups         number of cross validation groups (default = 5)
% cv_type           type of cross validation
%                   'vene' for venetian blinds' (default)
%                   'cont' for contiguous blocks
% num_chrom         number of chromosomes (default = 30)
% startvar          on average, variables per chromosome in the initial population (default = 5)
% maxvar            maximum variables in each chromosome (default = 10)
% probmu            probability of mutation (default = 0.01)
% probcross         probability of cross-over (default = 0.5)
% runs              number of GA runs (repetations, default = 100)
% num_eval          number of evaluations in each run (default = 110)
% perc_validation   percentage of samples to be used in the valdiation set, e.g. 0.2 to set 20%, default = 0
% num_windows       windows (intervals) to be used in PLS and PCR
%                   if set to 1 (default), variables are used in the original form, otherwise
%                   selection is made on the specified number of windows
% dist_type         distance metric, only for KN and BNN
%                   'euclidean' Euclidean distance (default)
%                   'mahalanobis' Mahalanobis distance
%                   'cityblock' City Block distance
%                   'minkowski' Minkowski distance
%                   'jt' jaccard-tanimoto for binary data
% do_plot           settings for showing plots:
%                   do_plot = 0: nothing is shown
%                   do_plot = 1: info on the command window during evolution
%                   do_plot = 2: plots are shown during evolution
% 
% RELATED ROUTINES:
% ga_selection      variable selection based on Genetic Algorithms (GA)
%
% HELP:
% note that a detailed HTML help is provided with the toolbox,
% see the HTML HELP files (help.htm) for futher details and examples
%
% LICENCE:
% This toolbox is distributed with an Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0) licence: https://creativecommons.org/licenses/by-nc-nd/4.0/
% You are free to share - copy and redistribute the material in any medium or format. The licensor cannot revoke these freedoms as long as you follow the following license terms:
% Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
% NonCommercial - You may not use the material for commercial purposes.
% NoDerivatives - If you remix, transform, or build upon the material, you may not distribute the modified material.
%
% REFERENCE:
% The toolbox is freeware and may be used if proper reference is given to the authors, preferably refer to the following paper:
% D. Ballabio, G. Baccolo, V. Consonni. A MATLAB toolbox for multivariate regression. Submitted to Chemometrics and Intelligent Laboratory Systems
% 
% Regression toolbox for MATLAB
% version 1.0 - July 2020
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

options.method = method;            % modelling method 'pls', 'ols', 'pcr', 'knn', 'bnn', 'ridge'
options.pret_type = pret_type;      % data pretreatment, only for pls, pcr, knn, bnn
                                    % 'cent' centering
                                    % 'none' no scaling
                                    % 'auto' for autoscaling (centering + variance scaling)
options.cv_groups = 5;              % cv deletion groups
options.cv_type   = 'vene';         % type of cross validation
                                    % 'vene' for venetian blinds'
                                    % 'cont' for contiguous blocks
options.num_chrom = 30;             % number of chromosomes
options.startvar  = 5;              % on average, variables per chromosome in the original population
options.maxvar    = 15;             % maximum variables in each chromosome
options.probmut   = 0.01;           % probability of mutation 1%
options.probcross = 0.5;            % probability of cross-over 50%
options.runs      = 100;            % number of GA runs
options.num_eval  = 110     ;       % number of evaluations
options.perc_validation = 0;        % percentage of samples to be used in the valdiation set, e.g. 0.2
options.num_windows = 1;            % windows (intervals) to be used in pls, plsda, pcalda, pcaqda
                                    % if set to 1 (default), variables are
                                    % used in the original form, otherwise
                                    % selection is made on the specified
                                    % number of windows
options.dist_type = 'euclidean';    % distance type, only for knn and bnn
                                    % 'euclidean' Euclidean distance
                                    % 'mahalanobis' Mahalanobis distance
                                    % 'cityblock' City Block metric
                                    % 'minkowski' Minkowski metric
                                    % 'sm' sokal-michener for binary data
                                    % 'rt' rogers-tanimoto for binary data
                                    % 'jt' jaccard-tanimoto for binary data
                                    % 'gle' gleason-dice sorenson for binary data
                                    % 'ct4' consonni todeschini for binary data
                                    % 'ac' austin colwell for binary data
options.do_plot = 2;                % settings for showing plots:
                                    % do_plot = 0: nothing is shown
                                    % do_plot = 1: info on the command window
                                    % do_plot = 2: plots