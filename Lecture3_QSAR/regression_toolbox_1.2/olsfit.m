function model = olsfit(X,y)

% fit Ordinary Least Squares (OLS)
%
% model = olsfit(X,y)
%
% INPUT:            
% X                 dataset [samples x variables]
% y                 response vector [samples x 1]
%
% OUTPUT:
% model is a structure containing the following fields
% yc                calculated response [samples x 1]
% b                 regression coefficients [variables+1 x 1]
% b_std             standardised regression coefficients [variables x 1]
% r                 residuals [samples x 1]
% r_std         	standardised residuals [samples x 1]
% reg_param         structure with regression measures (RMSE, R2)
% H                 leverages [samples x 1] 
% settings          structure with model settings
% labels            structure with sample and variable labels
%    
% RELATED ROUTINES:
% olspred           prediction of new samples with OLS
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

x_reg = [ones(size(X,1),1) X];
b = inv(x_reg'*x_reg)*x_reg'*y;
yc = x_reg*b;
reg_param = calc_reg_param(y,yc);
% leverages
H = diag(x_reg*pinv(x_reg'*x_reg)*x_reg');
% standardized coefficients
for i=1:length(b)-1
    b_std(i) = b(i+1)*std(X(:,i)/std(y));
end
% residuals
r = y - yc;
nobj = length(r);
Hdiff = 1 - H;
svar = sqrt(diag(r'*(r./(Hdiff.^2)))/(nobj-1))';
r_std = r./svar(ones(nobj,1),:).*sqrt(Hdiff);
% save results
model.type = 'ols';
model.yc = yc;
model.b = b;
model.b_std = b_std';
model.r = r;
model.r_std = r_std;
model.reg_param = reg_param;
model.H = H;
model.settings.pret_type = NaN;
model.settings.raw_data = X;
model.settings.raw_y = y;
model.cv = [];
model.labels.variable_labels = {};
model.labels.sample_labels = {};
