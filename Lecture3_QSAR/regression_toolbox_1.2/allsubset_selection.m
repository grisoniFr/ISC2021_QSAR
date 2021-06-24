function res = allsubset_selection(X,y,options)

% function for variable selection based on all subset selection
%
% res = forward_selection(X,y,options)
%
% INPUT:            
% X                 dataset [samples x variables]
% y                 response vector [samples x 1]
% options           options for all subset selection, a structure array
%                   containing the following fields        
% method            method of analysis
%                   'pls', 'ols', 'pcr', 'knn', 'bnn', 'ridge'
% pret_type          data pretreatment, only for pls, pcr, knn, bnn
%                   'none' no scaling
%                   'cent' centering
%                   'auto' autoscaling (centering + variance scaling)
% maxvar            maximum number of variables to be selected
% cv_groups         number of cross validation groups (e.g. 5)
% cv_type           type of cross validation
%                   'vene' for venetian blinds'
%                   'cont' for contiguous blocks
% maxvar            maximum number of variables to be selected
% dist_type         distance metric, only for KN and BNN
%                   'euclidean' Euclidean distance (default)
%                   'mahalanobis' Mahalanobis distance
%                   'cityblock' City Block distance
%                   'minkowski' Minkowski distance
%                   'jt' jaccard-tanimoto for binary data
% do_plot           settings for showing plots:
%                   do_plot = 0: nothing is shown
%                   do_plot = 1: plot bar during calculation
%
% OUTPUT:
% res is a structure containing the following fields:
% var_list          selected variable IDs 
% step_selection    structure with R2, R2cv, rmse, rmsecv, selected variable ID for selected subset
% options           selection options
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

max_param = 10;
if options.do_plot == 2
    hwait = waitbar(0,'All subset selection');
end
% start all subset
cnt_var = 0;
count_models = 0;
total_models = 0;
% count total models to be calculated
for k=1:options.maxvar
    C = nchoosek([1:size(X,2)],k);
    total_models = total_models + size(C,1);
end
if options.do_plot == 1
    hwait = waitbar(0,'all subsets selection');
end
for k=1:options.maxvar
    C = nchoosek([1:size(X,2)],k);
    r2 = []; rmse = []; r2cv = []; rmsecv = []; param = []; selected_variables = {};
    for a=1:size(C,1)
        count_models = count_models + 1;
        waitbar(count_models/total_models);
        test_varhere = C(a,:);
        [r2cvhere,paramhere,~,rmsecvhere,r2here,rmsehere] = ga_cv(X,y,test_varhere,options,max_param);
        selected_variables{a,1} = test_varhere;
        r2cv(a,1) = r2cvhere;
        rmsecv(a,1) = rmsecvhere;
        r2(a,1) = r2here;
        rmse(a,1) = rmsehere;        
        param(a,1) = paramhere;
    end
    [m,s] = sort(r2cv,1,'descend');
    if size(C,1) > 3
        model_to_store_for_dimension = 3;
    else
        model_to_store_for_dimension = size(C,1);
    end
    for g =1:model_to_store_for_dimension
        cnt_var = cnt_var + 1;
        step_selection(cnt_var,1).r2cv = r2cv(s(g),1);
        step_selection(cnt_var,1).rmsecv = rmsecv(s(g),1);
        step_selection(cnt_var,1).r2 = r2(s(g),1);
        step_selection(cnt_var,1).rmse = rmse(s(g),1);        
        step_selection(cnt_var,1).selected_variables = selected_variables{s(g)};
        step_selection(cnt_var,1).param = param(s(g),1);
        var_list{cnt_var} = step_selection(cnt_var,1).selected_variables;
    end
end

if options.do_plot == 1
    delete(hwait)
end
res.var_list = var_list;
res.step_selection = step_selection;
res.options = options;
end