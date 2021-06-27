function model = dafit(X,class,class_prob,method,num_comp,pret_type)

% fit Discriminant Analysis (DA)
%
% model = dafit(X,class,class_prob,method)
%
% INPUT:            
% X                 dataset [samples x variables]
% class             class vector, class labels can be 
%                   - numerical. The class vector is a numerical vector [samples x 1]. If G classes are present, class labels must range from 1 to G (0 values are not allowed)
%                   - strings. The class vector is a cell array containing the class labels {samples x 1}
% class_prob        prior probability; if class_prob = 1 equal probability, if class_prob = 2 proportional probability
% method            'linear' (LDA) or 'quadratic' (QDA)
% OPTIONAL INPUT:
% num_comp          DA is calculated on the first num_comp scores calculated through Principal Component Analysis (PCA)
% pret_type         data pretreatment 
%                   'none' no scaling
%                   'cent' centering
%                   'scal' variance scaling
%                   'auto' for autoscaling (centering + variance scaling)
%                   'rang' range scaling (0-1)
%
% OUTPUT:
% model is a structure containing the following fields:
% class_calc        predicted class as numerical vector [samples x 1]
% class_calc_string predicted class as string vector {samples x 1}
%                   (available only if the class input vector is a cell array with strings as class labels)
% class_param       structure with classification measures 
%                   (error rate, confusion matrix, specificity, sensitivity, precision)
% prob              class probability [samples x classes]
% settings          structure with model settings
% L                 loadings on canonical variables [variables x classes-1], only for LDA
% Lstd              standardized loadings on canonical variables [variables x classes-1], only for LDA
% S                 scores on canonical variables [variables x classes-1], only for LDA
%
% RELATED ROUTINES:
% dapred            prediction of classes of new samples with Discriminant Analysis (DA)
% dacv              cross-validatation of Discriminant Analysis (DA)
% dacompsel         selection of the optimal number of principal components for PCA - Discriminant Analysis (PCA-DA)
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
n = size(X,1);
nclass = max(class);

if class_prob == 2
    for g = 1:nclass 
        obj_cla(g)  = length(find(class == g));
    end
    prob = obj_cla/n;
else
    prob = NaN;
end

if nargin == 6
    modelpca = pca_model(X,num_comp,pret_type);
    Xtrain = modelpca.T;
else
    Xtrain = X;
    modelpca = NaN;
    num_comp = 0;
    pret_type = 'none';
end

% if linear and not with PCs check for pooled estimate of covariance
doit = 1;
if strcmp('linear',method) & nargin < 6
    doit = pec(X,class);
end

if doit
    % fitting
    if class_prob == 1
        [class_calc,e,prob_calc] = classify(Xtrain,Xtrain,class,method);
    else
        [class_calc,e,prob_calc] = classify(Xtrain,Xtrain,class,method,prob);
    end
    % calculates canonical variables for lda
    if strcmp('linear',method)
        class_unfold = zeros(size(Xtrain,1),max(class)-1);
        for g=1:max(class)-1
            class_unfold(find(class==g),g) = 1;
        end
        [L,B,r,S,V] = canoncorr(Xtrain,class_unfold);
        for k=1:size(L,1);
            for j=1:size(L,2)
                Lstd(k,j) = L(k,j)*std(Xtrain(:,k));
            end
        end
    end
else
    class_calc = ones(size(X,1),1);
    L = zeros(size(X,2),1);
    Lstd = zeros(size(X,2),1);
    S = zeros(size(X,1),1);
end

class_param = calc_class_param(class_calc,class);
if strcmp(method,'linear')
    if num_comp > 0
        model.type = 'pcalda';
    else
        model.type = 'lda';
    end
else
    if num_comp > 0
        model.type = 'pcaqda';
    else
        model.type = 'qda';
    end
end
model.class_calc  = class_calc;
if length(class_labels) > 0
    model.class_calc_string = calc_class_string(model.class_calc,class_labels);
end
model.prob = prob_calc;
model.class_param = class_param;
if strcmp('linear',method)
    model.L = L;
    model.Lstd = Lstd;
    model.S = S;
end
model.settings.pret_type = pret_type;
model.settings.class_prob = class_prob;
model.settings.prob = prob;
model.settings.method = method;
model.settings.modelpca = modelpca;
model.settings.num_comp = num_comp;
model.settings.raw_data = X;
model.settings.class = class;
model.cv = [];
model.labels.variable_labels = {};
model.labels.sample_labels = {};
model.labels.class_labels = class_labels;

% -------------------------------------------------------------------------
function doit = pec(X,class)
for g = 1:max(class)
    gmeans(g,:) = mean(X(find(class == g),:));
end
% Pooled estimate of covariance
[Q,R] = qr(X - gmeans(class,:), 0);
R = R / sqrt(size(X,1) - max(class)); % SigmaHat = R'*R
s = svd(R);
if any(s <= eps^(3/4)*max(s))
    doit = 0;
    disp('The pooled covariance matrix of training samples must be positive definite. model not calculated');
else
    doit = 1;
end