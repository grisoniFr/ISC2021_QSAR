function cv = pcrcv(X,y,comp,pret_type,cv_type,cv_groups)

% cross-validate Principal Component Regresion (PCR)
%
% cv = pcrcv(X,y,comp,pret_type,cv_type,cv_groups)
%
% INPUT:
% X                 dataset [samples x variables]
% y                 response vector [samples x 1]
% comp              number of Principal Components
% pret_type         data pretreatment 
%                   'none' no scaling
%                   'cent' centering
%                   'scal' variance scaling
%                   'auto' autoscaling (centering + variance scaling)
%                   'rang' range scaling (0-1)
% cv_type           type of cross validation
%                   'vene' for venetian blinds'
%                   'cont' for contiguous blocks
%                   'boot' for bootstrap with resampling
%                   'rand' for random sampling (montecarlo) with 20% of samples out
% cv_groups         number of cv groups
%                   if cv_groups == samples: leave-one-out
%                   if 'boot' or 'rand' are selected as cv_type, cv_groups sets the number of iterations
%
% OUTPUT:
% cv is a structure containing the following fields:
% yc                cross validated response [samples x 1]
% reg_param         structure with regression measures (RMSE, R2)
% settings          cv settings
%
% RELATED ROUTINES:
% pcrfit            fit PCR model
% pcrpred           prediction of new samples with PCR
% pcrcompsel        selection of the optimal number of components for PCR
% reg_gui           main routine to open the graphical interface
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

nobj = size(X,1);
if strcmp(cv_type,'boot')
    hwait = waitbar(0,'bootstrap validation');
    out_bootstrap = zeros(nobj,1);
    assigned_y = [];
    y_true = [];
    for i=1:cv_groups
        waitbar(i/cv_groups)
        out = ones(nobj,1);
        whos_in = [];
        for k=1:nobj
            r = ceil(rand*nobj);
            whos_in(k) = r;
        end
        out(whos_in) = 0;
        % counters for left out samples
        boot_how_many_out(i)=length(find(out == 1));
        out_bootstrap(find(out == 1)) = out_bootstrap(find(out == 1)) + 1;
        x_ext = X(find(out == 1),:);
        y_ext = y(find(out == 1));
        x_in  = X(whos_in,:);
        y_in  = y(whos_in);
        model = pcrfit(x_in,y_in,comp,pret_type,0);
        pred = pcrpred(x_ext,model);
        assigned_y = [assigned_y; pred.yc];
        y_true = [y_true; y_ext];
    end
    y = y_true;
    delete(hwait);
elseif strcmp(cv_type,'rand')
    hwait = waitbar(0,'montecarlo validation');
    out_rand = zeros(nobj,1);
    perc_in = 0.8;
    take_in = round(nobj*perc_in);
    assigned_y = [];
    y_true = [];
    for i=1:cv_groups
        waitbar(i/cv_groups)
        out = ones(nobj,1);
        whos_in = randperm(nobj);
        whos_in = whos_in(1:take_in);
        out(whos_in) = 0;
        % counters for left out samples
        out_rand(find(out == 1)) = out_rand(find(out == 1)) + 1;
        x_ext = X(find(out == 1),:);
        y_ext = y(find(out == 1));
        x_in  = X(whos_in,:);
        y_in  = y(whos_in);
        model = pcrfit(x_in,y_in,comp,pret_type,0);
        pred = pcrpred(x_ext,model);
        assigned_y = [assigned_y; pred.yc];
        y_true = [y_true; y_ext];
    end
    y = y_true; 
    delete(hwait);
else
    assigned_y = zeros(nobj,1);
    obj_in_block = fix(nobj/cv_groups);
    left_over = mod(nobj,cv_groups);
    st = 1;
    en = obj_in_block;
    for i=1:cv_groups
        % prepares objects
        in = ones(nobj,1);
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
        x_in = X(find(in),:);
        y_in = y(find(in),:);
        x_ext = X(find(in == 0),:);
        model = pcrfit(x_in,y_in,comp,pret_type,0);
        pred = pcrpred(x_ext,model);
        assigned_y(find(in == 0)) = pred.yc;
    end
end
reg_param = calc_reg_param(y,assigned_y);
% results
cv.yc = assigned_y;
cv.reg_param = reg_param;
cv.settings.cv_groups = cv_groups;
cv.settings.cv_type = cv_type;
cv.settings.comp = comp;
cv.settings.pret_type = pret_type;