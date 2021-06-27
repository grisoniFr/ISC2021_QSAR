function pred = simcapred(X,model)

% prediction with SIMCA
%
% pred = simcapred(X,model)
%
% INPUT:
% X                 dataset [samples x variables]
% model             simca model calculated by means of simcafit
%
% OUTPUT:
% pred is a structure containing the following fields:
% class_pred        predicted class (binary vector) [samples x 1]
%                   class_pred = 1: the sample is predicted in the modelled (target) class space
%                   class_pred = 0: the sample is predicted outside the modelled (target) class space
% class_pred_string predicted class as string vector {samples x 1}
%                   (available only if the class input vector is a cell array with strings as class labels)
%                   class_pred_string = 'target class': the sample is predicted in the modelled (target) class space
%                   class_pred_string = 'not target class': the sample is predicted outside the modelled (target) class space
% T                 scores for the PCA class model [samples x components] 
% Thot              T2 Hotelling [samples x 1] 
% Thot_reduced      normalised T2 Hotelling [samples x 1] 
% Tcont             T2 Hotelling contribution [samples x 1] 
% Qres              Q residuals [samples x 1] 
% Qres_reduced      normalised Q residuals [samples x 1] 
% Qcont             Q residuals contribution [samples x 1] 
% distance          distances based on Qres_reduced and Thot_reduced [samples x 1]
%
% RELATED ROUTINES:
% simcafit          fit of SIMCA
% simcacv           cross-validation of SIMCA
% simcacompsel      selection of the optimal number of components for SIMCA
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

modelpca = model.modelpca;
modelpca = pca_project(X,modelpca);
% scores
pred.T = modelpca.Tpred;
% t hotelling
pred.Thot = modelpca.Thot_pred';
pred.Thot_reduced = pred.Thot./modelpca.settings.tlim;
pred.Tcont = modelpca.Tcont_pred;
% q residuals
pred.Qres = modelpca.Qres_pred';
pred.Qres_reduced = pred.Qres./modelpca.settings.qlim;
pred.Qcont = modelpca.Qcont_pred;

% predict samples
for i=1:size(X,1)
    Q = pred.Qres_reduced;
    T = pred.Thot_reduced;
    q = Q(i);
    t = T(i);
    pred.distance(i,1) = (q^2 + t^2)^0.5;
end
[pred.class_pred] = simcafindclass(pred.distance,model.settings.thr);
if length(model.labels.class_labels) > 0
    pred.class_pred_string = cell(length(pred.class_pred),1);
    pred.class_pred_string(:) = {model.settings.target_class};
    pred.class_pred_string(find(pred.class_pred == 0)) = model.labels.class_labels_classmodelling(2);
end
