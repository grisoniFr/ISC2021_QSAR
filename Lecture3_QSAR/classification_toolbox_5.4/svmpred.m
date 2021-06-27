function pred = svmpred(X,model)

% prediction with Support Vector Machines
%
% pred = svmpred(X,model)
% 
% INPUT:
% X                 dataset [samples x variables]
% model             SVM model calculated by means of svmfit
%
% OUTPUT:
% pred is a structure containing the following fields:
% class_pred        predicted class as numerical vector [samples x 1]
% class_pred_string predicted class as string vector {samples x 1}
%                   (available only if model was fitted with the class input vector as a cell array with strings as class labels)
% prob              class probability [samples x classes] 
% dist              distance from class boundary [samples x 1]
%
% SVM are based on the MATLAB toolbox, further info:
% http://it.mathworks.com/help/stats/support-vector-machines-svm.html
%
% RELATED ROUTINES:
% svmpred          prediction of classes of new samples with SVM
% svmcv            cross-validatation of SVM
% svmcostsel        selection of the optimal cost and kernel parameter for SVM
% class_gui         main routine to open the graphical interface
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
% Ballabio D, Consonni V, (2013) Classification tools in chemistry. Part 1: Linear models. PLS-DA. Analytical Methods, 5, 3790-3798
% 
% Classification toolbox for MATLAB
% version 5.4 - November 2019
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

if isnan(model.settings.num_comp)
    X_scal = test_pretreatment(X,model.settings.param);
else
    [model_pca] = pca_project(X,model.settings.model_pca);
    X_scal = model_pca.Tpred;
end

[~,dist] = predict(model.settings.net,X_scal);
dist = dist(:,2);
[~,prob] = predict(model.settings.net_scores,X_scal);
prob = prob(:,[2 1]);
% class prediction
class_pred = sign(dist);
% put 2 instead of -1
class_pred(find(class_pred == -1)) = 2;
pred.class_pred = class_pred;
if length(model.labels.class_labels) > 0
    pred.class_pred_string = calc_class_string(pred.class_pred,model.labels.class_labels);
end
pred.prob = prob;
pred.dist = dist;
