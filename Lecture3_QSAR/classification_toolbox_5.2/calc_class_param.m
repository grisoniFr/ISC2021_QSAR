function class_param = calc_class_param(class_calc,class)

% calc_class_param calculates classification measures
%
% class_param = calc_class_param(class_calc,class);
%
% INPUT:            
% class_calc        calculated class vector [samples x 1]
% class             class vector [samples x 1], numerical vector. If G classes are present, class labels must range from 1 to G (0 values are not allowed)
%
% OUTPUT:
% class_param       structure containing confusion matrix, error rate, non-error rate, 
%                   accuracy, specificity, precision and sensitivity
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

num_class = max([max(class) max(class_calc)]);
nobj = size(class,1);

conf_mat = zeros(num_class,num_class+1);
for g = 1:num_class
    in_class = find(class==g);
    for k = 1:num_class
        conf_mat(g,k) = length(find(class_calc(in_class) == k));
    end
    conf_mat(g,num_class + 1) = length(find(class_calc(in_class) == 0));
end

% sensitivity, specificity, precision, class error, accuracy
accuracy = 0;
for g = 1:num_class
    if sum(conf_mat(:,g)) > 0
        precision(g)   = conf_mat(g,g)/sum(conf_mat(:,g));
        sensitivity(g) = conf_mat(g,g)/sum(conf_mat(g,1:num_class));
    else
        precision(g)   = 0;
        sensitivity(g) = 0;
    end
    in = ones(num_class,1); in(g) = 0;
    red_mat = conf_mat(find(in),1:num_class);
    specificity(g) = 0;
    for k = 1:size(red_mat,2)
        if k ~= g; specificity(g) = specificity(g) + sum(red_mat(:,k)); end;
    end
    if sum(sum(red_mat)) > 0
        specificity(g) = specificity(g)/sum(sum(red_mat));
    else
        specificity(g) = 0;
    end
    accuracy = accuracy + conf_mat(g,g);
end
accuracy = accuracy/sum(sum(conf_mat(:,1:num_class)));

% error rates
not_ass = sum(conf_mat(:,end))/nobj;
ner = mean(sensitivity);
er = 1 - ner;

class_param.conf_mat = conf_mat;
class_param.ner = ner;
class_param.er  = er;
class_param.accuracy  = accuracy;
class_param.not_ass = not_ass;
class_param.precision = precision;
class_param.sensitivity = sensitivity;
class_param.specificity = specificity;