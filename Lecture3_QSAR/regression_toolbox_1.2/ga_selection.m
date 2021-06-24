function res = ga_selection(X,y,options)

% function for variable selection based on Genetic Algorithms (GA)
% GA are repeated options.runs times; at the end of these repetitions,
% variables are sorted on the basis of how many times they have been included in the best model of each run.
% Thus variables are sorted from the most important to the less important in the variable selection framework. 
%
% res = ga_selection(X,y,options)
%
% INPUT:            
% X                 dataset [samples x variables]
% y                 response vector [samples x 1]
% options           GA options created with the functions ga_options
%
% OUTPUT:
% res is a structure containing the following fields:
% var_sorted        sorted variable IDs [1 x variables] 
% num_selection	    number of times the variable in the corresponding var_sorted vector has been included in the best model [1 x variables]
% pop               structure array containing the GA populations at the end of the evolution {1 x options.runs}
%                   each populations include the following fields
%                   chrom: list of binary chromosomes [options.num_chrom x variables]
%                   ff: fitness function of chromosomes, R2 in cross validation [1 x options.num_chrom]
%                   param: number of LV (PLS), components (PCR), K (ridge), K (KNN), alpha (BNN) used for the corresponding chromosome [1 x options.num_chrom]
% options           GA options
% 
% RELATED ROUTINES:
% ga_options       create options for variable selection based on Genetic Algorithms (GA)
%
% REFERENCE PAPER:
% The GA strategy implemented in this function is inspired to that shown in the following paper:
% Leardi, R. and Lupianez, A. (1998). Genetic algorithms applied to feature selection in PLS regression: how and when to use them. Chemometrics and Intelligent Laboratory Systems, 41, 195-207.
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

% settings
runs = options.runs;
num_windows = options.num_windows;
num_eval = options.num_eval;
num_chrom = options.num_chrom;    
nvar = size(X,2);
max_param = 10;
if num_windows > 1
    nvar = num_windows;
end
% windows check
if num_windows > 1 && options.do_plot == 1
    mwin = mod(size(X,2),num_windows);
    window_size = floor(size(X,2)/num_windows);
    if mwin > 0
        disp(['windowing: ' num2str(window_size + mwin) ' variables will be grouped in the last window'])
    end
end
% cv with all the variables and set of the maximum param (like number of components) where required
if strcmp(options.method,'pls') || strcmp(options.method,'pcr')
    var_in = [1:nvar];
    [rhere,max_param] = ga_cv(X,y,var_in,options,max_param);
    if options.do_plot == 1
        disp(['cv with all variables: ' num2str(rhere) ' with ' num2str(max_param) ' components'])
    end
end
% GA runs
for r=1:runs
    if options.do_plot == 1
        disp(' ')
        disp(['run ' num2str(r) ' of ' num2str(runs)])
    end
    [pop,best_eval,pred_eval] = dorun(X,y,options,max_param);
    % save run results and updates plot
    best_chrom(r,:) = pop.chrom(1,:);
    best_resp(r) = pop.resp(1);
    pop.best_eval = best_eval([num_chrom + 1:num_eval]);
    pop.pred_eval = pred_eval;
    pred_resp(r) = pred_eval;
    pop_tmp{r} = pop;
    if options.do_plot == 1
        disp(['At the end of the evolution: R2cv is ' num2str(best_resp(r)) ' with ' num2str(length(find(pop.chrom(1,:) == 1))) ' variables'])
    elseif options.do_plot > 1
        ga_plot(best_chrom,best_resp,pred_resp,runs,num_windows,r)
    end
end
% calculates frequencies
if size(best_chrom,1) > 1
    final_sel = sum(best_chrom);
else
    final_sel = best_chrom;
end
[~,where] = sort(-final_sel);
var_sorted  = where;
num_selection = final_sel(where);
% save results
res.var_sorted   = var_sorted;
res.num_selection  = num_selection;
res.pop = pop_tmp;
res.options = options;
res.options.max_param = max_param;
res.options.original_data_size = size(X,2);
% display final results
if options.do_plot == 3
    close (1)
end

% -------------------------------------------------------------------------
function [pop,best_eval,pred_eval] = dorun(X,y,options,max_param)
num_eval  = options.num_eval;
probmut   = options.probmut;
probcross = options.probcross;
num_chrom = options.num_chrom;    
maxvar    = options.maxvar;
freq_back = 100; % backward stepwise every freq_back evaluations
perc_validation = options.perc_validation;
[X,X_val,y,y_val] = make_test(X,y,perc_validation);
% creation and evaluation of the starting population
library = [];
library_back = [];
best_eval = [];
cnt_back  = 1;
[pop,library] = initpop(X,y,options,library,max_param);
e = num_chrom;
if options.do_plot == 1
    disp(['After the creation of the population: R2cv is ' num2str(pop.resp(1)) ' with ' num2str(length(find(pop.chrom(1,:) == 1))) ' variables'])
