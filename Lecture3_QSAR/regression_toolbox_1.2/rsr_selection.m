function res = rsr_selection(X,y,options)

% function for variable selection based on Reshaped Sequential Replacement (RSR)
%
% res = rsr_selection(X,y,options)
%
% INPUT:            
% X                 dataset [samples x variables]
% y                 response vector [samples x 1]
% options           RSR options created with the functions rsr_options
%
% OUTPUT:
% res is a structure containing the following fields:
% summary           summary of the final population of models. Each row represents a model and columns correspond to:
%                   1: number of included variables (see var_list for variables ID), 2: fitting measure (R2) 
%                   3: cross-validation measure (R2cv) 4: optimal parameters (k for kNN, PCs for PCR, LV for PLS and so on)
% var_list          structure array containing the index of the variables included in the models. 
%                   Each k-th entry of var_list contains the variables included in the model described in the k-th row of summary
% options           RSR options
% 
% RELATED ROUTINES:
% rsr_options      create options for variable selection based on Reshaped Sequential Replacement (RSR)
%
% REFERENCE PAPERS:
% The RSR variable selection strategy is explained in the following papers:
% [1]  M. Cassotti, F. Grisoni, R. Todeschini. Reshaped Sequential Replacement algorithm: an efficient approach to variable selection. Chemometrics and Intelligent Laboratory Systems, (2014) 133, 136-148.
% [2]  F. Grisoni, M. Cassotti, R. Todeschini. Reshaped Sequential Replacement for variable selection in QSPR: comparison with other reference methods. Journal of Chemometrics (2014) 28, 249–259.
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
% RSR toolbox v. 2.0
% March 2020.
% Roberto Todeschini, Matteo Cassotti & Francesca Grisoni
% Milano Chemometrics and QSAR Research Group
% adapted for the Regression toolbox for MATLAB
% version 1.0 - July 2020
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

if options.minvar == 1
    options.minvar = 2;
end
numseed = options.numseed;
method = options.method;
doplot = options.do_plot;
% Display options
if doplot == 1
    disp('RSR selection')
    disp ( 'Options:')
    disp (['- maxvar: ' num2str(options.maxvar)])
    disp (['- numseed: ' num2str(numseed)])
    disp (['Total number of seeds: ' num2str(numseed*(options.maxvar - options.minvar + 1))])
end
lab_par = 'Q2cv';
% quik rule is deactivated if not OLS
if ~strcmp(method,'ols')
    options.quik_rule = 0;
end
[~,nvar] = size(X);  % save n and p of the (new) X, Y
var_index = 1:nvar;
% Calculation of correlation matrix of X and X+Y (if options.quik_rule = 1)
if options.quik_rule == 1
    [X_scal,~] = data_pretreatment(X,options.pret_type);
    Cxy = corrcoef([X_scal y]);
else
    Cxy = [];
end
% Calculations of univariate models
univparam = calc_univ(X,y,options,nvar);
% Tabu list
if options.tabu == 1
    [var_index_in, leng_in, options] = do_tabu(univparam,var_index,nvar,options.thr_tabu,options); 
else
    var_index_in = var_index;   
    leng_in = nvar;
end
% Reshaped Sequential Replacement
[seed,inseedcc] = rsr_init(options,leng_in);
if seed == -999
    res = NaN; 
    return
end
% find models with only 1 combination possible or saturated combinations.
if  size(seed,1) > inseedcc
    seedcc = seed(inseedcc+1:end,:);
    num_seedcc = size(seedcc,1);
    % expand seedcc to all variables
    seedccexploded = zeros(num_seedcc,nvar);
    seedccexploded(:,var_index_in) = seedcc;
    % detach seedcc from seed
    seed = seed(1:inseedcc,:);
    % cross-validate seedcc
    conv_r_cc = zeros(num_seedcc,1);
    best_param_cc = zeros(num_seedcc,1);
    for i = 1:num_seedcc
        [r_cc_here,best_param_cc_here] = ga_cv(X,y,find(seedccexploded(i,:)),options,10);
        conv_r_cc(i) = r_cc_here;
        best_param_cc(i) = best_param_cc_here;
    end   
else
    seedccexploded = []; 
    best_param_cc = [];
    conv_r_cc = [];
