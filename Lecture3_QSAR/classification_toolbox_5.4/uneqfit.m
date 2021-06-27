function model = uneqfit(X,class,target_class,num_comp,pret_type)

% fit UNEQ model
%
% model = uneqfit(X,class,target_class,num_comp,pret_type)
%
% INPUT:
% X                 dataset [samples x variables]
% class             class vector, class labels can be 
%                   - numerical. The class vector is a numerical vector [samples x 1]. If G classes are present, class labels must range from 1 to G (0 values are not allowed)
%                   - strings. The class vector is a cell array containing the class labels {samples x 1}
% target_class      label of the class to be modelled
%                   - numerical. When the class vector is a numerical vector, target_class is the numerical label of the class to be modelled. Then, the class labels will be
%                   trasformed into: 1 (modelled class) and 2 (all other classes)
%                   - strings. When the class vector is a cell array containing the class labels, target_class is a string with the label of the class to be modelled (e.g. 'my_class_name'). Then, the class labels will be
%                   trasformed into: 'target_class' and 'not target_class'
% comp              number of components for PCA class model
% pret_type         data pretreatment 
%                   'none' no scaling
%                   'cent' centering
%                   'scal' variance scaling
%                   'auto' for autoscaling (centering + variance scaling)
%                   'rang' range scaling (0-1)
%
% OUTPUT:
% model is a structure containing the following fields
% class_calc        predicted class (binary vector) [samples x 1]
%                   class_calc = 1: the sample is predicted in the modelled (target) class space
%                   class_calc = 0: the sample is predicted outside the modelled (target) class space
% class_calc_string predicted class as string vector {samples x 1}
%                   (available only if the class input vector is a cell array with strings as class labels)
%                   class_calc_string = 'target class': the sample is predicted in the modelled (target) class space
%                   class_calc_string = 'not target class': the sample is predicted outside the modelled (target) class space
% class_param       structure with classification measures 
%                   (error rate, confusion matrix, specificity, sensitivity, precision)
%                   Note that when the class vector is a numerical vector, the class labels will be
%                   trasformed into: 1 (modelled class) and 2 (all other classes)
% T                 scores of the PCA class model [samples x model.settings.num_comp] 
% Thot              T2 Hotelling [samples x 1]
% Thot_reduced      normalised T2 Hotelling [samples x 1]
% Tcont             T2 Hotelling contribution [samples x 1] 
% Qcont             Q residuals contribution [samples x 1] 
% tlim              T2 Hotelling confidence limit (95th percentile)
% modelpca          structure containing the class pca model
% settings          structure with model settings
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
% version 5.4 - November 2019
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

if iscell(class)
    class_string_original = class;
    [class_original,class_labels_original] = calc_class_string(class_string_original);
    [class,class_string,class_labels] = calc_class_modellinglabels(class_original,target_class,class_labels_original);
else
    class_string = {};
    class_string_original = {};
    class_labels = {};
    class_labels_original = {};
    class_original = class;
    [class] = calc_class_modellinglabels(class_original,target_class);
end
modelled_class = 1;
train = X(find(class == modelled_class),:);
test = X(find(class ~= modelled_class),:);
modelpca = pca_model(train,num_comp,pret_type);
modelpca = pca_project(test,modelpca);
num_comp_effective = size(modelpca.T,2);
% scores
T = zeros(size(modelpca.T,1),size(modelpca.T,2));
T(find(class==modelled_class),:) = modelpca.T;
T(find(class~=modelled_class),:) = modelpca.Tpred;
model.T = T;
% hotelling T2
Thot = zeros(size(X,1),1);
Thot(find(class==modelled_class),:) = modelpca.Thot';
Thot(find(class~=modelled_class),:) = modelpca.Thot_pred';
Tcont = zeros(size(X,1),size(X,2));
Tcont(find(class==modelled_class),:) = modelpca.Tcont;
Tcont(find(class~=modelled_class),:) = modelpca.Tcont_pred;
model.Thot = Thot;
model.Thot_reduced = Thot/modelpca.settings.tlim;
model.Tcont = Tcont;
model.tlim = modelpca.settings.tlim;
% Q residulas contributions
Qcont = zeros(size(X,1),size(X,2));
Qcont(find(class==modelled_class),:) = modelpca.Qcont;
Qcont(find(class~=modelled_class),:) = modelpca.Qcont_pred;
model.Qcont = Qcont;
% pca model
model.modelpca = modelpca;
% assign samples with class modelling (T2 Hotelling < thr)
resthr = simcafindthr(model.Thot_reduced,class);
model.class_calc = simcafindclass(model.Thot_reduced,resthr.class_thr);
model.settings.sp = resthr.sp;
model.settings.sn = resthr.sn;
model.settings.thr_val = resthr.thr_val';
model.settings.thr = resthr.class_thr;
if length(class_labels) > 0
    model.class_calc_string = cell(length(model.class_calc),1);
    model.class_calc_string(:) = {target_class};
    model.class_calc_string(find(model.class_calc == 0)) = class_labels(2);
end
% save results
model.type = 'uneq';
model.class_param = calc_class_param_classmodelling(model.class_calc,class);
model.settings.pret_type = pret_type;
model.settings.raw_data = X;
model.settings.class = class_original;
model.settings.class_classmodelling = class;
model.settings.target_class = target_class;
model.settings.num_comp = num_comp_effective;
model.cv = [];
model.labels.variable_labels = {};
model.labels.sample_labels = {};
model.labels.class_labels = class_labels_original;
model.labels.class_labels_classmodelling = class_labels;