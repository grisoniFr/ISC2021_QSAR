function [model] = pca_project(Xnew,model)

% project new samples in the PCA model
%
% model = pca_project(Xnew,model);
%
% INPUT:
% Xnew              dataset [samples x variables]
% model             PCA model calculated by means of pca_model
%
% OUTPUT
% model is a structure containing the following fields:
% Tpred             score matrix [samples x num_comp]
% Thot_pred         T2 Hotelling [1 x samples]
% Tcont_pred        T2 Hotelling contributions [samples x variables]
% Qres_pred         Q residuals [1 x samples]
% Qcont_pred        Q residuals contribution [samples x variables]
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

X_scal = test_pretreatment(Xnew,model.settings.param);
T = X_scal*model.L;
model.Tpred = T;
% hotelling T2
I = zeros(size(T,2),size(T,2)); mL = I;
for i=1:size(T,2)
    I(i,i) = model.E(i);
    mL(i,i) = 1/sqrt(model.E(i));
end
mL = mL*model.L';
for i=1:size(T,1)
    Thot(i) = T(i,:)*inv(I)*T(i,:)';
    Tcont(i,:) = T(i,:)*mL;
end
model.Thot_pred = Thot;
model.Tcont_pred = Tcont;
% Q residuals
Xmod = T*model.L';
Err = X_scal - Xmod;
for i=1:size(T,1)
    Qres(i) = Err(i,:)*Err(i,:)';
end
model.Qres_pred = Qres;
model.Qcont_pred = Err;
