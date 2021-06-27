function [lambda,rank] = wilks_lambda(X,class)

% ranking of variables on the basis of wilk's lambda
%
% INPUT:            
% X                 dataset [samples x variables]
% class             class vector [samples x 1].
%                   The class vector is a numerical vector. If G classes are present, class labels must range from 1 to G (0 values are not allowed)
%
% OUTPUT:
% lambda            wilk's lambda values for the ranked varaibles
% rank              variables ranked on the basis of wilk's lambda values
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

in = find(class > 0);
X = X(in,:);
[n,p] = size(X);

blocks(1:20) = 0;
for i=1:length(class)
    if class(i) > 0
        blocks(class(i)) = class(class(i)) + 1;  
    end
end

nclass = 0;
for k=1:length(blocks)
    if blocks(k) > 0
        nclass = nclass + 1;
    end    
end

for j=1:p
    X_var = X(:,j);
%    X_var = X;
    C = cov(X_var);
    W = 0;
    for k=1:nclass
        Xin = X_var(find(class==k),:);
        Cg = cov(Xin);
        W = W + Cg.*(size(Xin,1)-1);
    end
    C = C.*(size(X_var,1)-1);
    L(j) = det(W)/det(C);
    %L = det(W)/det(C); 
end

[lambda,rank] = sort(L);
