function model = pca_model(X,num_comp,pret_type,dofullcalc)

% calculates Principal Components Analysis (PCA)
%
% model = pca_model(X,num_comp,pret_type)
%
% INPUT:
% X                 dataset [samples x variables]
% num_comp          number of principal components
% pret_type         data pretreatment 
%                   'none' no scaling
%                   'cent' centering
%                   'scal' variance scaling
%                   'auto' for autoscaling (centering + variance scaling)
%                   'rang' range scaling (0-1)
%
% OUTPUT:
% model is a structure containing the following fields:
% exp_var           explained variance [num_comp x 1]
% cum_var           cumulative explained variance [num_comp x 1]
% T                 score matrix [samples x num_comp]
% L                 loading matrix [variables x num_comp]
% E                 eigenvalues [num_comp x 1]
% Thot              T2 Hotelling [1 x samples]
% Tcont             T2 Hotelling contributions [samples x variables]
% Qres              Q residuals [1 x samples]
% Qcont             Q contributions [sampels x variables]
% settings          structure array with settings
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

if nargin < 4
    dofullcalc = 1;
end
[n,p] = size(X);
ran = min(size(X,1),size(X,2));
if num_comp > ran
    num_comp = ran;
end
[X_in,param] = data_pretreatment(X,pret_type);
[Tmat,E,L] = svd(X_in,0);     % diagonalisation
eigmat = E;
Efull = diag(E).^2/(n-1);      % eigenvalues
exp_var = Efull/sum(Efull);
E = Efull(1:num_comp);
exp_var = exp_var(1:num_comp);
for k=1:num_comp; cum_var(k) = sum(exp_var(1:k));end;
L = L(:,1:num_comp);       % loadings and scores
T = X_in*L;
if dofullcalc
    % T2 hotelling
    I = zeros(size(T,2),size(T,2)); mL = I;
    for i=1:size(T,2)
        I(i,i) = E(i);
        mL(i,i) = 1/sqrt(E(i));
    end
    mL = mL*L';
    for i=1:size(T,1)
        Thot(i,1) = T(i,:)*inv(I)*T(i,:)';
        Tcont(i,:) = T(i,:)*mL;
    end
    % Q residuals
    Xmod = T*L';
    Err = X_in - Xmod;
    for i=1:size(T,1)
        Qres(i,1) = Err(i,:)*Err(i,:)';
    end
    % T2 and Q limits
    [tlim,qlim] = calc_qt_limits(Efull,num_comp,size(X,1));
else
    Thot = NaN;
    Tcont = NaN;
    Qres = NaN;
    Err = NaN;
    tlim = NaN;
    qlim = NaN;
end
% save results
model.type = 'pca';
model.exp_var = exp_var;
model.cum_var = cum_var';
model.E = E;
model.L = L;
model.T = T;
model.eigmat = eigmat;
model.Tmat = Tmat;
model.Qres = Qres;
model.Qcont = Err;
model.Thot = Thot;
model.Tcont = Tcont;
model.settings.raw_data = X;
model.settings.tlim = tlim;
model.settings.qlim = qlim;
model.settings.num_comp = num_comp;
model.settings.param = param;
model.settings.ran = ran;
model.settings.dofullcalc = dofullcalc;
model.labels.variable_labels = {};
model.labels.sample_labels = {};
model.labels.class_labels = {};
