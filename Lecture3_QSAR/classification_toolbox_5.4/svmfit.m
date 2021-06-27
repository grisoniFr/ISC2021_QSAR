function model = svmfit(X,class,kernel,C,kernelpar,pret_type,num_comp)

% fit Support Vector Machines (only two classes allowed)
%
% model = svmfit(X,class,kernel,C,kernelpar,pret_type)
%
% INPUT:
% X                 dataset [samples x variables]
% class             class vector, class labels can be 
%                   - numerical. The class vector is a numerical vector [samples x 1]. If G classes are present, class labels must range from 1 to G (0 values are not allowed)
%                   - strings. The class vector is a cell array containing the class labels {samples x 1}
% kernel            type of kernel: 'linear' , 'polynomial', 'rbf'
% C                 upper bound for the coefficients alpha during training (cost)
% kernelpar         parameter for rbf and poly kernels, suggested in the range [0.01 10];
%                   for linear kernel, kernelpar can be set to []
% pret_type         data pretreatment 
%                   'none' no scaling
%                   'cent' centering
%                   'scal' variance scaling
%                   'auto' for autoscaling (centering + variance scaling)
%                   'rang' range scaling (0-1)
% OPTIONAL INPUT:
% num_comp          define the number of PCs to apply svm on Principal Components;
%                   num_comp = NaN: do not apply svm on Principal Components;
%                   num_comp = 0: autodetect PCs by taking those components with eigenvalue higher than the average eigenvalue
%                   num_comp = integer number, to define a fixed number of components to be used;
%
% OUTPUT:
% model is a structure containing the following fields
% class_calc        predicted class as numerical vector [samples x 1]
% class_calc_string predicted class as string vector {samples x 1}
%                   (available only if the class input vector is a cell array with strings as class labels)
% class_param       structure with classification measures 
%                   (error rate, confusion matrix, specificity, sensitivity, precision)
% prob              class probability [samples x classes] 
% dist              distance from class boundary [samples x 1]
% svind             id of support vectors [sv x 1]
% alpha             alpha values [samples x 1]; 
%                   support vectors have alpha > 0
%                   suppor vectors on margin have alpha less than cost
% bias              model bias
% b                 linear coefficients [1 x variables], only for 'linear' kernel
% settings          structure with model settings
%
% SVM are based on the MATLAB toolbox, further info:
% http://it.mathworks.com/help/stats/support-vector-machines-svm.html
%
% RELATED ROUTINES:
% svmpred           prediction of classes of new samples with SVM
% svmcv             cross-validatation of SVM
% svmcostsel        selection of the optimal cost and kernel parameter for SVM
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
if nargin < 7; num_comp = NaN; end
if max(class) > 2
    disp('more than two classes detected, but only two classes allowed! model wont be calculated')
    model = NaN;
    return;
end
class(find(class == 2)) = -1;
tol = 1e-2;
% pretreat data
if isnan(num_comp)
    [X_scal,param] = data_pretreatment(X,pret_type);
    model_pca = NaN;
else
    param = NaN;
    if num_comp == 0
        comphere = 10; 
    else
        comphere = num_comp; 
    end
    model_pca = pca_model(X,comphere,pret_type);
    if num_comp == 0
        compin = length(find(model_pca.E > mean(model_pca.settings.Efull)));
        model_pca = pca_model(X,compin,pret_type);
    end
    X_scal = model_pca.T;
end

net = fitcsvm(X_scal,class,'KernelFunction',kernel,'KernelScale',kernelpar,'BoxConstraint',C);
[~,dist] = predict(net,X_scal);
dist = dist(:,2);
net_scores = fitPosterior(net,X_scal,class);
[~,prob] = predict(net_scores,X_scal);
prob = prob(:,[2 1]);
alpha = zeros(size(X,1),1);
alpha(find(net.IsSupportVector)) = net.Alpha;
% class prediction
class_calc = sign(dist);
class(find(class == -1)) = 2;
class_calc(find(class_calc == -1)) = 2;
class_param = calc_class_param(class_calc,class);
% store linear coefficents and bias
model.type = 'svm';
model.alpha = alpha;
model.svind = find(net.IsSupportVector);
model.b = net.Beta;
model.bias = net.Bias;
model.dist = dist;
model.prob = prob;
model.class_calc = class_calc;
if length(class_labels) > 0
    model.class_calc_string = calc_class_string(model.class_calc,class_labels);
end
model.class_param = class_param;
model.settings.net = net;
model.settings.net_scores = net_scores;
model.settings.param = param;
model.settings.pret_type = pret_type;
model.settings.C = C;
model.settings.kernel = kernel;
model.settings.kernelpar = kernelpar;
model.settings.svind_data_scaled = X_scal(model.svind,:);
model.settings.svind_data = X(model.svind,:);
model.settings.data_scaled = X_scal;
model.settings.num_comp = num_comp;
model.settings.model_pca = model_pca;
model.settings.raw_data = X;
model.settings.class = class;
model.cv = [];
model.labels.variable_labels = {};
model.labels.sample_labels = {};
model.labels.class_labels = class_labels;