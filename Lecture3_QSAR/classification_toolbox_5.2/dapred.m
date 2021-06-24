function pred = dapred(X,model)

% prediction with Discriminant Analysis (DA)
%
% pred = dapred(X,model)
%
% INPUT:            
% X                 dataset [samples x variables]
% model             model calculated by means of dafit
%
% OUTPUT:
% pred structure containing:
% prob              class probability [samples x classes] 
% class_pred        predicted class as numerical vector [samples x 1]
% class_pred_string predicted class as string vector {samples x 1}
%                   (available only if model was fitted with the class input vector as a cell array with strings as class labels)
% S                 scores on canonical variables [samples x G-1], only for LDA
% T                 scores on PCA if DA was calculate on principal components
% modelpca          structure with PCA model if DA was calculate on principal components
%                   the structure contains also statistics on the predicted
%                   samples (see pca_project for further info)
%
% RELATED ROUTINES:
% dafit             fit Discriminant Analysis (DA)
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
% version 5.2 - November 2018
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

class_prob = model.settings.class_prob;
method = model.settings.method;
Xtrain = model.settings.raw_data;
num_comp = model.settings.num_comp;
class_train = model.settings.class;
prob = model.settings.prob;

if num_comp > 0
    modelpca = pca_project(X,model.settings.modelpca);
    Xin = modelpca.Tpred;
    Xtrain = modelpca.T;
else
    Xin = X;
end

% prediction
if class_prob == 1
    [class_pred,e,prob_pred] = classify(Xin,Xtrain,class_train,method);
else
    [class_pred,e,prob_pred] = classify(Xin,Xtrain,class_train,method,prob);
end
% prediction of scores on canonical variables only for lda
if strcmp('linear',method)
    [a,param] = data_pretreatment(Xtrain,'cent');
    Xin_cent = test_pretreatment(Xin,param);
    pred.S = Xin_cent*model.L;
end
pred.class_pred = class_pred;
if length(model.labels.class_labels) > 0
    pred.class_pred_string = calc_class_string(pred.class_pred,model.labels.class_labels);
end
pred.prob = prob_pred;
if num_comp > 0
    pred.T = modelpca.Tpred;
    pred.modelpca = modelpca;
end
