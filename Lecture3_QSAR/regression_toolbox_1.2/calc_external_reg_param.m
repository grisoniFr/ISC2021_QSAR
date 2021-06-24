function res = calc_external_reg_param(y_train,y_test,y_test_calc)

% calculation of regression measures for external test set
%
% res = calc_external_reg_param(y_train,y_train_calc,y_test,y_test_calc)
%
% INPUT
% y_train:      vector of experimental responses (samples train x 1)
% y_test:       vector of experimental responses (samples test x 1)
% y_test_calc:  vector of preicted responses (samples test x 1)
% 
% OUTPUT
% res is a structure array with fields:
% R2:           percentage of explained variance
% rmsep:        Root Mean Squared Error in Prediction
%
% This is an internal routine of the toolbox.
% The main routine to open the graphical interface is reg_gui
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

n = length(y_train);
nt = length(y_test);
% standardized PRESS and TSS
TSS = sum((y_train - mean(y_train)).^2);
RSS = sum((y_test - y_test_calc).^2);
R2  = 1 - (RSS/nt)/(TSS/n);
RMSEP = (RSS/nt)^0.5;
% output
res.R2 = R2;
res.rmsep = RMSEP;
