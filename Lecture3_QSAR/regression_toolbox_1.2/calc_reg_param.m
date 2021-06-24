function [res,RSS] = calc_reg_param(y_exp,y_calc)

% calculation of regression measures
%
% [res,RSS] = calc_reg_param(y_exp,y_calc)
%
% INPUT
% y_exp:        vector of experimental responses [samples x 1]
% y_calc:       vector of calculated responses [samples x 1]
% 
% OUTPUT
% res is a structure array with the following fields:
% R2:           percentage of explained variance
% rmse:         Root Mean Squared Error of Calibration
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

n = length(y_exp);
% TSS, Total Sum of Squares
TSS = sum((y_exp - mean(y_exp)).^2);
% RSS, Residual Sum of Squares
RSS = sum((y_exp - y_calc).^2);
% R2, percentage of explained variance
R2 = 1 - RSS/TSS;
% RMSEC, Root Mean Squared Error of Calibration
% also called SDEC, Standard Deviation Error in Calibration
rmse = (RSS/n)^0.5;
res.R2 = R2;
res.rmse = rmse;