end
% seeds permutation
if isempty(seed) == 0
    [conv_BEST,conv_r,~,conv_param,~] = sequential_replacement(seed,...
        leng_in,options,Cxy,var_index_in, var_index,X,y,nvar,lab_par);
else
    conv_BEST = []; conv_r = []; conv_param = [];
end
% get the numseed best univariate seeds
if numseed > nvar  % if numseed>nvar, we maximum have nvar univariate models
   numseed_univ = nvar;
else
    numseed_univ = numseed;
end
[~,J] = sort(univparam,'descend');
best_univseed = zeros(numseed_univ,nvar);
best_r_univ = univparam(J(1:numseed_univ));
best_param_univ = zeros(numseed_univ,1);
for i = 1:numseed_univ
    best_univseed(i,J(i)) = 1;
    [~,best_param_univ_here] = ga_cv(X,y,find(best_univseed(i,:)),options,10);
    best_param_univ(i) = best_param_univ_here;
end
% merge BEST, seedcc and univseed
Final_pop = [conv_BEST;seedccexploded;best_univseed];
Final_r = [conv_r;conv_r_cc;best_r_univ];
Final_best_param = [conv_param;best_param_cc;best_param_univ];
% sort final population
Final_size = sum(Final_pop,2);
[Final_size,I] = sort(Final_size);
Final_pop = Final_pop(I,:);
Final_best_param = Final_best_param(I);
Final_r = Final_r(I,:);
% Fit final population
Final_r_fit = zeros(size(Final_r,1),2);
for i = 1 : size(Final_r,1)
    [~,~,~,~,R2,rmse] = ga_cv(X,y,find(Final_pop(i,:)),options,10);
    Final_r_fit(i,:) = [R2 rmse];
end
% Create Final_pop_var, containing variable indexes of each model
in = find(Final_r(:,1) > -999);
Final_pop = Final_pop(in,:);
Final_r_fit = Final_r_fit(in,:);
Final_r = Final_r(in,:);
Final_size = Final_size(in,:);
Final_best_param = Final_best_param(in,:);
for i = 1:size(Final_pop,1)
    var_here = find(Final_pop(i,:));
    var_list{i,1} = var_here;
end
% pathologies, only for OLS
if strcmp(options.method,'ols')
    R_pathologies = rsr_R_funct(Final_pop,Final_r_fit,X,y);
end
% Create summary of the results
Final_r_fit(:,1) = round(Final_r_fit(:,1),4);
Final_r(:,1) = round(Final_r(:,1),4);
summary = [Final_size  Final_r(:,1) Final_r_fit(:,1) Final_best_param];
% find equal solutions and delete, delete solutions with less than minvar
[summary,var_list] = filterequals(summary,var_list,options.minvar);
% Stores results in res
res.summary = summary;
res.var_list = var_list;
res.options = options;
end

% -------------------------------------------------------
function R_funct = rsr_R_funct(finalpop,Final_r_fit,X,y)
thr_RP = 0.01;
thr_RN = 0.02; 
% Initialization
num_models = size(finalpop,1);
univ_in = sum(finalpop);
univ_in = find(univ_in);
nvar_in = length(univ_in);
univparam = zeros(nvar_in,1);
% User-defined thresholds
e = thr_RN;
tP = thr_RP;
% Univariate param
for i = 1 : nvar_in
    res = olsfit(X(:,univ_in(i)),y);
    univparam(i,1) = res.reg_param.R2;
end
resRN = ones(num_models,1);
resRP = ones(num_models,1);
RP = zeros(num_models,1);
tN = zeros(num_models,1);
for j = 1 : num_models
    % Calculation of Mj for each variable of the model
    R = Final_r_fit(j,1);       % R2 of the j-th model
    p = sum(finalpop(j,:));     % number of variables
    Mj = zeros(p,1);
    Rp = zeros(p,1);
    Rn = zeros(p,1);
    a = find(finalpop(j,:));    % variables of this model
    % calculation of tN value for rejecting the models
    tN = (p*e - R)/(p*R);
    % calculation of Mj, RP and RN
    for k = 1:p
        Rjy = univparam(find(univ_in==a(k)));
        Mj(k,1) = Rjy/R -(1/p);
        if Mj(k,1) > 0
            Rp(k,1) = 1-(Mj(k)*(p/(p-1)));
            Rn(k,1) = 0;
        else
            Rn(k,1) = Mj(k,1);
            Rp(k,1) = 1;
        end
    end
    % application of RN rule
    if isempty(find(Rn<tN)) == 0
        resRN(j) = 0;           % RN with single elements
    end
    % applcation of RP rule
    RP_here = prod(Rp);
    if RP_here < tP
        resRP (j) = 0;
    end
