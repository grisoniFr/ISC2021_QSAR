function pred = olspred(X,model)

% prediction with Ordinary Least Squares (OLS)
%
% pred = olspred(X,model)
%
% INPUT:            
% X                 dataset [samples x variables]
% model             OLS model calculated by means of olsfit
%
% OUTPUT:
% pred is a structure containing the following fields
% yc                predicted response [samples x 1]
% H                 leverages [samples x 1]
%    
% RELATED ROUTINES:
% olsfit            fit OLS model
% olscv             cross-validatation of OLS
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

X = [ones(size(X,1),1) X];
pred.yc = X*model.b;
% leverages
xtrain = [ones(size(model.settings.raw_data,1),1) model.settings.raw_data];
pred.H = diag(X*pinv(xtrain'*xtrain)*X');
