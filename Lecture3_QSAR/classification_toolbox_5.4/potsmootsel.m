function res = potsmootsel(X,class,target_class,perc,pret_type,cv_type,cv_groups,num_comp)

% selection of optimal smoothing parameter for Potential Functions (based on Gaussian kernels) by means of cross-validation
%
% res = potsmootsel(X,class,type,perc,pret_type,cv_type,cv_groups)
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
% res is a structure containing the following fields:
% er                class error rate in cross-validation, i.e. 1 - average of class specificity and sensitivity [components x 1]
% specificity       class specificity in cross-validation [components x 1]
% sensitivity       class sensitivity in cross-validation [components x 1]
% settings          settings used in optimisation
%
% RELATED ROUTINES:
% potfit            fit of Potential Functions
% potcv             cross-validation of Potential Functions
% potpred           prediction of classes of new samples with Potential Functions
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

if nargin < 8; num_comp = NaN; end
smoot_range = [0.1:0.1:1.2];
hwait = waitbar(0,'cross validating models','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(hwait,'canceling',0)
for k = 1:length(smoot_range)
    if ~ishandle(hwait)
        res.er = NaN;
        res.sensitivity = NaN;
        res.specificity = NaN;
        res.smoot_prod = NaN;
        break
    elseif getappdata(hwait,'canceling')
        res.er = NaN;
        res.sensitivity = NaN;
        res.specificity = NaN;
        res.smoot_prod = NaN;
        break
    else
        waitbar(k/length(smoot_range))
        smoot_here = smoot_range(k);
        out = potcv(X,class,target_class,smoot_here,perc,pret_type,cv_type,cv_groups,num_comp);
        res.er(k,1) = out.class_param.er;
        res.sensitivity(k,1) = out.class_param.sensitivity(1);
        res.specificity(k,1) = out.class_param.specificity(1);
    end
end
if ishandle(hwait)
    delete(hwait)
end
res.settings.smoot_range = smoot_range;
res.settings.target_class = target_class;
res.settings.perc = perc;
res.settings.pret_type = pret_type;
res.settings.cv_type = cv_type;
res.settings.cv_groups = cv_groups;
res.settings.num_comp = num_comp;
end
