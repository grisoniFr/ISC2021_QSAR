function visualize_plotprediction(model)

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
% Ballabio D, Consonni V, (2013) Classification tools in chemistry. Part 1: Linear models. PLS-DA. Analytical Methods, 5, 3790-3798
% 
% Classification toolbox for MATLAB
% version 5.4 - November 2019
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

if strcmp(model.type,'plsda') % if model was calibrated on components
    if size(model.T,2) == 2 % on 2 PCs
        X = model.T; % data to be predicted
        [x,y,Xgrid] = makegriddata(X,500);
        Xplot = X; % data to be plotted
        Xgrid_plot = Xgrid;
        variable_labels{1} = 'scores on LV1';
        variable_labels{2} = 'scores on LV2';
    else % on 2D data with 1 PCs
        X = model.settings.raw_data;
        [x,y,Xgrid] = makegriddata(X,100);
        Xplot = data_pretreatment(X,model.settings.pret_type);
        Xgrid_plot = test_pretreatment(Xgrid,model.settings.px);
        variable_labels = getlabels(model);
    end
elseif strcmp(model.type,'simca') || strcmp(model.type,'uneq')
    X = model.settings.raw_data;
    [x,y,Xgrid] = makegriddata(X,150);
    Xplot = test_pretreatment(X,model.modelpca.settings.param);
    Xgrid_plot = test_pretreatment(Xgrid,model.modelpca.settings.param);
    variable_labels = getlabels(model);
elseif strcmp(model.type,'pf')
    X = model.settings.raw_data;
    [x,y,Xgrid] = makegriddata(X,150);
    Xplot = test_pretreatment(X,model.settings.param);
    Xgrid_plot = test_pretreatment(Xgrid,model.settings.param);
    variable_labels = getlabels(model);
elseif strcmp(model.type,'pcalda') || strcmp(model.type,'pcaqda')
    if size(model.settings.modelpca.T,2) == 2 % on 2 PCs
        X = model.settings.modelpca.T;
        [x,y,Xgrid] = makegriddata(X,500);
        Xplot = X;
        Xgrid_plot = Xgrid;
        variable_labels{1} = 'scores on PC1';
        variable_labels{2} = 'scores on PC2';
    else % on 2D data with 1 PCs
        X = model.settings.raw_data;
        [x,y,Xgrid] = makegriddata(X,250);
        Xplot = data_pretreatment(X,model.settings.pret_type);
        Xgrid_plot = test_pretreatment(Xgrid,model.settings.modelpca.settings.param);
        variable_labels = getlabels(model);
    end
elseif strcmp(model.type,'knn') || strcmp(model.type,'backprop') % if model was calibrated on scaled data
    X = model.settings.raw_data;
    if strcmp(model.type,'knn')
        [x,y,Xgrid] = makegriddata(X,50);
    else
        [x,y,Xgrid] = makegriddata(X,150);
    end
    if strcmp(model.type,'backprop')
        [Xplot,param_simca] = data_pretreatment(X,'auto');
    else
        [Xplot,param_simca] = data_pretreatment(X,model.settings.pret_type);
    end
    Xgrid_plot = test_pretreatment(Xgrid,param_simca);
    variable_labels = getlabels(model);
elseif strcmp(model.type,'svm') % special cases for svm, data or components
    if isstruct(model.settings.model_pca) && model.settings.num_comp == 2
        X = model.settings.model_pca.T; % data to be predicted
        [x,y,Xgrid] = makegriddata(X,100);
        Xplot = X; % data to be plotted
        Xgrid_plot = Xgrid;
        variable_labels{1} = 'scores on PC1';
        variable_labels{2} = 'scores on PC2';
    else % on 2D data with 1 PCs
        X = model.settings.raw_data;
        [x,y,Xgrid] = makegriddata(X,100);
        [Xplot,param_svmpotfun] = data_pretreatment(X,model.settings.pret_type);
        Xgrid_plot = test_pretreatment(Xgrid,param_svmpotfun);
        variable_labels = getlabels(model);
    end
else % cart, lda, qda
    X = model.settings.raw_data;
    Xplot = X;
    [x,y,Xgrid] = makegriddata(X,500);
    Xgrid_plot = Xgrid;
    variable_labels = getlabels(model);
end

