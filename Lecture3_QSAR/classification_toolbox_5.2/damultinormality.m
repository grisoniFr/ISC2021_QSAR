function distSort = damultinormality(X)

% test for multinormality distribution based on squared generalized distance and chi-square percentiles;
% data are multinormally distributed if:
% 1. a plot of the ordered squared distances and the chi-square percentiles is nearly linear 
% 2. roughly half of the distances are less then or equal to chi-square percentile of 0.5
% REF: Applied Multivariate Statistical Analysis - Johnson,R.A.;Wichern,D.W.
% 
% distSort = damultinormality(X)
%
% INPUT:
% X                 data [samples x variables]
%
% OUTPUT:
% distSort          table [samples x 3] with:
%                   first column:  ID of samples
%                   second column: sorted squared generalized distances (from minimum to maximum)
%                   third column:  chi-square percentiles, with degree of freedom equal to the number of variables
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

[n,p] = size(X);
ave = mean(X);
S = cov(X);
for i=1:n                        
    dist(i,1) = i;
    vec = (X(i,:) - ave)';
    dist(i,2) = vec'*inv(S)*vec; % squared generalized distance
end
[sorthere,pos] = sort(dist(:,2));
distSort = dist(pos,:);
for i=1:n
    pr     = (i - 0.5)/n;
    chi(i) = chi2inv(pr,p); % calculates chi-square percentiles
end
distSort(:,3) = chi';
chiTest = chi2inv(0.5,p);        
Low = length(find(distSort(:,2) < chiTest)); % test with chi-square percentile of 0.5
percLow = Low/n;

figure
set(gcf,'color','white'); box on;
plot(distSort(:,2),distSort(:,3),'o','MarkerEdgeColor','r','MarkerSize',3,'MarkerFaceColor','w')
xlabel('squared generalized distances');
ylabel('chi-square percentiles');
M = max(max(distSort(:,2:3)));
M = M+M/10;
H=line([0 M],[0 M],'LineStyle','-','color','k');
axis([0 M 0 M])
title('test of multinormality');
str=([sprintf('%1.0f',percLow*100) '% dist < ',num2str(chiTest),' [chi-square(0.5)]']);
text(M/20,M-M/20,str);
