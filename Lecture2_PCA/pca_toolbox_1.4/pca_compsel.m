function res = pca_compsel(X,pret_type,cv_type,cv_groups)

% calculates criteria (based on eigenvalues and cross validation)
% for the selection of the optimal number of components for PCA
%
% res = pca_compsel(X,pret_type,cv_type,cv_groups)
%
% INPUT:
% X                 dataset [samples x variables]
% pret_type         data pretreatment 
%                   'none' no scaling
%                   'cent' centering
%                   'scal' variance scaling
%                   'auto' for autoscaling (centering + variance scaling)
%                   'rang' range scaling (0-1)
% cv_type           type of cross validation
%                   'vene' for venetian blinds'
%                   'cont' for contiguous blocks
% cv_groups         number of cv groups
%                   if cv_groups == samples: leave-one-out
%
% OUTPUT:
% res is a structure containing the following fields:
% rmsecv:           root mean squared error (residuals) in cross validation [1 x components]
% KL:               number of optimal components based on K correlation index linear function 
% KP:               number of optimal components based on K correlation index non-linear power function 
% AEC:              number of optimal components based on average eigenvalue criterion 
% CAEC:             number of optimal components based on corrected average eigenvalue criterion 
% IE:               Imbedded error [1 x components] 
% IND:              Malinowski Indicator Function [1 x components]
%
% References to the criteria for the component selection:
% rmsecv: R. Bro, K. Kjeldahl, A. K. Smilde, H. A. L. Kiers, 2008, Cross-validation of component models: A critical look at current methods, Anal Bioanal Chem 390, pp 1241–1251 
%         Wise B, Ricker N (1991) In: Najim K, Dufour E (eds) IFAC Symp on Advanced Control of Chemical Processes, Toulouse, France, 14–16 October 1991, pp 125–130
% AEC, CAEC: Kaiser,H.F., 1960. The application of electronic computers to factor analysis, Educational and Psychological Measurement 20, pp. 141-151.
% KL, KP: Todeschini,R., 1997. Data correlation, number of significant principal components and shape of molecules. The K correlation index, Anal. Chim. Acta 348, pp. 419-430
% IE and IND: Malinowski, E. R.; Howery, D. G. (1980). Factor Analysis in Chemistry. New York: Wiley.
%
% RELATED ROUTINES:
% pca_model         calculates Principal Component Analysis (PCA)
% pca_project       project new samples in a PCA model
% mds_model         calculates Multidimensional Scaling (MDS)
% cluster_model     calculates hierarchical cluster analysis
% pca_gui           main routine to open the graphical interface 
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

[n,p] = size(X);
model = pca_model(X,p,pret_type);
if strcmp(pret_type,'auto')
    AEC = length(find(model.E >= 1));
    CAEC = length(find(model.E >= 0.7));
else
    AEC = length(find(model.E >= mean(model.E)));
    CAEC = length(find(model.E >= 0.7*mean(model.E)));    
end
K = k_index(model.E);
KLtmp = (1 + (p-1)*(1-K));
KL = round(KLtmp);
KPtmp = p^(1-K);
KP = round(KPtmp);
for k=1:length(model.E)
    IE(k) = ((k/(n*p))*(sum(model.E(k+1:end))/(p - k)))^0.5;
    IND(k) = ((sum(model.E(k+1:end))/(n*(p - k)))^0.5)/(p - k)^2;
end
if model.settings.ran > 20
    maxcomp = 20;
else
    maxcomp = model.settings.ran;
end
cv = pcacv(X,maxcomp,cv_type,cv_groups,pret_type);
res.rmsecv = cv.rmsecv;
res.KL = KL;
res.KP = KP;
res.AEC = AEC;
res.CAEC = CAEC;
res.IE = IE;
res.IND = IND;
res.settings.cv_groups = cv_groups;
res.settings.cv_type = cv_type;
res.settings.pret_type = pret_type;
res.settings.E = model.E;
res.settings.exp_var = model.exp_var;
res.settings.cum_var = model.cum_var;

%------------------------------------------------------------
function K = k_index(eig_val)
sum_eig = sum(eig_val);
exp_var = eig_val./sum_eig;
mean_eig = mean(eig_val);
num = sum(abs(exp_var - (mean_eig/sum_eig)));
den = 2*(sum_eig - mean_eig)/sum_eig;
K = (num/den);

%------------------------------------------------------------
function cv = pcacv(X,maxcomp,cv_type,cv_groups,pret_type)
[nobj,nvar] = size(X);
obj_in_block = fix(nobj/cv_groups);
left_over = mod(nobj,cv_groups);
st = 1;
en = obj_in_block;
hwait = waitbar(0,'cross validating PCA models...');
setappdata(hwait,'canceling',0)
for i = 1:cv_groups
    if getappdata(hwait,'canceling')
        break
    end
    waitbar(i/cv_groups) 
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
    Xext = X(find(in==0),:);
    maxcomp = min([size(Xtrain,1) size(Xtrain,2)]);
    modelcv = pca_model(Xtrain,maxcomp,pret_type);
    Xext_scal = test_pretreatment(Xext,modelcv.settings.param);
    for k = 1:maxcomp
        Xext_scal_refit = zeros(size(Xext,1),size(Xext,2));
        for j=1:size(Xext_scal_refit,2)
            w = ones(size(Xext_scal_refit,2),1);
            w(j) = 0;
            w = find(w);
            xj = Xext_scal(:,w);
            Lj = modelcv.L(w,1:k);
            tj = xj*Lj*pinv(Lj'*Lj);
            Xext_scal_refit(:,j) = tj*modelcv.L(j,1:k)';
        end
        E = Xext_scal_refit - Xext_scal;
        press(i,k) = sum(sum(E.^2));
    end
end
delete(hwait)
cumpress = sum(press);
rmsecv = sqrt(cumpress./nobj);
cv.press = press';
cv.cumpress = cumpress;
cv.rmsecv = rmsecv;
