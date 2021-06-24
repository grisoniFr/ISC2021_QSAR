function cv = svmcv(X,class,kernel,C,kernelpar,pret_type,cv_type,cv_groups,num_comp)

% cross-validation for Support Vector Machines (only two classes allowed)
%
% cv = svmcv(X,class,kernel,C,kernelpar,pret_type,cv_type,cv_groups)
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
%                   'cent' centering
%                   'scal' variance scaling
%                   'auto' for autoscaling (centering + variance scaling)
%                   'rang' range scaling (0-1)
%                   'none' no scaling
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
% num_comp          define the number of PCs to apply svm on Principal Components;
%                   num_comp = NaN: do not apply svm on Principal Components;
%                   num_comp = 0: autodetect PCs by taking those components with eigenvalue higher than the average eigenvalue
%                   num_comp = integer number, to define a fixed number of components to be used;
%
% OUTPUT:
% cv is a structure containing the following fields:
% class_pred        predicted class as numerical vector [samples x 1]
% class_pred_string predicted class as string vector {samples x 1}
%                   (available only if the class input vector is a cell array with strings as class labels)
% class_param       structure with classification measures 
%                   (error rate, confusion matrix, specificity, sensitivity, precision)
% average_svind     average number of support vectors;
% settings          cv settings
%
% SVM are based on the MATLAB toolbox, further info:
% http://it.mathworks.com/help/stats/support-vector-machines-svm.html
%
% RELATED ROUTINES:
% svmfit            fit of SVM
% svmpred           prediction of classes of new samples with SVM
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
if nargin < 9; num_comp = NaN; end
nobj = size(X,1);
if strcmp(cv_type,'boot')
    hwait = waitbar(0,'bootstrap validation');
    svind = zeros(cv_groups,1);
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
        
        model = svmfit(Xtrain,class_train,kernel,C,kernelpar,pret_type,num_comp);
        pred = svmpred(Xext,model);
        class_pred = [class_pred; pred.class_pred];
        class_true = [class_true; class_ext];
        svind(i) = length(model.svind);
    end
    class = class_true;
    delete(hwait);
elseif strcmp(cv_type,'rand')
    hwait = waitbar(0,'montecarlo validation');
    svind = zeros(cv_groups,1);
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
        
        model = svmfit(Xtrain,class_train,kernel,C,kernelpar,pret_type,num_comp);
        pred = svmpred(Xext,model);
        class_pred = [class_pred; pred.class_pred];
        class_true = [class_true; class_ext];
        svind(i) = length(model.svind);
    end
    class = class_true;
    delete(hwait);
else
    svind = zeros(cv_groups,1);
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
        model = svmfit(Xtrain,class_train,kernel,C,kernelpar,pret_type,num_comp);
        pred = svmpred(Xext,model);
        class_pred(find(in==0)) = pred.class_pred;
        svind(i) = length(model.svind);
    end
end

class_param = calc_class_param(class_pred,class);
cv.class_pred = class_pred;
if length(class_labels) > 0
    cv.class_pred_string = calc_class_string(cv.class_pred,class_labels);
end
cv.average_svind = mean(svind);
cv.class_param = class_param;
cv.settings.cv_groups = cv_groups;
cv.settings.cv_type = cv_type;
cv.settings.kernel = kernel;
cv.settings.C = C;
cv.settings.kernelpar = kernelpar;
cv.settings.pret_type = pret_type;
cv.settings.num_comp = num_comp;