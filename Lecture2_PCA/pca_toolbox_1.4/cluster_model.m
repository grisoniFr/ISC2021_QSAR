function model = cluster_model(X,distance,pret_type,linkage_type)

% calculates hierarchical cluster analysis
%
% model = cluster_model(X,distance,pret_type,linkage_type)
%
% INPUT:            
% X                 dataset [samples x variables]
% distance:         distance
%                   'euclidean': Euclidean distance
%                   'cityblock': City Block distance
%                   'mahalanobis': Mahalanobis distance
%                   'minkowski': Minkowski distance with exponent 2
%                   'jaccard': Jaccard-Tanimoto distance for binary data
% pret_type         data pretreatment 
%                   'none' no scaling
%                   'cent' centering
%                   'scal' variance scaling
%                   'auto' for autoscaling (centering + variance scaling)
%                   'rang' range scaling (0-1)
% linkage_type:     type of linkage for clustering
%                   'single': nearest distance
%                   'complete': furthest distance
%                   'average': average distance
%                   'centroid': center of mass distance
%
% OUTPUT:
% model is a structure containing the following fields:
% L                 linkage results as reported in the matlab linkage function
% D                 distance matrix [samples x samples]
% settings          structure array with settings
%
% RELATED ROUTINES:
% pca_model         calculates Principal Component Analysis (PCA)
% pca_project       project new samples in a PCA model
% mds_model         calculates Multidimensional Scaling (MDS)
% pca_compsel       selection of the optimal number of principal components for PCA
% pca_gui           main routine to open the graphical interface 
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
% D. Ballabio (2015), A MATLAB toolbox for Principal Component Analysis and unsupervised exploration of data structure
% Chemometrics and Intelligent Laboratory Systems, 149 Part B, 1-9
% 
% PCA toolbox for MATLAB
% version 1.4 - December 2018
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

[X_in,param] = data_pretreatment(X,pret_type);
if license('test','statistics_toolbox')
    D = pdist(X_in,distance);
    L = linkage(D,linkage_type);
    D = squareform(D);
else
    D = NaN;
    L = NaN;
end
% save results
model.type = 'cluster';
model.L = L;
model.D = D;
model.settings.raw_data = X;
model.settings.distance = distance;
model.settings.linkage_type = linkage_type;
model.settings.param = param;
model.labels.variable_labels = {};
model.labels.sample_labels = {};
model.labels.class_labels = {};