end
R_funct = [resRN resRP];
end

% ---------------------------------------------------------------------
function [summary,var_list] = filterequals(summary,var_list,minvar)
varin = ones(length(var_list),1);
for k = 1:length(var_list) - 1
    if varin(k) == 1
        for j = k+1:length(var_list)
            if varin(j) == 1
                w = isequal(var_list{k},var_list{j});
                if w
                    varin(j) = 0;
                end
            end
        end
    end
end
in = find(varin);
summary = summary(in,:);
var_list = var_list(in);
in = find(summary(:,1) >= minvar);
summary = summary(in,:);
var_list = var_list(in);
end

% ---------------------------------------------------------------------
function univparam = calc_univ(X,y,options,nvar)
univparam = zeros(nvar,1); % storage for univariate statistics
if ~strcmp(options.method,'ols'); options.method = 'ols'; end
for i = 1:nvar
    r2cv = ga_cv(X,y,i,options,NaN);
    univparam(i,1) = r2cv;
end
end

% ---------------------------------------------------------------------
function [var_index_in, leng_in, options, in_tabu] = do_tabu(univparam,var_index,nvar,thr_tabu,options)
in_tabu = zeros(1,nvar);
in_tabu(univparam < thr_tabu) = 1;
var_index_in = var_index(in_tabu == 0);
leng_in = length(var_index_in);
leng_out = nvar - leng_in;
% check that not all the variables are in tabu list
if leng_out == nvar
    if options.do_plot == 1
        disp (' ')
        disp(['Tabu list contains all the ' num2str(leng_out) ' variables'])
        disp ('Deactivation of tabu list is suggested.')
    end
    res = NaN;
    return
end
if options.do_plot == 1
    if options.do_plot == 1
        disp (['Tabu list contains: ' num2str(leng_out) ' variables'])
        disp (['Remaining: ' num2str(leng_in) ' variables'])
    end
end
if leng_in < options.maxvar
    options.maxvar = leng_in;
    if options.do_plot == 1
        disp (['maxvar reduced to ' num2str(leng_in) ' due to Tabu list'])
    end
end
% check that minvar < maxvar
if options.minvar > options.maxvar
    options.minvar = options.maxvar;
    if doplot == 1
        disp (['minvar reduced to ' num2str(options.minvar) ' due to Tabu list'])
    end
end
end

% -------------------------------------------------------------------------
function [conv_BEST,conv_r,conv_it,conv_param,tabu_ind] = sequential_replacement(seed,...
    leng_in,options,Cxy,var_index_in, var_index,X,y,nvar,lab_par)
n_models = size(seed,1);
BEST = zeros(n_models,leng_in);
it = zeros(n_models,1); % number of iterations to converge
r = zeros(n_models,1);
BEST_param = zeros(n_models,1);
if options.do_plot == 2
    hwait = waitbar(0,'RSR variable selection');
end
for i = 1 : size(seed,1)
    [conv_seed,conv_it,conv_r,conv_best_param] = do_permutations(seed(i,:),options,Cxy,...
        X(:,var_index_in),y, var_index_in,i);
    BEST(i,:) = conv_seed;
    it(i) = conv_it;
    r(i) = conv_r;
    BEST_param(i) = conv_best_param;
    if options.do_plot == 1
        disp(' ')
        disp(['Seed ' num2str(i) ' out of ' num2str(size(seed,1)) ' converged.'])
        disp([lab_par ' = ' num2str(sprintf('%0.3f',conv_r)) ' and ' num2str(length(find(conv_seed(1,:)))) ' variables.'])
    elseif options.do_plot == 2
        waitbar(i/size(seed,1))
    end
end
if options.do_plot == 2
    delete(hwait)
