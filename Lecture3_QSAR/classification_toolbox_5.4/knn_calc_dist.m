function D = knn_calc_dist(X,Xnew,dist_type)

% calculation of distances between samples of X and Xnew
% dist_type:    'euclidean' Euclidean distance
%               'mahalanobis' Mahalanobis distance
%               'cityblock' City Block metric
%               'minkowski' Minkowski metric
%               'sm' sokal-michener for binary data
%               'rt' rogers-tanimoto for binary data
%               'jt' jaccard-tanimoto for binary data
%               'gle' gleason-dice sorenson for binary data
%               'ct4' consonni todeschini for binary data
%               'ac' austin colwell for binary data
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

if strcmp(dist_type,'mahalanobis')
    inv_covX = pinv(cov(X));
end
for i=1:size(Xnew,1)
    if strcmp(dist_type,'euclidean')
        x_in = Xnew(i,:);
        D_squares_x = (sum(x_in'.^2))'*ones(1,size(X,1));
        D_squares_w = sum(X'.^2);
        D_product   = - 2*(x_in*X');
        D(i,:) = (D_squares_x + D_squares_w + D_product).^0.5; 
    else
        for j=1:size(X,1)
            x = Xnew(i,:);
            y = X(j,:);
            if strcmp(dist_type,'mahalanobis')
                D(i,j) = ((x - y)*inv_covX*(x - y)')^0.5;
            elseif strcmp(dist_type,'cityblock')
                D(i,j) = sum(abs(x - y));
            elseif strcmp(dist_type,'minkowski')
                p = 2;
                D(i,j) = (sum((abs(x - y)).^p))^(1/p);
            else
                [a,bc,d,p] = calcbinary(x,y);
                if strcmp(dist_type,'sm')
                    D(i,j)=1-((a+d)/p);
                elseif strcmp(dist_type,'rt')
                    D(i,j)=1-((a+d)/(p+bc));
                elseif strcmp(dist_type,'jt')
                    D(i,j)=1-(a/(a+bc));
                elseif strcmp(dist_type,'gle')
                    D(i,j)=1-(2*a/(2*a+bc));
                elseif strcmp(dist_type,'ct4')
                    D(i,j)=1-(log2(1+a)/log2(1+a+bc));
                elseif strcmp(dist_type,'ac')
                    D(i,j)=1-((2/pi)*asin(sqrt((a+d)/p)));
                end
            end
        end
    end
end

% ------------------------------------------------
function [a,bc,d,p] = calcbinary(x,y)
p = length(x);
s = sum([x; y]);
a = length(find(s==2));
bc = length(find(s==1));
d = length(find(s==0));