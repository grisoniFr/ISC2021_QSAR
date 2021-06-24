function pred = uneqpred(X,model)

% prediction with UNEQ
%
% pred = uneqpred(X,model)
%
% INPUT:
% X                 dataset [samples x variables]
% model             uneq model calculated by means of uneqfit
%
% OUTPUT:
% pred is a structure containing the following fields:
% class_pred        predicted class as numerical vector [samples x 1]
% binary_assignation binary prediction in the class spaces [samples x classes]
%                   1: the sample is predicted in the class space; 
%                   0: the sample is predicted outside the class space;
% class_pred_string predicted class as string vector {samples x 1}
%                   (available only if model was fitted with the class input vector as a cell array with strings as class labels)
% T                 structure with scores for each class model [samples x classes] 
% Thot              matrix with T2 Hotelling for each class model [samples x classes] 
% Thot_reduced      matrix with normalised T2 Hotelling for each class model [samples x classes] 
% Tcont             structure with T2 Hotelling contribution for each class model [samples x classes]
% Qcont             structure with Q residuals contribution for each class model [samples x classes] 
%
% RELATED ROUTINES:
% uneqfit           fit of UNEQ
% uneqcv            cross-validation of UNEQ
% uneqcompsel       selection of the optimal number of components for UNEQ
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
% version 5.2 - November 2018
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

for g=1:max(model.settings.class)
    modelpca = model.modelpca{g};
    modelpca = pca_project(X,modelpca);
    % Scores
    pred.T{g} = modelpca.Tpred;
    % hotelling T2
    pred.Thot(:,g) = modelpca.Thot_pred';
    pred.Thot_reduced(:,g) = pred.Thot(:,g)./modelpca.settings.tlim;
    pred.Tcont{g} = modelpca.Tcont_pred;
    % Q residuals
    pred.Qcont{g} = modelpca.Qcont_pred;
end
% always assign samples
for i=1:size(X,1)
    [v,c] = min(pred.Thot_reduced(i,:));
    class_pred_dist(i,1) = c;
end
[pred.class_pred,pred.binary_assignation] = simcafindclass(pred.Thot_reduced,model.settings.thr);
if strcmp(model.settings.assign_method,'distance')
    pred.class_pred = class_pred_dist;
end
if length(model.labels.class_labels) > 0
    pred.class_pred_string = calc_class_string(pred.class_pred,model.labels.class_labels);
end