end
% Reincluding the variables of tabu list
if options.tabu == 1 && isequal(leng_in,nvar) == 0
    BESTexploded = zeros(size(BEST,1),nvar);
    BESTexploded(:,var_index_in) = BEST;
    [t_BEST,t_r,t_it,t_best_param] = rsr_tabu(X,y,BESTexploded,options,r,var_index,Cxy);
else
    t_r = []; t_BEST = []; t_it = []; t_best_param = []; BESTexploded = BEST;
end
conv_BEST = [BESTexploded; t_BEST];
conv_r = [r; t_r];
conv_it = [it; t_it];
conv_param = [BEST_param; t_best_param];
tabu_ind = zeros(size(conv_BEST,1),1);
if isempty(t_BEST) == 0
    tabu_ind(size(BESTexploded,1)+1:end) =  1;
end
end

%-------------------------------------------------------------------------
function [seed,inseedcc] = rsr_init(options,nvar)
maxvar = options.maxvar;
minvar = options.minvar;
numseed = options.numseed;
nvarin = nvar;
% calculates the number of possible combinations for each dimension.
seedcc = [];  
ncomb = zeros(1,maxvar - minvar + 1);
for i = minvar:maxvar
    n = nvarin-i+1;
    prod = n;
    for j = (n+1):(nvarin)
        prod = prod*j; 
    end
    ncomb(i-minvar+1) = prod/factorial(i);
    if ncomb(i-minvar+1) <= numseed
        comb = combnk(1:nvarin,i);
        if isempty(seedcc) == 0
            zer = zeros(size(seedcc,1),i-size(seedcc,2));
            seedcc = [seedcc zer];
        end
        seedcc = [seedcc;comb];
    end
end
% reduce maxvar according to check on combinations for each model size
if isempty(seedcc) == 0
    [~,E] = find(ncomb > numseed);
    if maxvar == minvar+max(E)-1
        dsp = 0;
    else
        dsp = 1;
    end
    maxvar = minvar+max(E)-1;                  
    if isempty(maxvar) == 0 && dsp == 1
        if options.do_plot == 1
            disp (['Sequential replacement on seeds up to ' num2str(maxvar) ' variables'])
        end
    elseif isempty(maxvar) == 1
        if options.do_plot == 1
            disp ('No seeds subject to sequential search')
        end
    end
end
% Initialization of seeds
if isempty(maxvar) == 0
    totseed = numseed*(maxvar - minvar + 1);
    seedc(1:totseed,1:maxvar) = zeros;
    seedc = rand_init(minvar,maxvar,numseed,seedc,nvarin);
    % unfolding
    seed = zeros(size(seedc,1),nvar);
    p_here = zeros(size(seed,1),1);
    for i = 1:size(seedc,1)
        p_here(i) = nnz(seedc(i,:));
        seed(i,seedc(i,1:p_here(i))) = 1;
    end
    % reorder seeds in blocks of same model size
    [~,I] = sort(p_here,'ascend');
    seed = seed(I,:);
elseif isempty(maxvar) == 1
    seed = [];
end
% unfold eventual seedcc
if isempty(seedcc) == 0
    seedccc = zeros(size(seedcc,1),nvar);
    p_here = zeros(size(seedcc,1),1);
    for i = 1:size(seedcc,1)
        p_here(i) = nnz(seedcc(i,:));
        seedccc(i,seedcc(i,1:p_here(i))) = 1;
    end
end
% merge seed and seedccc
inseedcc = size(seed,1);
if isempty(seedcc) == 0
    seed = [seed;seedccc];
end
end

% -------------------------------------------------------------------------
function seedc = rand_init(minvar,maxvar,numseed,seedc,nvar)
nseed = 0;
totseed = size(seedc,1);
for k = minvar:maxvar
    for i = 1:numseed
        nseed = nseed +1;
        r = randperm(nvar);
        seedc(nseed,1:k) = r(1:k);
    end
