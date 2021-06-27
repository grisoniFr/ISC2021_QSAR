function model = plsdafit(X,class,comp,pret_type,assign_method,doqtlimit)

% fit Partial Least Squares Discriminant Analysis (PLSDA)
%
% model = plsdafit(X,class,comp,pret_type,assign_method)
%
% INPUT:            
% X                 dataset [samples x variables]
% class             class vector, class labels can be 
%                   - numerical. The class vector is a numerical vector [samples x 1]. If G classes are present, class labels must range from 1 to G (0 values are not allowed)
%                   - strings. The class vector is a cell array containing the class labels {samples x 1}
% comp              number of latent variables
% pret_type         data pretreatment 
%                   'none' no scaling
%                   'cent' centering
%                   'scal' variance scaling
%                   'auto' for autoscaling (centering + variance scaling)
%                   'rang' range scaling (0-1)
% assign_method     assignation method
%                   'bayes' samples are assigned on thresholds based on Bayes Theorem
%                   'max' samples are assigned to the class with maximum yc
% OPTIONAL INPUT:
% doqtlimit         if doqtlimit = 1 calculates Hotelling T2 and Q limits
%                   if doqtlimit = 0, does not calculates Hotelling T2 and Q limits
%
% OUTPUT:
% model is a structure containing the following fields
% yc                calculated response [samples x classes]
% prob              class probability [samples x classes] 
% class_calc        predicted class as numerical vector [samples x 1]
% class_calc_string predicted class as string vector {samples x 1}
%                   (available only if the class input vector is a cell array with strings as class labels)
% class_param       structure with classification measures 
%                   (error rate, confusion matrix, specificity, sensitivity, precision)
% T                 X scores [samples x comp] 
% P                 X loadings [variables x comp] 
% W                 X weights [classes x comp] 
% U                 Y scores [samples x comp] 
% Q                 Y weights [variables x comp] 
% b                 regression coefficients [variables x 1]
% expvar            explained variance on X and Y [comp x 2] 
% cumvar            cumulative explained variance on X and Y [comp x 2] 
% rmsec             root mean squared error [classes x 1] 
% H                 leverages [samples x 1] 
% Thot              Hotelling T2 [samples x 1]
% Qres              Q residuals [samples x 1]
% Tcont             Hotelling T2 contributions [samples x variables]
% Qcont             Q contributions [sampels x variables]
% settings          structure with model settings
% labels            structure with sample, variable and class labels
%
% based on Frans Van Den Berg mypls routine
% http://www.models.kvl.dk/
%
% RELATED ROUTINES:
% plsdapred         prediction of classes of new samples with PLSDA
% plsdacv           cross-validatation of PLSDA
% plsdacompsel      selection of the optimal number of latent variables for PLSDA
% class_gui         main routine to open the graphical interface
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

if nargin < 6
    doqtlimit = 0;
end
if iscell(class)
    class_string = class;
    [class,class_labels] = calc_class_string(class_string);
else
    class_string = {};
    class_labels = {};
end
% unfold classes
y = zeros(size(X,1),max(class));
for g=1:max(class)
    y(find(class==g),g) = 1;
end
% data scaling
[X_scal,px] = data_pretreatment(X,pret_type);
[y_scal,py] = data_pretreatment(y,'none');
% pls2
[T,P,W,U,Q,B,ssq,Ro,Rv,Lo,Lv] = mypls(X_scal,y_scal,comp);
yscal_c = T*Q';
Lo = Lo(:,comp);
yc = redo_scaling(yscal_c,py);
cumvar = ssq;
expvar(1,:) = cumvar(1,:);
for k = 2:comp; expvar(k,:) = cumvar(k,:) - cumvar(k - 1,:); end
% coefficients
b = W(:,1:comp)*inv(P(:,1:comp)'*W(:,1:comp))*Q(:,1:comp)';
% T hot
fvar = sqrt(1./(diag(T'*T)/(size(X,1) - 1)));
Thot = sum((T*diag(fvar)).^2,2);
Tcont = (T*diag(fvar)*P');
% Qres
Xmod = T*P';
Qcont = X_scal - Xmod;
for i=1:size(T,1)
    Qres(i) = Qcont(i,:)*Qcont(i,:)';
end
% rmsec
for g=1:size(y,2)
    res = calc_reg_param(y(:,g),yc(:,g));
    rmsec(g) = res.RMSEC;
end
% T2 and Q limits
if doqtlimit
    mlim = pca_model(X,comp,pret_type);
    tlim = mlim.settings.tlim;
    qlim = mlim.settings.qlim;
else
    tlim = NaN;
    qlim = NaN;
end
% class probabilities, Chemometrics and Intelligent Laboratory Systems 95 (2013) 122-128.
for g=1:max(class)
    mc(g) = mean(yc(find(class==g),g));
    sc(g) = std(yc(find(class==g),g));
    mnc(g) = mean(yc(find(class~=g),g));
    snc(g) = std(yc(find(class~=g),g));
    for i=1:size(X,1)
        Pc = 1./(sqrt(2*pi)*sc(g)) * exp(-0.5*((yc(i,g) - mc(g))/sc(g)).^2);
        Pnc = 1./(sqrt(2*pi)*snc(g)) * exp(-0.5*((yc(i,g) - mnc(g))/snc(g)).^2);
        prob(i,g) = Pc/(Pc + Pnc);
    end
end
% class evaluation
[tmp,class_true] = max(y');
resthr = plsdafindthr(yc,class_true');
if strcmp(assign_method,'max')
    % assigns on the maximum calculated response
    [non,assigned_class] = max(prob');
else
    % assigns on the bayesian discrimination threshold
    assigned_class = plsdafindclass(yc,resthr.class_thr);
end
class_param = calc_class_param(assigned_class',class_true');
model.type = 'plsda';
model.yc = yc;
model.prob = prob;
model.class_calc = assigned_class';
if length(class_labels) > 0
    model.class_calc_string = calc_class_string(model.class_calc,class_labels);
end
model.class_param = class_param;
model.T = T;
model.P = P;
model.U = U;
model.Q = Q;
model.W = W;
model.b = b;
model.cumvar = cumvar;
model.expvar = expvar;
model.rmsec = rmsec;
model.H = Lo;
model.Thot = Thot;
model.Tcont = Tcont;
model.Qres = Qres;
model.Qcont = Qcont;
model.settings.pret_type = pret_type;
model.settings.px = px;
model.settings.py = py;
model.settings.y = y;
model.settings.tlim = tlim;
model.settings.qlim = qlim;
model.settings.thr_val = resthr.thr_val';
model.settings.sp = resthr.sp;
model.settings.sn = resthr.sn;
model.settings.thr = resthr.class_thr;
model.settings.assign_method = assign_method;
model.settings.raw_data = X;
model.settings.class = class;
model.settings.class_string = class_string;
model.settings.mc = mc;
model.settings.sc = sc;
model.settings.mnc = mnc;
model.settings.snc = snc;
model.cv = [];
model.labels.variable_labels = {};
model.labels.sample_labels = {};
model.labels.class_labels = class_labels;
