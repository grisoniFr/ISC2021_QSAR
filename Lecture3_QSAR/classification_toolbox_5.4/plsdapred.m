function pred = plsdapred(X,model)

% prediction with Partial Least Squares Discriminant Analysis (PLSDA)
%
% pred = plsdapred(X,model)
%
% INPUT:            
% X                 dataset [samples x variables]
% model             plsda model calculated by means of plsdafit
%
% OUTPUT:
% pred is a structure containing the following fields:
% yc                predicted response [samples x classes]
% prob              class probability [samples x classes] 
% class_pred        predicted class as numerical vector [samples x 1]
% class_pred_string predicted class as string vector {samples x 1}
%                   (available only if model was fitted with the class input vector as a cell array with strings as class labels)
% H                 leverages [samples x 1]
% T                 predicted scores [samples x comp]
% Thot              T2 Hotelling [samples x 1]
% Qres              Q residuals [samples x 1]
% Tcont             T2 Hotelling contributions [samples x variables]
% Qcont             Q contributions [sampels x variables]
%
% RELATED ROUTINES:
% plsdafit          fit of PLSDA
% plsdacv           cross-validatation of PLSDA
% plsdacompsel      selection of the optimal number of latent variables for PLSDA
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

W = model.W;
Q = model.Q;
P = model.P;
nF = size(model.T,2);
T = model.T;
X_scal = test_pretreatment(X,model.settings.px);
% prediction
yscal_c = 0;
for k = 1:nF
    Ttest(:,k) = X_scal*W(:,k)/(W(:,k)'*W(:,k));
    yscal_c = yscal_c + Ttest(:,k)*Q(:,k)';
    X_scal = X_scal - Ttest(:,k)*P(:,k)';
end
pred.yc = redo_scaling(yscal_c,model.settings.py);
pred.T = Ttest;
% probability
for g=1:size(pred.yc,2)
    mc(g) = model.settings.mc(g);
    sc(g) = model.settings.sc(g);
    mnc(g) = model.settings.mnc(g);
    snc(g) = model.settings.snc(g);
    for i=1:size(X,1)
        Pc = 1./(sqrt(2*pi)*sc(g)) * exp(-0.5*((pred.yc(i,g) - mc(g))/sc(g)).^2);
        Pnc = 1./(sqrt(2*pi)*snc(g)) * exp(-0.5*((pred.yc(i,g) - mnc(g))/snc(g)).^2);
        prob(i,g) = Pc/(Pc + Pnc);
    end
end
pred.prob = prob;
if strcmp(model.settings.assign_method,'max')
    [non,assigned_class] = max(prob');
else
    assigned_class = plsdafindclass(pred.yc,model.settings.thr);
end
pred.class_pred = assigned_class';
if length(model.labels.class_labels) > 0
    pred.class_pred_string = calc_class_string(pred.class_pred,model.labels.class_labels);
end
% leverages
X_scal = test_pretreatment(X,model.settings.px);
pred.H = diag(Ttest*pinv(T'*T)*Ttest');
% T hot
fvar = sqrt(1./(diag(T'*T)/(size(T,1) - 1)));
pred.Thot = sum((Ttest*diag(fvar)).^2,2);
pred.Tcont = Ttest*diag(fvar)*P';
% Qres
Xmod = Ttest*P';
Qcont = X_scal - Xmod;
for i=1:size(X,1)
    pred.Qres(i) = Qcont(i,:)*Qcont(i,:)';
end
pred.Qcont = Qcont;