% make prediction on grid data
if strcmp(model.type,'plsda')
    if size(model.T,2) == 2 % on 2 PCs
        Q = model.Q;
        nF = size(model.T,2);
        yscal_c = 0;
        for k = 1:nF
            yscal_c = yscal_c + Xgrid(:,k)*Q(:,k)';
        end
        yc = redo_scaling(yscal_c,model.settings.py);
    else
        pred = plsdapred(Xgrid,model);
        yc = pred.yc;
    end
    if strcmp(model.settings.assign_method,'max')
        [non,assigned_class] = max(yc');
    else
        assigned_class = plsdafindclass(yc,model.settings.thr);
    end
    class_pred = assigned_class';
    P = reshape(class_pred, [length(x) length(y)]);
elseif strcmp(model.type,'simca')
    pred = simcapred(Xgrid,model);
    class_pred = pred.class_pred;
    P = reshape(class_pred, [length(x) length(y)]);
elseif strcmp(model.type,'uneq')
    pred = uneqpred(Xgrid,model);
    class_pred = pred.class_pred;
    P = reshape(class_pred, [length(x) length(y)]);
elseif strcmp(model.type,'pf')
    pred = potpred(Xgrid,model);
    class_pred = pred.class_pred;
    P = reshape(class_pred, [length(x) length(y)]);    
elseif strcmp(model.type,'pcalda') || strcmp(model.type,'pcaqda')
    if size(model.settings.modelpca.T,2) == 2
        if model.settings.class_prob == 1
            class_pred = classify(Xgrid,X,model.settings.class,model.settings.method);
        else
            class_pred = classify(Xgrid,X,model.settings.class,model.settings.method,model.settings.prob);
        end
    else
        if model.settings.class_prob == 1
            pred = dapred(Xgrid,model);
            class_pred = pred.class_pred;
        else
            pred = dapred(Xgrid,model);
            class_pred = pred.class_pred;
        end
    end
    P = reshape(class_pred, [length(x) length(y)]);
elseif strcmp(model.type,'lda') || strcmp(model.type,'qda')
    pred = dapred(Xgrid,model);
    P = reshape(pred.class_pred, [length(x) length(y)]);
elseif strcmp(model.type,'knn') 
    pred = knnpred(Xgrid,model.settings.raw_data,model.settings.class,model.settings.K,model.settings.dist_type,model.settings.pret_type);
    P = reshape(pred.class_pred, [length(x) length(y)]);
elseif strcmp(model.type,'svm')
    if isstruct(model.settings.model_pca) && model.settings.num_comp == 2
        [~,dist] = predict(model.settings.net,Xgrid);
        dist = dist(:,2);
    else % on 2D data with 1 PCs
        pred = svmpred(Xgrid,model);
        dist = pred.dist;
    end
    P = reshape(dist, [length(x) length(y)]);
elseif strcmp(model.type,'backprop')
    pred = backpropagationpred(Xgrid,model);
    P = reshape(pred.class_pred, [length(x) length(y)]);
else % cart
    pred = cartpred(Xgrid,model);
    P = reshape(pred.class_pred, [length(x) length(y)]);
end

% plot areas
class = model.settings.class;
col_ass = visualize_colors;
figure
set(gcf,'color','white');
hold on
xx = reshape(Xgrid_plot(:,1), [length(x) length(y)]);
yy = reshape(Xgrid_plot(:,2), [length(x) length(y)]);
if strcmp(model.type,'svm')
    contour(xx, yy, P, [1 1], 'b-');
    contour(xx, yy, P, [-1 -1], 'r-');
    contour(xx, yy, P, [0 0], 'k-', 'LineWidth', 2);
elseif strcmp(model.type,'simca') || strcmp(model.type,'uneq') || strcmp(model.type,'pf')
    if length(model.labels.class_labels) > 0
        target_class = find(strcmp(model.settings.target_class,model.labels.class_labels));
    else
        target_class = model.settings.target_class;
    end
    contour(xx, yy, P, [1 1], 'LineColor', col_ass(target_class+1,:), 'LineWidth', 2);
else % plsda, lda, qda, pcalda, pcaqda, knn, cart with predicted class labels
    draw_class = zeros(max(class),1);
    for g=1:max(class)
        Ptmp = P;
        Ptmp(find(P~=g)) = 0;
        Ptmp(find(P==g)) = g;
        if length(find(Ptmp>0)) > 0
            % do contourface if samples are assigned to the class
            % e.g. 2 PC scores on Iris, PLSDA 1 LVs, bayes assignation, class
            % 3 is not assigned at all
            contourf(xx, yy, Ptmp, [g g]);
            draw_class(g) = 1;
        end
    end
    colormap(col_ass(find(draw_class) + 1,:))
end

% plot samples and sv
if strcmp(model.type,'svm')
    for g=1:max(class)
        inclass = find(class==g);
        a = find(class(model.svind)==g);
        svinclass = model.svind(a);
        plot(Xplot(inclass,1),Xplot(inclass,2),'o','MarkerEdgeColor',col_ass(g+1,:),'MarkerSize',5,'MarkerFaceColor','w')
        plot(Xplot(svinclass,1),Xplot(svinclass,2),'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',col_ass(g+1,:))
    end
else
    for g=1:max(class)
        inclass = find(class==g);
        color_in = col_ass(g+1,:);
        plot(Xplot(inclass,1),Xplot(inclass,2),'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',color_in)
    end
end

% plot errors
% err = find(model.class_calc ~= model.settings.class);
% plot(Xplot(err,1),Xplot(err,2),'*','MarkerEdgeColor','k','MarkerSize',3,'MarkerFaceColor','k')

% labels and plot settings
xlabel(variable_labels{1})
ylabel(variable_labels{2})
box on
hold off

%---------------------------------------------------
function [x,y,Xgrid] = makegriddata(X,step)
% make grid
rx = (max(X(:,1)) - min(X(:,1)));
ry = (max(X(:,2)) - min(X(:,2)));
xrange = [min(X(:,1))-rx/5 max(X(:,1))+rx/5];
yrange = [min(X(:,2))-ry/5 max(X(:,2))+ry/5];
x = xrange(1):(xrange(2)-xrange(1))/step:xrange(2);
y = yrange(1):(yrange(2)-yrange(1))/step:yrange(2);
[xx,yy] = meshgrid(x,y);
Xgrid = [xx(:),yy(:)];

%---------------------------------------------------
function variable_labels = getlabels(model)
if length(model.labels.variable_labels) > 0
    variable_labels = model.labels.variable_labels;
else
    for k=1:size(model.settings.raw_data,2); variable_labels{k} = ['variable ' num2str(k)]; end
end
