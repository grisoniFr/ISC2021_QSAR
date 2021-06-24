function model = knnfit(X,y,K,dist_type,pret_type)

% fit local regression based on K Nearest Neighbours (KNN)
%
% model = knnfit(X,y,K,dist_type,pret_type)
%
% INPUT:            
% X                 dataset [samples x variables]
% y                 response vector [samples x 1]
% K                 number of neighbors
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
%
% OUTPUT:
% model is a structure containing
% yc                calculated response [samples x 1]
% r                 residuals [samples x 1]
% r_std         	standardised residuals [samples x 1]
% reg_param         structure with regression measures (RMSE, R2)
% H                 leverages [samples x 1] 
% neighbours        index of neighbours ordered for similarity as numerical array [samples x K]
% D                 distance matrix [samples x samples]
% settings          structure with model settings
% labels            structure with sample and variable labels
%  
% RELATED ROUTINES:
% knnpred           prediction of new samples with KNN
% knncv             cross-validatation of KNN
% knnksel           selection of the optimal K for KNN
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

n = size(X,1);
[X_scal,param] = data_pretreatment(X,pret_type);
D = knn_calc_dist(X_scal,X_scal,dist_type);
neighbors = zeros(n,K);
for i=1:n
    D_in = D(i,:);
    [d_tmp,n_tmp] = sort(D_in);
    % delete i-th object
    ith = find(n_tmp==i);
    d_tmp(ith) = [];  
    n_tmp(ith) = [];
    neighbors(i,:) = n_tmp(1:K);
    d_neighbors = d_tmp(1:K);
    yc(i,1) = knncalcy(y(neighbors(i,:)));
end
reg_param = calc_reg_param(y,yc);
r = y - yc;
if size(X,1) > 2*size(X,2)
    % leverages
    H = diag(X_scal*pinv(X_scal'*X_scal)*X_scal');
    % residuals
    nobj = length(r);
    Hdiff = 1 - H;
    svar = sqrt(diag(r'*(r./(Hdiff.^2)))/(nobj-1))';
    r_std = r./svar(ones(nobj,1),:).*sqrt(Hdiff);
else
    H = NaN(size(X,1),1);
    r_std = NaN(size(X,1),1);
end
model.type = 'knn';
model.yc = yc;
model.r = r;
model.r_std = r_std;
model.reg_param = reg_param;
model.H = H;
model.neighbors  = neighbors;
model.D = D;
model.settings.pret_type = pret_type;
model.settings.param = param;
model.settings.K = K;
model.settings.dist_type = dist_type;
model.settings.raw_data = X;
model.settings.raw_y = y;
model.cv = [];
model.labels.variable_labels = {};
model.labels.sample_labels = {};
