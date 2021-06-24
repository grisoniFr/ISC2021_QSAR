function model = uneqfit(X,class,num_comp,pret_type,assign_method)

% fit UNEQ model
%
% model = uneqfit(X,class,num_comp,pret_type,assign_method)
%
% INPUT:
% X                 dataset [samples x variables]
% class             class vector, class labels can be 
%                   - numerical. The class vector is a numerical vector [samples x 1]. If G classes are present, class labels must range from 1 to G (0 values are not allowed)
%                   - strings. The class vector is a cell array containing the class labels {samples x 1}
% comp              number of components for each class model [1 x classes]
% pret_type         data pretreatment 
%                   'none' no scaling
%                   'cent' centering
%                   'scal' variance scaling
%                   'auto' for autoscaling (centering + variance scaling)
%                   'rang' range scaling (0-1)
% assign_method     assignation method
%                   'class modeling', samples are assigned to class(es) with normalised T2 Hotelling lower than a class threshold. T2 Hotelling are normalised over their 95% confidence limits. 
%                   Samples can be predicted in none or multiple classes. Threshold is found for each class by maximizing specificity and sensitivity
%                   'distance', samples are always assigned to the closest class, i.e. the class with the lowest normalised T2 Hotelling. T2 Hotelling are normalised over their 95% confidence limits.
%
% OUTPUT:
% model is a structure containing the following fields
% class_calc        predicted class as numerical vector [samples x 1]
% binary_assignation binary prediction in the class spaces [samples x classes]
%                   1: the sample is predicted in the class space; 
%                   0: the sample is predicted outside the class space;
% class_calc_string predicted class as string vector {samples x 1}
%                   (available only if the class input vector is a cell array with strings as class labels)
% class_param       structure with classification measures 
%                   (error rate, confusion matrix, specificity, sensitivity, precision)
% T                 structure with scores for each class model [samples x classes] 
% Thot              matrix with T2 Hotelling for each class model [samples x classes] 
% Thot_reduced      matrix with normalised T2 Hotelling for each class model [samples x classes]
% Tcont             structure with T2 Hotelling contribution for each class model [samples x classes] 
% Qcont             structure with Q residuals contribution for each class model [samples x classes] 
% tlim              T2 Hotelling confidence limit (95th percentile) for each class model [classes x 1]
% modelpca          structure containing the class pca models for each class [classes x 1]
% settings          structure with model settings
% settings.thr      when using 'class modeling' as assign_method, this field contains the normalised T2 Hotelling threshold used for each class
%
% RELATED ROUTINES:
% uneqpred          prediction of classes of new samples with UNEQ
% uneqcv            cross-validatation of UNEQ
% uneqcompsel       selection of the optimal number of components for UNEQ
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
% version 5.2 - November 2018
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

if iscell(class)
    class_string = class;
    [class,class_labels] = calc_class_string(class_string);
else
    class_string = {};
    class_labels = {};
end
for g=1:max(class)
    train = X(find(class==g),:);
    test = X(find(class~=g),:);
    modelpca = pca_model(train,num_comp(g),pret_type);
    modelpca = pca_project(test,modelpca);
    num_comp_effective(g) = size(modelpca.T,2);
    % scores
    T = zeros(size(modelpca.T,1),size(modelpca.T,2));
    T(find(class==g),:) = modelpca.T;
    T(find(class~=g),:) = modelpca.Tpred;
    model.T{g} = T;
    % hotelling T2
    Thot = zeros(size(X,1),1);
    Thot(find(class==g),:) = modelpca.Thot';
    Thot(find(class~=g),:) = modelpca.Thot_pred';
    Tcont = zeros(size(X,1),size(X,2));
    Tcont(find(class==g),:) = modelpca.Tcont;
    Tcont(find(class~=g),:) = modelpca.Tcont_pred;
    model.Thot(:,g) = Thot;
    model.Thot_reduced(:,g) = Thot/modelpca.settings.tlim;
    model.Tcont{g} = Tcont;
    model.tlim(g) = modelpca.settings.tlim;
    % Q residulas contributions
    Qcont = zeros(size(X,1),size(X,2));
    Qcont(find(class==g),:) = modelpca.Qcont;
    Qcont(find(class~=g),:) = modelpca.Qcont_pred;
    model.Qcont{g} = Qcont;
    % pca model
    model.modelpca{g} = modelpca;
end

% calculate distance and always assign samples
for i=1:size(X,1)
    [v,c] = min(model.Thot_reduced(i,:));
    class_calc_dist(i,1) = c;
end

if strcmp(assign_method,'distance')
    model.class_calc = class_calc_dist;
    model.settings.sp(1:max(class)) = NaN;
    model.settings.sn(1:max(class)) = NaN;
    model.settings.thr(1:max(class)) = NaN;
    model.settings.thr_val(1:max(class)) = NaN;
else
    % assign samples with class modelling (T2 Hotelling < thr)
    resthr = simcafindthr(model.Thot_reduced,class);
    [model.class_calc, model.binary_assignation] = simcafindclass(model.Thot_reduced,resthr.class_thr);
    model.settings.sp = resthr.sp;
    model.settings.sn = resthr.sn;
    model.settings.thr_val = resthr.thr_val';
    model.settings.thr = resthr.class_thr;
end
if length(class_labels) > 0
    model.class_calc_string = calc_class_string(model.class_calc,class_labels);
end
class_param = calc_class_param(model.class_calc,class);
% save results
model.type = 'uneq';
model.class_param = class_param;
model.settings.pret_type = pret_type;
model.settings.assign_method = assign_method;
model.settings.raw_data = X;
model.settings.class = class;
model.settings.num_comp = num_comp_effective;
model.cv = [];
model.labels.variable_labels = {};
model.labels.sample_labels = {};
model.labels.class_labels = class_labels;