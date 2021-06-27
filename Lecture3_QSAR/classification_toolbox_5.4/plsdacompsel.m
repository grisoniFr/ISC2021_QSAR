function res = plsdacompsel(X,class,pret_type,cv_type,cv_groups,assign_method)

% selection of the optimal number of latent variables for PLSDA by means of cross-validation
%
% res = plsdacompsel(X,class,pret_type,cv_type,cv_groups,assign_method)
%
% INPUT:
% X                 dataset [samples x variables]
% class             class vector, class labels can be 
%                   - numerical. The class vector is a numerical vector [samples x 1]. If G classes are present, class labels must range from 1 to G (0 values are not allowed)
%                   - strings. The class vector is a cell array containing the class labels {samples x 1}
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
% assign_method     assignation method
%                   'bayes' samples are assigned on thresholds based on Bayes Theorem
%                   'max' samples are assigned to the class with maximum probability
%
% OUTPUT:
% res is a structure with the following fields:
% er                error rate in cross-validation [1 x latent variables]
% ner               not-error rate in cross-validation [1 x latent variables]
% not_ass           ratio of not-assigned samples [1 x latent variables]
% settings          settings
%
% RELATED ROUTINES:
% plsdafit          fit of PLSDA
% plsdacv           cross-validatation of PLSDA
% plsdapred         prediction of classes of new samples with PLSDA
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

[n,p] = size(X);
r = min(n,p);
if r > 20
    r = 20;
end
if r > 2
    r = r - 1;
end
hwait = waitbar(0,'cross validating models','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(hwait,'canceling',0);
for k = 1:r
    if ~ishandle(hwait)
        res.er = NaN;
        res.ner = NaN;
        res.not_ass = NaN;
        break
    elseif getappdata(hwait,'canceling')
        res.er = NaN;
        res.ner = NaN;
        res.not_ass = NaN;
        break
    else
        waitbar(k/r)
        out = plsdacv(X,class,k,pret_type,cv_type,cv_groups,assign_method);
        res.er(k) = out.class_param.er;
        res.ner(k) = out.class_param.ner;
        res.not_ass(k) = out.class_param.not_ass;
    end
end
if ishandle(hwait)
    delete(hwait)
end
res.settings.pret_type = pret_type;
res.settings.cv_type = cv_type;
res.settings.cv_groups = cv_groups;
res.settings.assign_method = assign_method;