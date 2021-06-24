function pred = pcrpred(X,model)

% prediction with Principal Component Regresion (PCR)
%
% pred = pcrpred(X,model)
%
% INPUT:            
% X                 dataset [samples x variables]
% model             PCR model calculated by means of pcrfit
%
% OUTPUT:
% pred is a structure containing the following fields
% yc                predicted response [samples x 1]
% H                 leverages [samples x 1]
% T                 predicted scores [samples x comp]
% Thot              T2 Hotelling [samples x 1]
% Qres              Q residuals [samples x 1]
% Tcont             T2 Hotelling contributions [samples x variables]
% Qcont             Q contributions [sampels x variables]
%    
% RELATED ROUTINES:
% pcrfit            fit PCR model
% pcrcv             cross-validatation of PCR
% pcrcompsel        selection of the optimal number of components for PCR
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

%xscal = test_pretreatment(X,model.settings.px);
%yscal_c = xscal*model.b;
%pred.yc = redo_scaling(yscal_c,model.settings.py);
pred.yc = X*model.b + model.bias;
% leverages
p = pca_project(X,model.settings.pcamodel);
Tnew = p.T;
T = model.T;
pred.T = Tnew;
if model.settings.dofullcalc
    pred.H = diag(Tnew*pinv(T'*T)*Tnew');
    % T2 hotelling
    pred.Thot = p.Thot;
    pred.Tcont = p.Tcont;
    % Q residuals
    pred.Qres = p.Qres;
    pred.Qcont = p.Qcont;
else
    pred.H = NaN;
    pred.Thot = NaN;
    pred.Tcont = NaN;
    pred.Qres = NaN;
    pred.Qcont = NaN;
end