end
% start evaluations
while e < num_eval
    % selection of 2 chromosomes (weighted)
    chrom_id  = selectchrom(pop.ff);
    chrom_sel = pop.chrom(chrom_id,:);
    % cross-over and mutations
    chrom_sel = docrossover(chrom_sel,probcross);
    chrom_sel = domutations(chrom_sel,probmut);
    % evaluation of the offspring
    for i=1:size(chrom_sel,1)
        [pop,library,e,best_eval] = eval_offspring(X,y,chrom_sel(i,:),pop,library,e,maxvar,options,max_param,best_eval);
    end
    % does backward every freq_back evaluations
    if e >= freq_back*cnt_back
        cnt_back  = cnt_back + 1;
        [chrom_id,library_back]  = selectback(pop,library_back);
        var_in = find(pop.chrom(chrom_id,:));
        resp_in = pop.resp(chrom_id);
        var_step  = ga_stepback(X,y,var_in,options,max_param,resp_in);
        chrom_back = zeros(1,size(pop.chrom,2));
        chrom_back(var_step) = 1;
        [pop,library,e,best_eval] = eval_offspring(X,y,chrom_back,pop,library,e,maxvar,options,max_param,best_eval);
    end
end
% makes final backward
[chrom_id,library_back]  = selectback(pop,library_back);
var_in = find(pop.chrom(chrom_id,:));
resp_in = pop.resp(chrom_id);
var_step  = ga_stepback(X,y,var_in,options,max_param,resp_in);
chrom_back = zeros(1,size(pop.chrom,2));
chrom_back(var_step) = 1;
[pop,library,e,best_eval] = eval_offspring(X,y,chrom_back,pop,library,e,maxvar,options,max_param,best_eval);
% makes prediction on the validation set
if perc_validation > 0
    var_in = find(pop.chrom(1,:));
    pred_eval = ga_pred(X,y,X_val,y_val,var_in,options,pop.param(1));
else
    pred_eval = NaN;
end

% -------------------------------------------------------------------------
function chrom_co = docrossover(chrom,probcross)
chrom_co = chrom;
d = find(chrom(1,:) ~= chrom(2,:));
r = rand(1,size(d,2));
dohere  = find(r < probcross);
chrom_co(1,d(dohere)) = chrom(2,d(dohere));
chrom_co(2,d(dohere)) = chrom(1,d(dohere));

% -------------------------------------------------------------------------
function chrom_mu = domutations(chrom,probmut)
chrom_mu = chrom;
r = rand(2,size(chrom,2));
for i = 1:2
    f = find((r(i,:)) < probmut);
    if length(f) > 0
        chrom_mu(i,f) = abs(chrom(i,f) - 1);
    end
end

% -------------------------------------------------------------------------
function pop = updatepop(pop,chrom_sel,resp_sel,ff_sel,param_sel)
chrom = [pop.chrom; chrom_sel];
resp  = [pop.resp resp_sel];
param = [pop.param param_sel];
ff = [pop.ff ff_sel];
[a,where] = sort(-ff);
pop.chrom = chrom(where(1:end-1),:);
pop.resp  = resp(where(1:end-1));
pop.param  = param(where(1:end-1));
pop.ff  = ff(where(1:end-1));

% -------------------------------------------------------------------------
function chk = check_library(library,chrom_tmp)
chk = 1; k = 0; goon = 1;
while k < size(library,1) && goon
    k = k + 1;
    d = abs(chrom_tmp - library(k,:));
    if sum(d) == 0 
        goon = 0;    
        chk  = 0;
    end
end

% -------------------------------------------------------------------------
function [pop,library,e,best_eval] = eval_offspring(X,y,chrom_sel,pop,library,e,maxvar,options,max_param,best_eval)
chk_lib = check_library(library,chrom_sel);
sumvar = sum(chrom_sel);
if (chk_lib && sumvar < maxvar && sumvar > 0)
    var_in = find(chrom_sel);
    [rhere,best_param] = ga_cv(X,y,var_in,options,max_param);
    ff = dofitness(rhere,length(var_in),options);
    e = e + 1;
    library = [library; chrom_sel];
    % update population if better
    if ff > min(pop.ff)
        pop = updatepop(pop,chrom_sel,rhere,ff,best_param);
    end
end
best_eval(e) = pop.resp(1);

% -------------------------------------------------------------------------
function [pop,library] = initpop(X,y,options,library,max_param)
if options.num_windows < 2
    nvar = size(X,2);
else
    nvar = options.num_windows;    
end
probstart = options.startvar/nvar;
if probstart > 1; probstart = 0.5; end
cnt   = 0;
chrom = [];
resp  = [];
while cnt < options.num_chrom
    sumvar = 0;
    % creates chromosome with less variables than maxvar
    % and an average number of variables equal to options.startvar
    while (sumvar == 0 || sumvar > options.maxvar)
        chrom_tmp = rand(1,nvar);
        for j=1:length(chrom_tmp)
            if chrom_tmp(1,j) < probstart
                chrom_tmp(1,j)=1;
            else
                chrom_tmp(1,j)=0;
            end    
        end
        sumvar = sum(chrom_tmp);
    end
    % check if chrom_tmp already exists
    chk = check_library(library,chrom_tmp);
    if chk
        var_in = find(chrom_tmp);
        [r,best_param] = ga_cv(X,y,var_in,options,max_param);
        % r is best exp var in cv if regression, otherwise ner
        ff_tmp = dofitness(r,length(var_in),options);
        % calculate the fitness function. if pars_models is zero, 
        % the sort of indiviuduals on ff coincides with the sort made on r
        cnt = cnt + 1;
        library = [library; chrom_tmp];
        chrom(cnt,:)  = chrom_tmp;
        resp(cnt) = r;
        param(cnt) = best_param;
        ff(cnt) = ff_tmp;
    end
