function cv = dacv(X,class,cv_type,cv_groups,class_prob,method,num_comp,pret_type)

% cross validation for Discriminant Analysis (DA)
%
% cv = dacv(X,class,cv_type,cv_groups,class_prob,method)
%
% INPUT:
% X                 dataset [samples x variables]
% class             class vector, class labels can be 
%                   - numerical. The class vector is a numerical vector [samples x 1]. If G classes are present, class labels must range from 1 to G (0 values are not allowed)
%                   - strings. The class vector is a cell array containing the class labels {samples x 1}
% cv_type           type of cross validation
%                   'vene' for venetian blinds'
%                   'cont' for contiguous blocks
%                   'boot' for bootstrap with resampling
%                   'rand' for random sampling (montecarlo) of 20% of samples
% cv_groups         number of cv groups
%                   if cv_groups == samples: leave-one-out
%                   if 'boot' or 'rand' are selected as cv_type, cv_groups 
%                   sets the number of iterations
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
% cv is a structure containing the following fields:
% class_pred        predicted class as numerical vector [samples x 1]
% class_pred_string predicted class as string vector {samples x 1}
%                   (available only if the class input vector is a cell array with strings as class labels)
% class_param       structure with classification measures 
%                   (error rate, confusion matrix, specificity, sensitivity, precision)
% settings          cv settings
%
% RELATED ROUTINES:
% dafit             fit Discriminant Analysis (DA)
% dapred            prediction of classes of new samples with Discriminant Analysis (DA)
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

if iscell(class)
    class_string = class;
    [class,class_labels] = calc_class_string(class_string);
else
    class_string = {};
    class_labels = {};
end
nobj = size(X,1);
if strcmp(cv_type,'boot')
    hwait = waitbar(0,'bootstrap validation');
    out_bootstrap = zeros(nobj,1);
    class_pred = [];
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
        Xext = X(find(out == 1),:);
        class_ext = class(find(out == 1));
        Xtrain  = X(whos_in,:);
        class_train  = class(whos_in);
        if nargin == 8
            model = dafit(Xtrain,class_train,class_prob,method,num_comp,pret_type);
        else
            model = dafit(Xtrain,class_train,class_prob,method);
            num_comp = 0;
            pret_type = 'none';
        end
        pred = dapred(Xext,model);
        class_pred = [class_pred; pred.class_pred];
        class_true = [class_true; class_ext];
    end
    class = class_true;
    delete(hwait);
elseif strcmp(cv_type,'rand')
    hwait = waitbar(0,'montecarlo validation');
    out_rand = zeros(nobj,1);
    perc_in = 0.8;
    take_in = round(nobj*perc_in);
    class_pred = [];
    class_true = [];
    for i=1:cv_groups
        waitbar(i/cv_groups)
        out = ones(nobj,1);
        whos_in = randperm(nobj);
        whos_in = whos_in(1:take_in);
        out(whos_in) = 0;
        % counters for left out samples
        out_rand(find(out == 1)) = out_rand(find(out == 1)) + 1;
        
        Xext = X(find(out == 1),:);
        class_ext = class(find(out == 1));
        Xtrain  = X(whos_in,:);
        class_train  = class(whos_in);
        if nargin == 8
            model = dafit(Xtrain,class_train,class_prob,method,num_comp,pret_type);
        else
            model = dafit(Xtrain,class_train,class_prob,method);
            num_comp = 0;
            pret_type = 'none';
        end
        pred = dapred(Xext,model);
        class_pred = [class_pred; pred.class_pred];
        class_true = [class_true; class_ext];
    end
    class = class_true;
    delete(hwait);
else
    class_pred = zeros(size(X,1),1);
    obj_in_block = fix(nobj/cv_groups);
    left_over = mod(nobj,cv_groups);
    st = 1;
    en = obj_in_block;
    for i = 1:cv_groups
        in = ones(size(X,1),1);
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
        Xtrain = X(find(in==1),:);
        class_train = class(find(in==1));
        Xext = X(find(in==0),:);
        if nargin == 8
            model = dafit(Xtrain,class_train,class_prob,method,num_comp,pret_type);
        else
            model = dafit(Xtrain,class_train,class_prob,method);
            num_comp = 0;
            pret_type = 'none';
        end
        pred = dapred(Xext,model);
        class_pred(find(in==0)) = pred.class_pred;
    end
end

class_param = calc_class_param(class_pred,class);
cv.class_pred = class_pred;
if length(class_labels) > 0
    cv.class_pred_string = calc_class_string(cv.class_pred,class_labels);
end
cv.class_param = class_param;
cv.settings.cv_groups = cv_groups;
cv.settings.cv_type = cv_type;
cv.settings.class_prob = class_prob;
cv.settings.method = method;
cv.settings.num_comp = num_comp;
cv.settings.pret_type = pret_type;