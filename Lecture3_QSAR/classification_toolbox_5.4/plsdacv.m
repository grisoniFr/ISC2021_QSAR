function cv = plsdacv(X,class,comp,pret_type,cv_type,cv_groups,assign_method)

% cross-validate Partial Least Squares Discriminant Analysis (PLSDA)
%
% cv = plsdacv(X,class,comp,pret_type,cv_type,cv_groups,assign_method)
%
% INPUT:
% X                 dataset [samples x variables]
% class             class vector, class labels can be 
%                   - numerical. The class vector is a numerical vector [samples x 1]. If G classes are present, class labels must range from 1 to G (0 values are not allowed)
%                   - strings. The class vector is a cell array containing the class labels {samples x 1}
% comp              number of latent variables
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
%                   'rand' for random sampling (montecarlo) with 20% of samples out
% cv_groups         number of cv groups
%                   if cv_groups == samples: leave-one-out
%                   if 'boot' or 'rand' are selected as cv_type, cv_groups sets the number of iterations
% assign_method     assignation method
%                   'bayes' samples are assigned on thresholds based on Bayes Theorem
%                   'max' samples are assigned to the class with maximum probability
%
% OUTPUT:
% cv is a structure containing the following fields:
% class_pred        predicted class as numerical vector [samples x 1]
% class_pred_string predicted class as string vector {samples x 1}
%                   (available only if the class input vector is a cell array with strings as class labels)
% rmsec             root mean squared error in cross-validation (1 x g) 
% class_param       structure with classification measures 
%                   (error rate, confusion matrix, specificity, sensitivity, precision)
% settings          cv settings
%
% RELATED ROUTINES:
% plsdafit          fit of PLSDA
% plsdapred         prediction of classes of new samples with PLSDA
% plsdacompsel      selection of the optimal number of latent variables for PLSDA
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
y = class;
x = X;
nobj=size(x,1);
if strcmp(cv_type,'boot')
    hwait = waitbar(0,'bootstrap validation');
    out_bootstrap = zeros(nobj,1);
    assigned_class = [];
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
        boot_how_many_out(i)=length(find(out == 1));
        out_bootstrap(find(out == 1)) = out_bootstrap(find(out == 1)) + 1;
        
        x_out = x(find(out == 1),:);
        y_out = y(find(out == 1));
        x_in  = x(whos_in,:);
        y_in  = y(whos_in,:);
        
        model = plsdafit(x_in,y_in,comp,pret_type,assign_method,0);
        pred = plsdapred(x_out,model);
        assigned_class = [assigned_class; pred.class_pred];
        class_true = [class_true; class(find(out == 1))];
        for g=1:size(y,2)
            rmsec(g) = NaN;
            quantitative_class(g) = NaN;
        end
    end
    class = class_true;
    assigned_class = assigned_class';
    delete(hwait);
elseif strcmp(cv_type,'rand')
    hwait = waitbar(0,'montecarlo validation');
    assigned_class = [];
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
        y_out = y(find(out == 1));
        x_in  = x(whos_in,:);
        y_in  = y(whos_in,:);
        
        model = plsdafit(x_in,y_in,comp,pret_type,assign_method,0);
        pred = plsdapred(x_out,model);
        assigned_class = [assigned_class; pred.class_pred];
        class_true = [class_true; class(find(out == 1))];
        for g=1:size(y,2)
            rmsec(g) = NaN;
            quantitative_class(g) = NaN;
        end
    end
    class = class_true;
    assigned_class = assigned_class';
    delete(hwait);
else
    quantitative_class = zeros(nobj,max(class));
    class_pred = zeros(nobj,1);
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
        model = plsdafit(x_in,y_in,comp,pret_type,assign_method,0);
        out = plsdapred(x_out,model);
        assigned_class(find(in == 0)) = out.class_pred;
        quantitative_class(find(in == 0),:) = out.yc;
    end
    for g=1:size(y,2)
        C = calc_reg_param(y(:,g),quantitative_class(:,g));
        rmsec(g) = C.RMSEC;
    end
end

class_param = calc_class_param(assigned_class',class);

cv.class_pred = assigned_class';
if length(class_labels) > 0
    cv.class_pred_string = calc_class_string(cv.class_pred,class_labels);
end
cv.class_param = class_param;
cv.yc = quantitative_class;
cv.rmsec = rmsec;
cv.settings.cv_groups = cv_groups;
cv.settings.cv_type = cv_type;
cv.settings.num_comp = comp;
cv.settings.pret_type = pret_type;