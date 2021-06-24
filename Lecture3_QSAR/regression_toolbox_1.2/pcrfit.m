function model = pcrfit(X,y,comp,pret_type,dofullcalc)

% fit Principal Component Regresion (PCR)
%
% model = pcrfit(X,y,comp,pret_type,dofullcalc)
%
% INPUT:            
% X                 dataset [samples x variables]
% y                 response vector [samples x 1]
% comp              number of Principal Components
% pret_type         data pretreatment 
%                   'none' no scaling
%                   'cent' centering
%                   'scal' variance scaling
%                   'auto' autoscaling (centering + variance scaling)
%                   'rang' range scaling (0-1)
% OPTIONAL INPUT:
% dofullcalc        if dofullcalc = 1 (default) all figures of merit are calculated (standardized coefficients, standardized residuals, Hotelling T2, Q statistic, ...)
%                   if dofullcalc = 0 only default parameters (coefficients, regression measures) are calculated
%
% OUTPUT:
% model is a structure containing the following fields
% yc                calculated response [samples x 1]
% b                 regression coefficients [variables x 1]
% b_std             standardised regression coefficients [variables x 1]
% r                 residuals [samples x 1]
% r_std         	standardised residuals [samples x 1]
% reg_param         structure with regression measures (RMSE, R2)
% H                 leverages [samples x 1] 
% T                 scores [samples x comp] 
% P                 loadings [variables x comp] 
% E                 eigenvalues [1 x comp] 
% expvar            explained variance on X and Y [comp x 2] 
% cumvar            cumulative explained variance on X and Y [comp x 2] 
% Thot              Hotelling T2 [samples x 1]
% Qres              Q residuals [samples x 1]
% Tcont             Hotelling T2 contributions [samples x variables]
% Qcont             Q contributions [sampels x variables]
% settings          structure with model settings
% labels            structure with sample and variable labels
%    
% RELATED ROUTINES:
% pcrpred           prediction of new samples with PCR
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

if nargin < 5
    dofullcalc = 1;
end
[xscal,px] = data_pretreatment(X,pret_type);
[yscal,py] = data_pretreatment(y,pret_type);
if comp > size(X,1) || comp > size(X,2)
    comp = min([size(X,1) size(X,2)]);
end
mpca = pca_model(X,comp,pret_type,dofullcalc);
b1 = mpca.L*inv(mpca.eigmat(1:comp,1:comp))*mpca.Tmat(:,1:comp)'*yscal;
% yscal_c = xscal*b;
% yc = redo_scaling(yscal_c,py);
if strcmp(pret_type,'auto')
    for j=1:length(px.s); b(j,1) = py.s*b1(j)/px.s(j); end
    bias = py.a - px.a*b;
elseif strcmp(pret_type,'cent')
    for j=1:length(px.s); b(j,1) = b1(j); end
    bias = py.a - px.a*b;
else
    b = b1;
    bias = 0;
end
yc = X*b + bias;
reg_param = calc_reg_param(y,yc);
if dofullcalc
    % leverages
    T = mpca.T;
    H = diag(T(:,1:comp)*pinv(T(:,1:comp)'*T(:,1:comp))*T(:,1:comp)');
    % residuals
    r = y - yc;
    nobj = length(r);
    Hdiff = 1 - H;
    svar = sqrt(diag(r'*(r./(Hdiff.^2)))/(nobj-1))';
    r_std = r./svar(ones(nobj,1),:).*sqrt(Hdiff);
    % standardized coefficients
    for i=1:length(b)
        b_std(i) = b(i)*std(X(:,i)/std(y));
    end
    % T2 hotelling
    Thot = mpca.Thot;
    Tcont = mpca.Tcont;
    % Q residuals
    Qres = mpca.Qres;
    Qcont = mpca.Qcont;
    % T2 and Q limits
    tlim = mpca.settings.tlim;
    qlim = mpca.settings.qlim;
else
    H = NaN;
    r = NaN;
    r_std = NaN;
    b_std = NaN;
    Thot = NaN;
    Tcont = NaN;
    Qres =  NaN;
    Qcont = NaN;
    % T2 and Q limits
    tlim = NaN;
    qlim = NaN;
end
% save results
model.type = 'pcr';
model.yc = yc;
model.bias = bias;
model.b = b;
model.b_std = b_std';
model.r = r;
model.r_std = r_std;
model.reg_param = reg_param;
model.H = H;
model.T = mpca.T;
model.P = mpca.L;
model.E = mpca.E;
model.expvar = mpca.exp_var;
model.cumvar = mpca.cum_var;
model.Thot = Thot;
model.Qres = Qres;
model.Tcont = Tcont;
model.Qcont = Qcont;
model.settings.px = px;
model.settings.py = py;
model.settings.pret_type = pret_type;
model.settings.raw_data = X;
model.settings.raw_y = y;
model.settings.tlim = tlim;
model.settings.qlim = qlim;
model.settings.pcamodel = mpca;
model.settings.dofullcalc = dofullcalc;
model.cv = [];
model.labels.variable_labels = {};
model.labels.sample_labels = {};