function pred = pca_project(Xnew,model)

% projects new samples in the defined PCA score space
%
% pred = pca_project(Xnew,model);
%
% INPUT:
% Xnew              dataset [samples x variables]
% model             PCA model calculated by means of pca_model routine
%
% OUTPUT:
% pred is a structure containing the following fields:
% T                 score matrix [samples x num_comp] of the projected samples
% Thot              T2 Hotelling [1 x samples] of the projected samples
% Tcont             T2 Hotelling contributions [samples x variables] of the projected samples
% Qres              Q residuals [1 x samples] of the projected samples
% Qcont             Q residuals contribution [samples x variables] of the projected samples
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

X_in = test_pretreatment(Xnew,model.settings.param);
T = X_in*model.L;
pred.T = T;
if model.settings.dofullcalc
    % T2 hotelling
    I = zeros(size(T,2),size(T,2)); mL = I;
    for i=1:size(T,2)
        I(i,i) = model.E(i);
        mL(i,i) = 1/sqrt(model.E(i));
    end
    mL = mL*model.L';
    for i=1:size(T,1)
        Thot(i,1) = T(i,:)*inv(I)*T(i,:)';
        Tcont(i,:) = T(i,:)*mL;
    end
    pred.Thot = Thot;
    pred.Tcont = Tcont;
    % Q residuals
    Xmod = T*model.L';
    Err = X_in - Xmod;
    for i=1:size(T,1)
        Qres(i,1) = Err(i,:)*Err(i,:)';
    end
    pred.Qres = Qres;
    pred.Qcont = Err;
else
    pred.Thot = NaN;
    pred.Tcont = NaN;
    pred.Qres = NaN;
    pred.Qcont = NaN; 
end