end
% check for duplicates
if numseed > 1
    seedc = sort(seedc(:,:),2,'ascend');
    [unique_seedc,IA,~] = unique(seedc,'rows');
    if totseed > size(unique_seedc)
        cnt = 0;
        while  cnt == 0
            index = zeros(totseed,1);
            index(IA,1) = 1;
            duplicated = seedc(index==0,:);
            regenerated = zeros(size(duplicated));
            
            for i = 1:size(duplicated,1)
                size_duplicated = nnz(duplicated(i,:));
                r = randperm(nvar);
                regenerated(i,1:size_duplicated) = r(1:size_duplicated);
            end
            regenerated = sort(regenerated(:,:),2,'ascend');
            seedc = [unique_seedc;regenerated];
            [unique_seedc,IA,~] = unique(seedc,'rows');
            
            if totseed == size(unique_seedc,1)
                cnt = 1;
            end
        end
    end
     seedc = sort(seedc(:,:),2,'descend');
end
end

% -------------------------------------------------------------------------
function [conv_seed,conv_it,conv_r,conv_best_param] = do_permutations(seed,options,Cxy,X,y,var_index_in,row,rprev)
% Thresholds for comparison
if nargin == 7     % if tabu variables are reincluded
    thr_comp = 0;  
    tabu = 0;
elseif nargin == 8
    thr_comp = 0.01;
    tabu = 1;
end
convergence = 0;
iteration = 0;
history_r = [];
% Do permutations
while convergence == 0
    % Number of combinations
    fix_var = find(seed);
    n_fix = length(fix_var);
    var_comb = combnk(fix_var, n_fix - 1); % variable combinations
    % Generate permutations
    compl_seed = abs(seed - 1);  % Complementary seed
    % unfolding of compl_seed
    n_rows = sum(compl_seed,2);   % number of replacement for each combination
    var_compl = find(compl_seed);
    seedtemphere = zeros(n_rows, size(seed,2));
    for j = 1 : n_rows
        seedtemphere(j,var_compl(1,j)) = 1;
    end
    seedtemp = repmat(seedtemphere,n_fix,1);
    cnt = 1;
    for i = 1 : n_fix
        sel_var = var_comb(i,:);
        seedtemp(cnt:(cnt+n_rows-1),sel_var) = 1;
        cnt = cnt + n_rows;
    end
    seedtemp = [seedtemp; seed];    % adds original seed
    n_seedtemp = size(seedtemp,1);
    % QUIK rule
    if options.quik_rule == 1
        I = zeros(n_seedtemp,1);
        for i = 1:n_seedtemp
            var_sel = var_index_in(seedtemp(i,:)== 1);
            I(i) = rsr_quik(options.thr_quik,Cxy,var_sel);
        end
        if sum(I) == 0
            if options.do_plot == 1
                disp(' ')
                disp(['No replacement of variables of seed ' num2str(row) ' fulfilled the QUIK rule:'])
                disp('the seed will be randomly re-initialized.')
            end
            iwhile = 0;
            err = 0;
            while iwhile == 0 && err <= 50
                r = randperm(size(var_index_in,2));
                var_sel = var_index_in(r(1:n_fix));
                var_sel = sort(var_sel,2,'ascend');
                I = rsr_quik(options.thr_quik,Cxy,var_sel); %applies QUIK rule
                if I == 1
                    seedtemp = zeros(1,size(var_index_in,2));
                    seedtemp(1,r(1:n_fix)) = 1;
                    iwhile = 1;
                end
                if I == 0 && err == 50
                    if options.do_plot == 1
                        disp(' ')
                        disp (['WARNING: After 50 random re-initializations, no seed fulfilled the QUIK rule:'])
                    end
                    if iteration == 0
                        conv_it = -999;
                        conv_r = -999;
                        conv_best_param = -999;
                        conv_seed = seed;
                        if options.do_plot == 1
                            disp 'The seed will be terminated. Its parameters will be set to -999 in the final population.'
                        end
                    else
                        conv_it = iteration;
                        conv_r = rprev;
                        conv_seed = seed;
                        conv_best_param = best_param_max;
                        if options.do_plot == 1
                            disp 'The seed will be terminated. The last seed fulfilling the QUIK rule will be saved.'
                        end
                    end
                    return
                end
                err = err+1;
            end
        end
        seedtemp = seedtemp(I==1,:);
        n_seedtemp = size(seedtemp,1);
    end
    % Cross-validate seedtemp 
    rtemp = zeros(n_seedtemp,1);
    best_paramtemp = zeros(n_seedtemp,1);
    for i = 1 : n_seedtemp
        [rhere,best_paramhere] = ga_cv(X,y,find(seedtemp(i,:)),options,10);
        rtemp(i) = rhere;
        best_paramtemp(i) = best_paramhere;
    end
    % Find best replacement
    [rmax,I] = max(rtemp);
    best_param_max = best_paramtemp(I);
    %  Compare best replacement with starting seed
    if iteration == 0
        if tabu == 0
            rprev = rmax;
        end
        if isequal(seed,seedtemp(I,:)) || rmax < rprev + thr_comp
            convergence = 1;
            history_r = [history_r; rprev];
            if tabu
                best_param_max = -999;
            end
        else
            seedcntr = seedtemp(I,:);
        end
    else
        if rmax == rprev
            seedcntr = [seedcntr; seedtemp(I,:)];
            A = size(unique(seedcntr,'rows'),1);
            if isequal(size(seedcntr,1),A) == 0
                seed = seedtemp(I,:);
                convergence = 1;
                history_r = [history_r; rprev];
            end
        else
            seedcntr = seedtemp(I,:);
        end
    end
    iteration = iteration +1;
    if convergence < 1
        seed = seedtemp(I,:); rprev = rmax; history_r = [history_r; rprev];
    end
