function res = forward_selection(X,y,options)

% function for variable selection based on Forward Selection
%
% res = forward_selection(X,y,options)
%
% INPUT:            
% X                 dataset [samples x variables]
% y                 response vector [samples x 1]
% options           options created with the functions forward_options
%
% OUTPUT:
% res is a structure containing the following fields:
% included_var      selected variable IDs [1 x options.maxvar] 
% step_selection    structure with R2, R2cv, rmse, rmsecv, selected variable ID for each selection step [options.maxvar x 1]
% options           selection options
% 
% RELATED ROUTINES:
% forward_options   create options for variable selection based on Genetic Algorithms (GA)
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
if strcmp(options.method,'pls') || strcmp(options.method,'pcr')
    [~,max_param] = ga_cv(X,y,[1:size(X,2)],options,max_param);
end
if isfield(options,'num_windows')
    num_windows = options.num_windows;
else
    num_windows = 1;
end
if num_windows < 2
    nvar = size(X,2);
else
    nvar = num_windows;
end
best_param = NaN;
var_in = [];
cnt = 0;
if options.do_plot == 2
    hwait = waitbar(0,'Forward selection');
end
while length(var_in) < options.maxvar
    best_resp = -999;
    for k = 1:nvar
        if length(find(var_in == k)) < 1
            test_var = [var_in k];
            [r2cvhere,paramhere,~,rmsecvhere,r2here,rmsehere] = ga_cv(X,y,test_var,options,max_param);
            if r2cvhere >= best_resp
                best_resp = r2cvhere;
                best_param = paramhere;
                best_rmsecv = rmsecvhere;
                best_r2 = r2here;
                best_rmse = rmsehere;
                sel_var = k;
            end
        end
    end
    var_in = [var_in sel_var];
    cnt = cnt + 1;
    step_selection(cnt,1).r2cv = best_resp;
    step_selection(cnt,1).rmsecv = best_rmsecv;
    step_selection(cnt,1).r2 = best_r2;
    step_selection(cnt,1).rmse = best_rmse;
    step_selection(cnt,1).selected_variables = var_in;
    step_selection(cnt,1).param = best_param;
    if options.do_plot == 1
        disp(['selection of variable ' num2str(cnt) ' over ' num2str(options.maxvar)])
    elseif options.do_plot == 2
        waitbar(cnt/options.maxvar)
    end
end
if options.do_plot == 2
    delete(hwait)
end
res.included_var = var_in;
res.step_selection = step_selection;
res.options = options;
end