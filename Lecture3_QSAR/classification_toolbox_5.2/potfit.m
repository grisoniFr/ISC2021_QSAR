function model = potfit(X,class,type,smoot,perc,pret_type,num_comp)

% fit class modeling Potential Functions
%
% model = potfit(X,class,type,smoot,perc,pret_type)
%
% INPUT:
% X                 dataset [samples x variables]
% class             class vector, class labels can be 
%                   - numerical. The class vector is a numerical vector [samples x 1]. If G classes are present, class labels must range from 1 to G (0 values are not allowed)
%                   - strings. The class vector is a cell array containing the class labels {samples x 1}
% type              kernel type
%                   'gaus' gaussian kernel
%                   'tria' triangular kernel
% smoot             smoothing parameter [1 x classes], vector with
%                   smoothing parameters to be used for each class model
% perc              percentile to define the class boundary (e.g. 95)
%                   small percentiles gives smaller class spaces
% pret_type         data pretreatment 
%                   'none' no scaling
%                   'cent' centering
%                   'scal' variance scaling
%                   'auto' for autoscaling (centering + variance scaling)
%                   'rang' range scaling (0-1)
% OPTIONAL INPUT:
% num_comp          define the number of PCs to apply Potential Functions on Principal Components;
%                   num_comp = NaN: do not apply Potential Functions on Principal Components;
%                   num_comp = 0: autodetect PCs by taking those components with eigenvalue higher than the average eigenvalue
%                   num_comp = integer number, to define a fixed number of components to be used;
%
% OUTPUT
% model is a structure containing the following fields
% class_calc        predicted class as numerical vector [samples x 1]
% class_calc_string predicted class as string vector {samples x 1}
%                   (available only if the class input vector is a cell array with strings as class labels)
% class_param       structure with classification measures 
%                   (error rate, confusion matrix, specificity, sensitivity, precision)
% P                 sample potential for each class [samples x classes]
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
if nargin < 7; num_comp = NaN; end
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
for g=1:max(class)
    % potential function
    Xclass{g} = X_scal(find(class == g),:);
    for i=1:size(X_scal,1)
        P(i,g) = potcalc(X_scal(i,:),Xclass{g},type,smoot(g));
    end
    Pin = P(find(class == g),g);
    thr(g) = find_thr(Pin,perc);
end
class_calc = potfindclass(P,thr);
class_param = calc_class_param(class_calc,class);

model.type = 'pf';
model.P = P;
model.class_calc = class_calc;
if length(class_labels) > 0
    model.class_calc_string = calc_class_string(model.class_calc,class_labels);
end
model.class_param = class_param;
model.settings.thr = thr;
model.settings.smoot = smoot;
model.settings.type = type;
model.settings.perc = perc;
model.settings.Xclass = Xclass;
model.settings.num_comp = num_comp;
model.settings.pret_type = pret_type;
model.settings.param = param;
model.settings.model_pca = model_pca;
model.settings.raw_data = X;
model.settings.class = class;
model.cv = [];
model.labels.variable_labels = {};
model.labels.sample_labels = {};
model.labels.class_labels = class_labels;

end

% ------------------------------------------------------------------
function thr = find_thr(P,perc)
% class thresholds based on percentiles
q = perc*length(P)/100;
j = fix(q);
Ssort = -sort(-P);
thr = Ssort(j) + (q - j)*(Ssort(j+1) - Ssort(j));
end