end
% sort population
[a,where] = sort(-ff);
pop.chrom = chrom(where,:);
pop.resp  = resp(where);
pop.ff = ff(where);
pop.param  = param(where);

% -------------------------------------------------------------------------
function F = dofitness(resp,nvar,options)
maxvar = options.maxvar;
pars_models = 0;
U = 1 - pars_models;
m = (1 - U)/(1 - maxvar);
q = (U - maxvar)/(1 - maxvar);
for k=1:length(resp)
    y = nvar(k)*m + q;
    F(k) = mean([y resp(k)]);
end

% -------------------------------------------------------------------------
function [id,library_back] = selectback(pop,library_back)
id = 1; goon = 1; k = 0;
if size(library_back,1) > 0
    while k < size(pop.chrom,1) && goon
        k = k + 1;
        chk = 1;
        for j = 1:size(library_back,1)
            if pop.chrom(k,:) == library_back(j,:)
                chk = 0;
            end
        end
        if chk
            goon = 0;    
            id  = k;
            library_back = [library_back; pop.chrom(k,:)];
        end
    end
else
    library_back = [library_back; pop.chrom(1,:)];
end

% -------------------------------------------------------------------------
function id = selectchrom(crit)
f = find(crit < 0);
crit(f) = 0;
cumcrit = cumsum(crit);
goon = 1; cnt = 0;
while goon
    cnt = cnt + 1;
    k = rand*cumcrit(length(crit));
    lower = find(cumcrit < k);
    if isempty(lower)
        id(1) = 1;
    else
        id(1) = lower(end);
    end
    k = rand*cumcrit(length(crit));
    lower = find(cumcrit < k);
    if isempty(lower)
        id(2) = 1;
    else
        id(2) = lower(end);
    end
    if id(1) ~= id(2)
        goon = 0;
    elseif cnt > 100;
        goon = 0;
        id(1) = 1;
        id(2) = 2;
    end   
end

% -------------------------------------------------------------------------
function [X_train,X_val,y_train,y_val] = make_test(X,y,perc_in_test)
in = ones(size(X,1),1);
r = randperm(size(X,1));
w = floor(size(X,1)*perc_in_test);
in(r(1:w))= 0;
X_train = X(find(in==1),:);
X_val   = X(find(in==0),:);
y_train = y(find(in==1));
y_val   = y(find(in==0));

% ------------------------------------------------------------------------
function [var_in] = ga_stepback(X,y,var_in,options,max_param,resp_in)
best_resp = resp_in;
goon = 1;
while goon && length(var_in) > 1
    goon = 0;
    for k = 1:length(var_in)
        test_var = var_in;
        test_var(k) = [];
        rhere = ga_cv(X,y,test_var,options,max_param);
        if rhere >= best_resp
            goon = 1;
            best_resp = rhere;
            del_var = k;
        end
    end
    if goon == 1
        var_in(del_var) = [];
    end
end

% -----------------------------------------------------------------------
function r = ga_pred(X,y,X_val,y_val,var_in,options,best_param)
method     = options.method;
pret_type       = options.pret_type;
dist_type  = options.dist_type; % for knn
num_windows = options.num_windows;
if num_windows < 2
    X = X(:,var_in);
    X_val = X_val(:,var_in);
else
    X = ga_windows(X,var_in,num_windows);
    X_val = ga_windows(X_val,var_in,num_windows);
end
if strcmp(method,'pls')
    model = plsfit(X,y,best_param,pret_type,0);
    pred = plspred(X_val,model);
    res = calc_external_reg_param(y,y_val,pred.yc);
    r = res.R2;
elseif strcmp(method,'ols')    
    model = olsfit(X,y);
    pred = olspred(X_val,model);
    res = calc_external_reg_param(y,y_val,pred.yc);
    r = res.R2;
elseif strcmp(method,'pcr')
    model = pcrfit(X,y,best_param,pret_type);
    pred = pcrpred(X_val,model); 
    res = calc_external_reg_param(y,y_val,pred.yc);
    r = res.R2;
elseif strcmp(method,'ridge')
    model = ridgefit(X,y,best_param);
    pred = ridgepred(X_val,model); 
    res = calc_external_reg_param(y,y_val,pred.yc);
    r = res.R2;
elseif strcmp(method,'knn')
    pred = knnpred(X_val,X,y,best_param,dist_type,pret_type);
    res = calc_external_reg_param(y,y_val,pred.yc);
    r = res.R2;
elseif strcmp(method,'bnn')
    pred = bnnpred(X_val,X,y,best_param,dist_type,pret_type);
    res = calc_external_reg_param(y,y_val,pred.yc);
    r = res.R2;
end
