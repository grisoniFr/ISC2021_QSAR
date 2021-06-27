function [tlim,qlim] = calc_qt_limits(E,comp,nobj)

% This is an internal routine for the graphical interface of the toolbox.
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
% D. Ballabio (2015), A MATLAB toolbox for Principal Component Analysis and unsupervised exploration of data structure
% Chemometrics and Intelligent Laboratory Systems, 149 Part B, 1-9
% 
% PCA toolbox for MATLAB
% version 1.4 - December 2018
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

% T2 limit
lev_conf = 0.95;
if license('test','statistics_toolbox')
    F = finv(lev_conf,comp,nobj-comp);
    tlim = comp*(nobj - 1)/(nobj - comp)*F;
else
    tlim = NaN;
end

% Q limit
t1 = sum(E(comp+1:end).^1);
t2 = sum(E(comp+1:end).^2);
t3 = sum(E(comp+1:end).^3);
ho = 1 - (2*t1*t3)/(3*t2^2);
ca = norminv(0.95, 0, 1);
term1 = (ho*ca*(2*t2)^0.5)/t1;
term2 = (t2*ho*(ho - 1))/(t1^2);
qlim = t1*(term1 + 1 + term2)^(1/ho);
