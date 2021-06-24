function X = redo_scaling(X_scal,param)

% redo scaling (from scaled data to original data)
%
% X = redo_scaling(X_scal,param)
%
% INPUT
% X_scal:   pretreated data matrix [samples x variables]
% param:    output data structure from data_pretreatment routine
%
% OUTPUT
% X:        data matrix [samples x variables]
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

a = param.a;
s = param.s;
m = param.m;
M = param.M;
pret_type = param.pret_type;
if strcmp(pret_type,'cent')
    for i=1:size(X_scal,1)
        for j=1:size(X_scal,2)
            X(i,j) = X_scal(i,j) + a(j);
        end
    end
elseif strcmp(pret_type,'scal')
    for i=1:size(X_scal,1)
        for j=1:size(X_scal,2)
            X(i,j) = X_scal(i,j)/s(j);
        end
    end
elseif strcmp(pret_type,'auto')
    for i=1:size(X_scal,1)
        for j=1:size(X_scal,2)
            X(i,j) = X_scal(i,j)*s(j) + a(j);
        end
    end
elseif strcmp(pret_type,'rang')
    for i=1:size(X_scal,1)
        for j=1:size(X_scal,2)
            X(i,j) = X_scal(i,j)*(M(j) - m(j)) + m(j);
        end
    end
else
    X = X_scal;
end
