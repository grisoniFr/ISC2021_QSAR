function assigned_class = backpropagationfindclass(yc,class_thr,assignation_type,yc_scal)

% assign samples for Backpropagation Neural Networks on the basis of thresholds and calculated responses
%
% This is an internal routine of the toolbox.
% The main routine to open the graphical interface is class_gui
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

nobj = size(yc,1);
nclass = size(yc,2);
if strcmp(assignation_type,'thr')
    for i = 1:nobj
        pred = yc(i,:);
        chk_ass = zeros(1,nclass);
        for c = 1:nclass
            if pred(c) > class_thr(c); chk_ass(c) = 1; end
        end
        if length(find(chk_ass)) == 1
            assigned_class(i,1) = find(chk_ass);
        else
            assigned_class(i,1) = 0;
        end
    end
elseif strcmp(assignation_type,'max')
    [~,param] = data_pretreatment(yc_scal,'rang');
    yc_range = test_pretreatment(yc,param);
    for i = 1:nobj
        pred = yc_range(i,:);
        [a,b] = max(pred);
        assigned_class(i,1) = b;
    end
end
end