end
conv_r = rprev;
conv_seed = seed;
conv_it = iteration;
conv_best_param = best_param_max;
end

% -------------------------------------------------------------------------
function [t_BEST,t_r,t_it,t_best_param] = rsr_tabu(X,y,t_seed,options,r,var_index,Cxy)
doplot = options.do_plot;
% options for display according to the method
lab_par = 'Q2cv';
if options.do_plot == 1
    disp (' ')
    disp 'Inclusion of tabu list variables...'
end
% generating u_BEST, the same as BEST but with the right number of columns
I = find(r ~= -999);
t_seed = t_seed(I,:);
r = r(I);
[u_BEST,B] = unique(t_seed,'rows');
u_r = r(B);
t_BEST = [];
t_r = [];
t_it = [];
t_best_param = [];
for i = 1:size(u_BEST,1)
    [conv_seed,conv_it,conv_r,conv_best_param] = do_permutations(u_BEST(i,:),options,Cxy,X,y,var_index,i,u_r(i));
    if conv_best_param ~= -999
        t_BEST = [t_BEST;conv_seed];
        t_it = [t_it; conv_it];
        t_r = [t_r;conv_r];
        t_best_param = [t_best_param; conv_best_param];
        if doplot == 1
            disp(['1 seed including tabu variables converged with an increase in ' lab_par ' = ' num2str(sprintf('%0.3f',(conv_r - u_r(i))))])
        end
    end
end
if isempty(t_BEST)
    if options.do_plot == 1
        disp(' ')
        disp('Inclusion of tabu variables did not provide any improvement.')
    end
end
end

% -------------------------------------------------------------------------
function Iq = rsr_quik(thr_q,Cxy,var_sel)
% QUIK rule for rejecting models with high predictor collinearity (only for OLS regression).
CorrMx = Cxy(var_sel,var_sel);  % corr matrix of selected variables
lambda = eig(CorrMx);           % vector of the eigenvalues of CorrMx.
numvar = length(var_sel);       % number of variables in the model.
sumr = sum(lambda);
R = zeros(size(lambda));
for r = 1:numvar
    R(r) = abs((lambda(r)/sumr)-(1/numvar));
end
den = (numvar-1)/numvar;
Kx = sum(R)/(2*den);
% Calculates Kxy
CorrMxy = Cxy([var_sel end],[var_sel end]);  % corr matrix of selected variables + response
lambdaxy = eig(CorrMxy);                     % vector of the eigenvalues obtained from CorrMxy.
numvar = numvar+1;
suml = sum(lambdaxy);
L = zeros(size(lambdaxy));
for l=1:numvar
    L(l) = abs((lambdaxy(l)/suml)-(1/numvar));
end
den = (numvar-1)/(numvar);
Kxy = sum(L)/(2*den);
if Kxy-Kx > thr_q
    Iq = 1;
else
    Iq = 0;
end
end