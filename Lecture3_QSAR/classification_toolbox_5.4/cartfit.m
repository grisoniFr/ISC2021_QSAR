function model = cartfit(X,class,var_labels)

% fit Classifcation Trees (CART)
%
% model = cartfit(X,class)
%
% INPUT:            
% X                 dataset [samples x variables]
% class             class vector, class labels can be 
%                   - numerical. The class vector is a numerical vector [samples x 1]. If G classes are present, class labels must range from 1 to G (0 values are not allowed)
%                   - strings. The class vector is a cell array containing the class labels {samples x 1}
% OPTIONAL INPUT:
% var_labels        cell array with variables labels [1 x variables]
% 
% OUTPUT:
% model is a structure containing the following fields:
% tree              structure containing the classification tree 
% class_calc        predicted class as numerical vector [samples x 1]
% class_calc_string predicted class as string vector {samples x 1}
%                   (available only if the class input vector is a cell array with strings as class labels)
% class_param       structure with classification measures 
%                   (error rate, confusion matrix, specificity, sensitivity, precision)
%
% RELATED ROUTINES:
% cartpred          prediction of classes of new samples with CART
% cartcv            cross-validatation of CART
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
    class_string = class;
    [class,class_labels] = calc_class_string(class_string);
else
    class_string = {};
    class_labels = {};
end
if nargin < 3
    for j=1:size(X,2); var_labels{j}=['var ' num2str(j)]; end
end
t = fitctree(X,class,'PredictorNames',var_labels);
m = max(t.PruneList) - 1;
[~,~,~,best] = cvloss(t,'SubTrees',0:m,'KFold',10);
class_tree = prune(t,'Level',best);
class_calc = predict(class_tree,X);
class_param = calc_class_param(class_calc,class);

model.type = 'cart';
model.tree = class_tree;
model.class_calc = class_calc;
if length(class_labels) > 0
    model.class_calc_string = calc_class_string(model.class_calc,class_labels);
end
model.class_param = class_param;
model.settings.raw_data = X;
model.settings.class = class;
model.settings.class_string = class_string;
model.cv = [];
model.labels.variable_labels = {};
model.labels.sample_labels = {};
model.labels.class_labels = class_labels;
