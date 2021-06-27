function cv = potcv(X,class,target_class,smoot,perc,pret_type,cv_type,cv_groups,num_comp)

% cross validation for class modeling Potential Functions (based on Gaussian kernels)
%
% cv = potcv(X,class,target_class,smoot,perc,pret_type,cv_type,cv_groups,num_comp)
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
% cv_type           type of cross validation
%                   'vene' for venetian blinds'
%                   'cont' for contiguous blocks
%                   'boot' for bootstrap with resampling
%                   'rand' for random sampling (montecarlo) of 20% of samples
% cv_groups         number of cv groups
%                   if cv_groups == samples: leave-one-out
%                   if 'boot' or 'rand' are selected as cv_type, cv_groups 
%                   sets the number of iterations
% OPTIONAL INPUT:
% num_comp          define the number of PCs to apply Potential Functions on Principal Components (PCA is calculated just on the target class)
%                   num_comp = NaN: do not apply Potential Functions on Principal Components;
%                   num_comp = 0: autodetect PCs by taking those components with eigenvalue higher than the average eigenvalue
%                   num_comp = integer number, to define a fixed number of components to be used;
%
% OUTPUT:
% cv is a structure containing the following fields:
% class_pred        predicted class (binary vector) [samples x 1]
%                   class_pred = 1: the sample is predicted in the modelled (target) class space
%                   class_pred = 0: the sample is predicted outside the modelled (target) class space
% class_pred_string predicted class as string vector {samples x 1}
%                   (available only if the class input vector is a cell array with strings as class labels)
%                   class_pred_string = 'target class': the sample is predicted in the modelled (target) class space
%                   class_pred_string = 'not target class': the sample is predicted outside the modelled (target) class space
% class_param       structure with classification measures 
%                   (error rate, confusion matrix, specificity, sensitivity, precision)
%                   Note that when the class vector is a numerical vector, the class labels will be
%                   trasformed into: 1 (modelled class) and 2 (all other classes)
% settings          cv settings
%
% RELATED ROUTINES:
% potfit            fit of Potential Functions
% potpred           prediction of classes of new samples with Potential Functions
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
if nargin < 9; num_comp = NaN; end
y = class;
x = X;
nobj=size(x,1);
if strcmp(cv_type,'boot')
    hwait = waitbar(0,'bootstrap validation');
    out_bootstrap = zeros(nobj,1);
    assigned_class = [];
    binary_class = [];
    class_true = [];
    for i=1:cv_groups
        waitbar(i/cv_groups)
        out = ones(nobj,1);
        whos_in = [];
        for k=1:nobj
            r = ceil(rand*nobj);
            whos_in(k) = r;
        end
        out(whos_in) = 0;
        % counters for left out samples
        out_bootstrap(find(out == 1)) = out_bootstrap(find(out == 1)) + 1;
        x_out = x(find(out == 1),:);
        x_in  = x(whos_in,:);
        y_in  = y(whos_in,:);
        y_out = y(find(out == 1),:);
        model = potfit(x_in,y_in,modelled_class,smoot,perc,pret_type,num_comp);
        pred = potpred(x_out,model);
        assigned_class = [assigned_class; pred.class_pred];
        class_true = [class_true; class(find(out == 1))];
    end
    class = class_true;
    assigned_class = assigned_class';
    delete(hwait);
elseif strcmp(cv_type,'rand')
    hwait = waitbar(0,'montecarlo validation');
    assigned_class = [];
    binary_class = [];
    out_rand = zeros(nobj,1);
    perc_in = 0.8;
    take_in = round(nobj*perc_in);
    class_true = [];
    for i=1:cv_groups
        waitbar(i/cv_groups)
        out = ones(nobj,1);
        whos_in = randperm(nobj);
        whos_in = whos_in(1:take_in);
        out(whos_in) = 0;
        % counters for left out samples
        out_rand(find(out == 1)) = out_rand(find(out == 1)) + 1;
        x_out = x(find(out == 1),:);
        x_in  = x(whos_in,:);
        y_in  = y(whos_in,:);
        y_out = y(find(out == 1),:);
        model = potfit(x_in,y_in,modelled_class,smoot,perc,pret_type,num_comp);
        pred = potpred(x_out,model);
        assigned_class = [assigned_class; pred.class_pred];
        class_true = [class_true; class(find(out == 1))];
    end
    class = class_true;
    assigned_class = assigned_class';
    delete(hwait);
else
    obj_in_block = fix(nobj/cv_groups);
    left_over = mod(nobj,cv_groups);
    st = 1;
    en = obj_in_block;
    for i = 1:cv_groups
        in = ones(size(x,1),1);
        if strcmp(cv_type,'vene') % venetian blinds
            out = [i:cv_groups:nobj];
        else % contiguous blocks
            if left_over == 0
                out = [st:en];
                st =  st + obj_in_block;  en = en + obj_in_block;
            else
                if i < cv_groups - left_over
                    out = [st:en];
                    st =  st + obj_in_block;  en = en + obj_in_block;
                elseif i < cv_groups
                    out = [st:en + 1];
                    st =  st + obj_in_block + 1;  en = en + obj_in_block + 1;
                else
                    out = [st:nobj];
                end
            end
        end
        in(out) = 0;
        x_in = x(find(in),:);
        y_in = y(find(in),:);
        x_out = x(find(in == 0),:);
        y_out = y(find(in == 0),:);
        model = potfit(x_in,y_in,modelled_class,smoot,perc,pret_type,num_comp);
        pred = potpred(x_out,model);
        assigned_class(find(in == 0)) = pred.class_pred;
    end
end
cv.class_param = calc_class_param_classmodelling(assigned_class',class);
cv.class_pred = assigned_class';
if length(class_labels) > 0
    cv.class_pred_string = cell(length(cv.class_pred),1);
    cv.class_pred_string(:) = {target_class};
    cv.class_pred_string(find(cv.class_pred == 0)) = class_labels(2);
end
cv.settings.smoot = smoot;
cv.settings.cv_groups = cv_groups;
cv.settings.cv_type = cv_type;
cv.settings.target_class = target_class;
cv.settings.num_comp = num_comp;
cv.settings.scal = pret_type;