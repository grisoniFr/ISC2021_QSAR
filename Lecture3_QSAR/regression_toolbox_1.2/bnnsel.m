function res = bnnsel(X,y,dist_type,pret_type,cv_type,cv_groups)

% selection of the optimal alpha value for local regression based on Binned Nearest Neighbours (BNN) by means of cross-validation
%
% res = bnnsel(X,y,dist_type,pret_type,cv_type,cv_groups)
%
% INPUT: 
% X                 dataset [samples x variables]
% y                 response vector [samples x 1]
% dist_type:        'euclidean' Euclidean distance
%                   'mahalanobis' Mahalanobis distance
%                   'cityblock' City Block distance
%                   'minkowski' Minkowski distance
%                   'jt' jaccard-tanimoto for binary data
% pret_type         'none' no scaling
%                   'cent' centering
%                   'scal' variance scaling
%                   'auto' for autoscaling (centering + variance scaling)
%                   'rang' range scaling (0-1)
% cv_type           type of cross validation
%                   'vene' for venetian blinds'
%                   'cont' for contiguous blocks
% cv_groups         number of cv groups
%                   if cv_groups == samples: leave-one-out
%
% OUTPUT:
% res is a structure with the following fields:
% R2                R2 in cross-validation as a function of alpha values [1 x alpha values]
% rmse              root mean squared error in cross validation as a function of alpha values [1 x alpha values]
% alpha_list        list of tested alpha values [1 x alpha values]
% settings          settings
%
% RELATED ROUTINES:
% bnnfit            fit BNN regression model
% bnncv             cross-validatation of BNN
% bnnpred           prediction of new samples with BNN
% reg_gui           main routine to open the graphical interface
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

alpha = [0.1:0.1:2];
nalpha = length(alpha);
hwait = waitbar(0,'cross validating models');
for k = 1:nalpha
    if ~ishandle(hwait)
        res.R2 = NaN;
        res.rmse = NaN;
        break
    else
        waitbar(k/nalpha)
        a_val = alpha(k);
        out = bnncv(X,y,a_val,dist_type,pret_type,cv_type,cv_groups);
        res.R2(k) = out.reg_param.R2;
        res.rmse(k) = out.reg_param.rmse;
    end
end
if ishandle(hwait)
    delete(hwait)
end
res.alpha_list = alpha;
res.settings.pret_type = pret_type;
res.settings.cv_type = cv_type;
res.settings.cv_groups = cv_groups;
res.settings.dist_type = dist_type;
