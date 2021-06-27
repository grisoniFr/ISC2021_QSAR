function model = potfit(X,class,target_class,smoot,perc,pret_type,num_comp)

% fit class modeling Potential Functions (based on Gaussian kernels)
%
% model = potfit(X,class,target_class,smoot,perc,pret_type,num_comp)
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
% smoot             smoothing parameter 
% perc              percentile to define the class boundary (e.g. 95)
%                   small percentiles gives smaller class spaces
% pret_type         data pretreatment 
%                   'none' no scaling
%                   'cent' centering
%                   'scal' variance scaling
%                   'auto' for autoscaling (centering + variance scaling)
%                   'rang' range scaling (0-1)
% OPTIONAL INPUT:
% num_comp          define the number of PCs to apply Potential Functions on Principal Components (PCA is calculated just on the target class)
%                   num_comp = NaN: do not apply Potential Functions on Principal Components;
%                   num_comp = 0: autodetect PCs by taking those components with eigenvalue higher than the average eigenvalue
%                   num_comp = integer number, to define a fixed number of components to be used;
%
% OUTPUT
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
% P                 sample potential [samples x 1]
% settings          structure with model settings
%
% RELATED ROUTINES:
% potpred           prediction of classes of new samples with Potential Functions
% potcv             cross-validatation of Potential Functions
% potsmootsel       selection of the optimal smoothing parameter for Potential Functions
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
if nargin < 7; num_comp = NaN; end
if isnan(num_comp)
    [train_scal,param] = data_pretreatment(train,pret_type);
    [test_scal] = test_pretreatment(test,param);
    model_pca = NaN;
else
    param = NaN;
    if num_comp == 0
        comphere = 10; 
    else
        comphere = num_comp; 
    end
    model_pca = pca_model(train,comphere,pret_type);
    if num_comp == 0
        compin = length(find(model_pca.E > mean(model_pca.settings.Efull)));
        model_pca = pca_model(train,compin,pret_type);
    end
    model_pca = pca_project(test,model_pca);
    train_scal = model_pca.T;
    test_scal = model_pca.Tpred;
end
% potential function
for i=1:size(train_scal,1)
    Ptrain(i,1) = potcalc(train_scal(i,:),train_scal,smoot);
end
for i=1:size(test_scal,1)
    Ptest(i,1) = potcalc(test_scal(i,:),train_scal,smoot);
end
P = zeros(size(X,1),1);
P(find(class == modelled_class),:) = Ptrain;
P(find(class ~= modelled_class),:) = Ptest;
thr = find_thr(Ptrain,perc);
model.type = 'pf';
model.P = P;
model.class_calc = potfindclass(P,thr);
if length(class_labels) > 0
    model.class_calc_string = cell(length(model.class_calc),1);
    model.class_calc_string(:) = {target_class};
    model.class_calc_string(find(model.class_calc == 0)) = class_labels(2);
end
% save results
model.class_param = calc_class_param_classmodelling(model.class_calc,class);
model.settings.thr = thr;
model.settings.smoot = smoot;
model.settings.perc = perc;
model.settings.num_comp = num_comp;
model.settings.pret_type = pret_type;
model.settings.param = param;
model.settings.model_pca = model_pca;
model.settings.Xclass = train_scal;
model.settings.raw_data = X;
model.settings.class = class_original;
model.settings.class_classmodelling = class;
model.settings.target_class = target_class;
model.cv = [];
model.labels.variable_labels = {};
model.labels.sample_labels = {};
model.labels.class_labels = class_labels_original;
model.labels.class_labels_classmodelling = class_labels;
end

% ------------------------------------------------------------------
function thr = find_thr(P,perc)
% class thresholds based on percentiles
q = perc*length(P)/100;
j = fix(q);
Ssort = -sort(-P);
thr = Ssort(j) + (q - j)*(Ssort(j+1) - Ssort(j));
end