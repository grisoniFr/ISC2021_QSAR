function [tlim,qlim] = calc_qt(comp,nobj,E)

% This is an internal routine of the toolbox.
% The main routine to open the graphical interface is reg_gui
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
% D. Ballabio, G. Baccolo, V. Consonni. A MATLAB toolbox for multivariate regression. Submitted to Chemometrics and Intelligent Laboratory Systems
% 
% Regression toolbox for MATLAB
% version 1.0 - July 2020
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
epca = pca_model(E,comp,'none');
reseig = diag(epca.eigmat).^2/(nobj - 1);
m = length(reseig);
cl = 2*lev_conf*100-100;
t1 = sum(reseig(1:m,1));
t2 = sum(reseig(1:m,1).^2);
t3 = sum(reseig(1:m,1).^3);
if t1==0 
    qlim = 0;
else
    ca = sqrt(2)*erfinv(cl/100);
    h0 = 1-2*t1*t3/(3*(t2.^2)); 
    if h0<0.001; h0 = 0.001; end
    h1 = ca*sqrt(2*t2*h0.^2)/t1; h2 = t2*h0*(h0-1)/(t1.^2);
    qlim = t1*(1+h1+h2).^(1/h0);
end