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
% class_pred        predicted class as numerical vector [samples x 1]
% binary_assignation binary prediction in the class spaces [samples x classes]
%                   1: the sample is predicted in the class space; 
%                   0: the sample is predicted outside the class space;
% class_pred_string predicted class as string vector {samples x 1}
%                   (available only if model was fitted with the class input vector as a cell array with strings as class labels)
% T                 structure with scores for each class model [samples x classes] 
% Thot              structure with T2 Hotelling for each class model [samples x classes] 
% Thot_reduced      structure with normalised T2 Hotelling for each class model [samples x classes] 
% Tcont             structure with T2 Hotelling contribution for each class model [samples x classes] 
% Qres              structure with Q residuals for each class model [samples x classes] 
% Qres_reduced      structure with normalised Q residuals for each class model [samples x classes] 
% Qcont             structure with Q residuals contribution for each class model [samples x classes] 
% distance          distances based on Qres_reduced and Thot_reduced [samples x classes]
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
% version 5.2 - November 2018
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

for g=1:max(model.settings.class)
    modelpca = model.modelpca{g};
    modelpca = pca_project(X,modelpca);
    % scores
    pred.T{g} = modelpca.Tpred;
    % t hotelling
    pred.Thot{g} = modelpca.Thot_pred';
    pred.Thot_reduced{g} = pred.Thot{g}./modelpca.settings.tlim;
    pred.Tcont{g} = modelpca.Tcont_pred;
    % q residuals
    pred.Qres{g} = modelpca.Qres_pred';
    pred.Qres_reduced{g} = pred.Qres{g}./modelpca.settings.qlim;
    pred.Qcont{g} = modelpca.Qcont_pred;
end
% predict samples
for i=1:size(X,1)
    for g=1:max(model.settings.class)
        Q = pred.Qres_reduced{g};
        T = pred.Thot_reduced{g};
        q = Q(i);
        t = T(i);
        d(i,g) = (q^2 + t^2)^0.5;
    end
    [v,c] = min(d(i,:));
    class_pred_dist(i,1) = c;
end
pred.distance = d;
[pred.class_pred,pred.binary_assignation] = simcafindclass(pred.distance,model.settings.thr);
if strcmp(model.settings.assign_method,'distance')
    pred.class_pred = class_pred_dist;
end
if length(model.labels.class_labels) > 0
    pred.class_pred_string = calc_class_string(pred.class_pred,model.labels.class_labels);
end
