function [R2cv,best_param,ycv,rmsecv,R2,rmse] = ga_cv(X,y,var_in,options,max_param)

% coss validation for selection based on Genetic Algorithms
% 
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

best_param  = 0;
method      = options.method;
pret_type   = options.pret_type;
cv_type     = options.cv_type;
cv_groups   = options.cv_groups;
dist_type   = options.dist_type; % for knn
if isfield(options,'num_windows')
    num_windows = options.num_windows;
else
    num_windows = 1;
end
if num_windows < 2
    X = X(:,var_in);
else
    X = ga_windows(X,var_in,num_windows);    
end
if strcmp(method,'pls')
    if length(var_in) < max_param
        max_param = length(var_in);
    end
    for c = 1:max_param
        cv = plscv(X,y,c,pret_type,cv_type,cv_groups);
        rtmp(c) = cv.reg_param.R2;
        rtmp_ycv{c} = cv.yc;
        rmsetmp(c) = cv.reg_param.rmse;
    end
    [R2cv,best_param] = max(rtmp);
    ycv = rtmp_ycv{best_param};
    rmsecv = rmsetmp(best_param);
    modelhere = plsfit(X,y,best_param,pret_type,0);
    R2 = modelhere.reg_param.R2;
    rmse = modelhere.reg_param.rmse;
elseif strcmp(method,'pcr')
    if length(var_in) < max_param
        max_param = length(var_in);
    end
    for c = 1:max_param
        cv = pcrcv(X,y,c,pret_type,cv_type,cv_groups);
        rtmp(c) = cv.reg_param.R2;
        rtmp_ycv{c} = cv.yc;
        rmsetmp(c) = cv.reg_param.rmse;
    end
    [R2cv,best_param] = max(rtmp);
    ycv = rtmp_ycv{best_param};
    rmsecv = rmsetmp(best_param);
    modelhere = pcrfit(X,y,best_param,pret_type,0);
    R2 = modelhere.reg_param.R2;
    rmse = modelhere.reg_param.rmse;
elseif strcmp(method,'ridge')
    k = [0.1:0.1:3];
    for c = 1:length(k)
        cv = ridgecv(X,y,k(c),cv_type,cv_groups);
        rtmp(c) = cv.reg_param.R2;
        rtmp_ycv{c} = cv.yc;
        rmsetmp(c) = cv.reg_param.rmse;
    end
    [R2cv,best_param] = max(rtmp);
    ycv = rtmp_ycv{best_param};
    rmsecv = rmsetmp(best_param);
    best_param = k(best_param);
    modelhere = ridgefit(X,y,best_param);
    R2 = modelhere.reg_param.R2;
    rmse = modelhere.reg_param.rmse;
elseif strcmp(method,'ols')
    cv = olscv(X,y,cv_type,cv_groups);
    R2cv = cv.reg_param.R2;
    ycv = cv.yc;
    rmsecv = cv.reg_param.rmse;
    modelhere = olsfit(X,y);
    R2 = modelhere.reg_param.R2;
    rmse = modelhere.reg_param.rmse;    
elseif strcmp(method,'knn')
    for c = 1:max_param
        cv = knncv(X,y,c,dist_type,pret_type,cv_type,cv_groups);
        rtmp(c) = cv.reg_param.R2;
        rtmp_ycv{c} = cv.yc;
        rmsetmp(c) = cv.reg_param.rmse;
    end
    [R2cv,best_param] = max(rtmp);
    ycv = rtmp_ycv{best_param};
    rmsecv = rmsetmp(best_param);
    modelhere = knnfit(X,y,best_param,dist_type,pret_type);
    R2 = modelhere.reg_param.R2;
    rmse = modelhere.reg_param.rmse;    
elseif strcmp(method,'bnn')
    alpha = [0.1:0.1:2];
    for c = 1:length(alpha)
        a_val = alpha(c);
        cv = bnncv(X,y,a_val,dist_type,pret_type,cv_type,cv_groups);
        rtmp(c) = cv.reg_param.R2;
        rtmp_ycv{c} = cv.yc;
        rmsetmp(c) = cv.reg_param.rmse;
    end
    [R2cv,best_param] = max(rtmp);
    ycv = rtmp_ycv{best_param};    
    rmsecv = rmsetmp(best_param);
    best_param = alpha(best_param);
    modelhere = bnnfit(X,y,best_param,dist_type,pret_type);    
    R2 = modelhere.reg_param.R2;
    rmse = modelhere.reg_param.rmse;    
end
