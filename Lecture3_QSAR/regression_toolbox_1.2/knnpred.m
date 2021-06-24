function pred = knnpred(Xtest,X,y,K,dist_type,pret_type)

% prediction with local regression based on K Nearest Neighbours (KNN)
%
% pred = knnpred(Xtest,X,y,K,dist_type,pret_type)
%
% INPUT:            
% Xtest             dataset to be predicted [n_test x variables]
% X                 training dataset [samples x variables]
% y                 training response vector [samples x 1]
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
% pred is a structure containing
% yc                predicted response [n_test x 1]
% neighbours        index of neighbours ordered for similarity as numerical array [n_test x K]
% D                 distance matrix [n_test x samples]
% H                 leverages [n_test x 1]
%    
% RELATED ROUTINES:
% knnfit            fit KNN regression model
% knncv             cross-validatation of KNN
% knnsel            selection of the optimal K for KNN
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

n = size(Xtest,1);
[X_scal_train,param] = data_pretreatment(X,pret_type);
X_scal = test_pretreatment(Xtest,param);
D = knn_calc_dist(X_scal_train,X_scal,dist_type);
neighbors = zeros(n,K);
for i=1:n
    D_in = D(i,:);
    [d_tmp,n_tmp] = sort(D_in);
    neighbors(i,:) = n_tmp(1:K);
    d_neighbors = d_tmp(1:K);
    pred.yc(i,1) = knncalcy(y(neighbors(i,:)));
end
pred.neighbors  = neighbors;
pred.D = D;
if size(X_scal_train,1) > 2*size(X_scal_train,2)
    pred.H = diag(X_scal*pinv(X_scal_train'*X_scal_train)*X_scal');
else
    pred.H = NaN(size(X_scal,1),1);
end
