function pred = backpropagationpred(X,model)

% prediction with Backpropagation Neural Networks (BPNN)
%
% pred = backpropagationpred(X,model)
%
% INPUT:            
% X                 dataset [samples x variables]
% model             model calculated by means of backpropagationfit
%
% OUTPUT:
% pred structure containing:
% output_pred       predicted output [samples x classes]
% class_pred        predicted class as numerical vector [samples x 1]
% class_pred_string predicted class as string vector {samples x 1}
%                   (available only if model was fitted with the class input vector as a cell array with strings as class labels)
%
% RELATED ROUTINES:
% backpropagationfit        fit Backpropagation Neural Networks (BPNN)
% backpropagationcv         cross-validatation of Backpropagation Neural Networks (BPNN)
% backpropagationsettings   define netwrok settings
% class_gui                 main routine to open the graphical interface
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

%STEP 1 : Normalize the Input
[X_scal] = test_pretreatment(X,model.settings.param);
X_scal = [X_scal ones(size(X,1),1)];
output_pred = backpropagationproject(X_scal,model.W);
class_pred = backpropagationfindclass(output_pred{end},model.settings.thr,model.settings.network_settings.assignation_type,model.output_pred);
pred.output_pred = output_pred{end};
pred.class_pred = class_pred;
if length(model.labels.class_labels) > 0
    pred.class_pred_string = calc_class_string(pred.class_pred,model.labels.class_labels);
end
end
