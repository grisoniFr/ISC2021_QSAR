function res = simcafindthr(D,class)

% find optimal thresholds for normalised Q residuals and T2 Hotelling distances
% for each class (SIMCA class modeling)
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
% version 5.2 - November 2018
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

for g=1:size(D,2)
    Dclass = D(:,g);
    class_here = 2*ones(length(class),1);
    class_here(find(class == g)) = 1;
    dspan = max(Dclass);
    dstep = dspan/100;
    cnt = 0;
    for thr=0:dstep:dspan
        cnt = cnt + 1;
        class_pred = simcafindclass(Dclass,thr);
        class_pred(find(class_pred==0)) = 2;
        cp = calc_class_param(class_pred,class_here);
        res.sp(cnt,g) = cp.specificity(1);
        res.sn(cnt,g) = cp.sensitivity(1);
        res.thr_val(cnt,g) = thr;
    end
    % find best thr where sn and sp crosses
    res.class_thr(g) = findbestthr(res.sn(:,g),res.sp(:,g),res.thr_val(:,g));
end

% -------------------------------------------------------------------
function thr = findbestthr(sn,sp,thr_val)
f = find(sn == sp);
if length(f) > 0
    % look if sn and sp are equal for a range of thr values
    % takes the intermediate
    r = round(length(f)/2);
    f = f(r);
else
    % otherwise takes first value where sn > sp
    f = find(sn > sp);
    f = f(1);
end
thr = thr_val(f);