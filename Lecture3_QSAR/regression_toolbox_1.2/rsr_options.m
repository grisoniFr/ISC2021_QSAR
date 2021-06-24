function options = rsr_options(method,pret_type,minvar,maxvar,numseed)

% define options for Reshaped Sequential Replacement (RSR)
% rsr_options creates a structure with all the settings needed to calculate RSR
% default options can be changed by editing the options structure fields
%
% options = rsr_options(method,pret_type,minvar,maxvar,numseed)
%
% INPUT:            
% method:           method of analysis
%                   'pls', 'ols', 'pcr', 'knn', 'bnn', 'ridge'
% pret_type:         data pretreatment, only for pls, pcr, knn, bnn
%                   'none' no scaling
%                   'cent' centering
%                   'auto' autoscaling (centering + variance scaling)
% minvar            minimum number of variables in models
% maxvar            maximum number of variables in models
% numseed           number of models for each model size
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
% minvar            minimum number of variables in models
% maxvar            maximum number of variables in models
% numseed           number of models for each size
% tabu              if tabu == 1, then tabu list is active (default)
% quik_rule         if quik_rule == 1, then QUICK rule is active, only for OLS (default)
% thr_quik          QUIK rule threshold (default = 0.05)
% thr_tabu          threshold for tabu list (default = 0.1)
% dist_type         distance metric, only for KN and BNN
%                   'euclidean' Euclidean distance (default)
%                   'mahalanobis' Mahalanobis distance
%                   'cityblock' City Block distance
%                   'minkowski' Minkowski distance
%                   'jt' jaccard-tanimoto for binary data
% do_plot           settings for showing information during calculation
%                   do_plot = 0: nothing is shown
%                   do_plot = 1: info on the command window during evolution
% 
% RELATED ROUTINES:
% rsr_selection     variable selection based on Reshaped Sequential Replacement (RSR)
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
% RSR toolbox v. 2.0
% March 2020.
% Roberto Todeschini, Matteo Cassotti & Francesca Grisoni
% Milano Chemometrics and QSAR Research Group
% adapted for the Regression toolbox for MATLAB
% version 1.0 - July 2020
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

options.method = method;           % modelling method 'pls', 'ols', 'pcr', 'knn', 'bnn', 'ridge'
options.pret_type = pret_type;     % data pretreatment, only for pls, pcr, knn, bnn
                                   % 'cent' centering
                                   % 'none' no scaling
                                   % 'auto' for autoscaling (centering + variance scaling)
options.cv_type   = 'vene';        % type of cross validation
                                   % 'vene' for venetian blinds'
                                   % 'cont' for contiguous blocks
options.cv_groups = 5;             % cv deletion groups
options.minvar = minvar;           % minimum number of variables in model
options.maxvar = maxvar;           % maximum number of variables in model
options.numseed = numseed;         % number of models for each size
options.tabu = 1;                  % tabu list is active
options.quik_rule = 1;             % QUIK rule is active (only for OLS)
options.do_plot = 1;               % settings for showing info during calculation: 0 none, 1, write
options.thr_quik = 0.05;           % QUIK rule threshold
options.thr_tabu = 0.1;            % threshold for tabu list
options.dist_type = 'euclidean';   % distance type, only for knn and bnn
                                   % 'euclidean' Euclidean distance
                                   % 'mahalanobis' Mahalanobis distance
                                   % 'cityblock' City Block metric
                                   % 'minkowski' Minkowski metric
                                   % 'jt' jaccard-tanimoto for binary data