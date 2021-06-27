function model = backpropagationfit(X,class,settings)

% fit Backpropagation Neural Networks (BPNN)
%
% model = backpropagationfit(X,class,settings)
%
% INPUT:            
% X                 dataset [samples x variables]
% class             class vector, class labels can be 
%                   - numerical. The class vector is a numerical vector [samples x 1]. If G classes are present, class labels must range from 1 to G (0 values are not allowed)
%                   - strings. The class vector is a cell array containing the class labels {samples x 1}
% settings          networks settings, defined with the backpropagationsettings routine
%
% OUTPUT:
% model is a structure containing the following fields:
% class_calc        predicted class as numerical vector [samples x 1]
% class_calc_string predicted class as string vector {samples x 1}
%                   (available only if the class input vector is a cell array with strings as class labels)
% class_param       structure with classification measures 
%                   (error rate, confusion matrix, specificity, sensitivity, precision)
% output_pred       predicted output [samples x classes]
% W                 network weights (for hidden layers)
% settings          structure with model settings
%
% RELATED ROUTINES:
% backpropagationpred       prediction of classes of new samples with Backpropagation Neural Networks (BPNN)
% backpropagationcv         cross-validatation of Backpropagation Neural Networks (BPNN)
% backpropagationsettings   define netwrok settings
% class_gui                 main routine to open the graphical interface
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

if iscell(class)
    class_string = class;
    [class,class_labels] = calc_class_string(class_string);
else
    class_string = {};
    class_labels = {};
end
% backpropagation settings
scaling = 'auto';
num_hidden_neurons = settings.num_hidden_neurons;
learning_rate = settings.learning_rate; 
alpha = settings.alpha;                          
iter_max = settings.iter;
assignation_type = settings.assignation_type;
doplot = settings.doplot;

output = zeros(size(X,1),max(class));
for g=1:max(class)
    output(find(class==g),g) = 1;
end

%STEP 1 : Normalize the Input
[X_scal,param] = data_pretreatment(X,scaling);
% add ones for bias
X_scal = [X_scal ones(size(X,1),1)];

%Find the size of Input and Output Vectors
num_var = size(X_scal,2);
num_responses = size(output,2);

%Initialize the weight matrices with random weights
init_weights = [num_var num_hidden_neurons num_responses];
for k=1:length(init_weights)-1
    W{k} = randn(init_weights(k),init_weights(k+1));
end

% initialize weights
for k=1:length(W); delta_W{k} = zeros(size(W{k})); end
iter = 0;
error_latest = 1;
%Calling function for training the neural network
if doplot; figure; set(gcf,'color','white'); end
while iter < iter_max
    iter = iter + 1;
    % Change the weight metrix W by adding delta values to them
    for k=1:length(W); W{k} = W{k} + delta_W{k}; end
    [error(iter), delta_W, ~,output_pred_tmp] = nettrain(X_scal,output,W,learning_rate,alpha,delta_W);
    error_latest = error(iter);
    if doplot > 0
        thr_tmp = findthr(output_pred_tmp{end},class,1);
        class_calc_tmp = backpropagationfindclass(output_pred_tmp{end},thr_tmp.class_thr,assignation_type,output_pred_tmp{end});
        class_param_tmp = calc_class_param(class_calc_tmp,class);
        ner(iter) = class_param_tmp.ner;
        sensitivity(iter,:) = class_param_tmp.sensitivity;
        if doplot > 1
            updateplot(error(1:iter),1,iter_max,ner,sensitivity);
        end
    end
end
output_pred = backpropagationproject(X_scal,W);
res = findthr(output_pred{end},class);
class_calc = backpropagationfindclass(output_pred{end},res.class_thr,assignation_type,output_pred{end});
class_param = calc_class_param(class_calc,class);
if doplot > 0; updateplot(error(1:iter),1,iter_max,ner,sensitivity);end
model.type = 'backprop';
model.W = W;
model.output_pred = output_pred{end};
model.class_calc = class_calc;
if length(class_labels) > 0
    model.class_calc_string = calc_class_string(model.class_calc,class_labels);
end
model.class_param = class_param;
model.settings.network_settings = settings;
model.settings.param = param;
model.settings.thr = res.class_thr;
model.settings.thr_val = res.thr_val';
model.settings.sp = res.sp;
model.settings.sn = res.sn;
model.settings.error = error;
model.settings.raw_data = X;
model.settings.class = class;
model.cv = [];
model.labels.variable_labels = {};
model.labels.sample_labels = {};
model.labels.class_labels = class_labels;

end

%--------------------------------------------------------------------------
function [E, delta_W, residuals, Output_of_HiddenLayer] = nettrain(X,Output,W,learning_rate,alpha,delta_W)
%Calculating the Output of Input Layer
%Output of Input Layer is same as the Input of Input  Layer
[Output_of_HiddenLayer,Input_of_HiddenLayer] = backpropagationproject(X,W);
%Now we need to calculate the Error using Root Mean Square method
[E, residuals] = calc_errors(Output,Output_of_HiddenLayer{end});
%Calculate the matrix 'd' with respect to the desired output
d = (Output - Output_of_HiddenLayer{end});
d = d.*Output_of_HiddenLayer{end};
d = d.*(1-Output_of_HiddenLayer{end});
%Calculating delta output layer
delta_W{end} = alpha*delta_W{end} + learning_rate.*(d'*Output_of_HiddenLayer{end-1})';
%Calculating error matrix
error = (W{end}*d')';
for k = 1:length(W) - 2
    %Calculating d*
    d_star = [];
    d_star = error.*Output_of_HiddenLayer{end-k};
    d_star = d_star.*(1-Output_of_HiddenLayer{end-k});
    %Calculating delta W
    delta_W{end-k} = alpha*delta_W{end-k} + learning_rate*Input_of_HiddenLayer{end-k-1}'*d_star;
    % updating error for next correction 
    error = (W{end-k}*d_star')';
end
d_star = [];
d_star = error.*Output_of_HiddenLayer{1};
d_star = d_star.*(1-Output_of_HiddenLayer{1});
% Calculating delta W
s1 = alpha*delta_W{1};
s2 = X'*d_star;
delta_W{1} = s1+learning_rate*s2;
end

%--------------------------------------------------------------------------
function [E, residuals] = calc_errors(Output,Output_of_HiddenLayer)
difference = Output - Output_of_HiddenLayer;
square = difference.*difference;
E = sum(square(:))/size(Output,1);
residuals = sum(square,2);
end

%--------------------------------------------------------------------------
function res = findthr(yc,class,dofast)
if nargin < 3
    dofast = 0;
end
if dofast == 0
    rsize = 100;
else
    rsize = 50;
end
for g=1:size(yc,2)
    class_in = ones(size(class,1),1);
    class_in(find(class ~= g)) = 2;
    count = 0;
    y_in = yc(:,g);
    miny = min(min(yc)) - min(min(yc))/10;
    thr = max(max(yc)) + max(max(yc))/10;
    step = (thr - miny)/rsize;
    samples_g = length(find(class_in==1));
    samples_notg = length(find(class_in~=1));
    while thr > miny
        count = count + 1;
        class_calc_in = ones(size(class,1),1);
        thr = thr - step;
        sample_out_g = find(y_in < thr);
        class_calc_in(sample_out_g) = 2;
        sn(count,g) = length(find(class_in==1 & class_calc_in==1))/samples_g;
        sp(count,g) = length(find(class_in~=1 & class_calc_in~=1))/samples_notg;        
        thr_val(count,g) = thr;
    end
    res.class_thr(g) = findbestthr(sn(:,g),sp(:,g),thr_val(:,g));
end
res.sp = sp;
res.sn = sn;
res.thr_val = thr_val;
end

% -------------------------------------------------------------------
function thr = findbestthr(sn,sp,thr_val)
f = find(sn == sp);
if length(f) > 0
    % look if sn and sp are equal for a range of thr values
    % takes the intermediate
    r = round(length(f)/2);
    f = f(r);
else
    % otherwise takes first value where sn > sp
    f = find(sn > sp);
    f = f(1);
end
thr = thr_val(f);
end

%--------------------------------------------------------------------------
function updateplot(error,start_epoch,end_epoch,ner,sensitivity)
% plot residuals
subplot(2,1,1)
drawnow
cla
hold on
c1 = [0,0.447,0.741];
plot(error,'LineWidth',1.5,'Color',c1);
plot(length(error),error(end),'o','MarkerEdgeColor',c1,'MarkerSize',4,'MarkerFaceColor',c1);
% grid and axis
grid on
ax = gca;
ax.GridLineStyle = ':';
ax.GridAlpha = 0.5;
M = max(error); M = M*1.1;
axis([start_epoch end_epoch 0 M])
ylabel('error')
xlabel('epochs')
title(['training epochs: ' num2str(length(error)) ' of ' num2str(end_epoch)])
hold off
box on
% plot ner
subplot(2,1,2)
drawnow
cla
hold on
c2 = [0.8500 0.3250 0.0980];
c3 = [1 0.6 0.4];
for g=1:size(sensitivity,2)
    plot(sensitivity(:,g),'LineWidth',1,'Color',c3);
    plot(length(ner),sensitivity(end,g),'o','MarkerEdgeColor',c3,'MarkerSize',2.5,'MarkerFaceColor',c3);
end
plot(ner,'LineWidth',1.5,'Color',c2);
plot(length(ner),ner(end),'o','MarkerEdgeColor',c2,'MarkerSize',4,'MarkerFaceColor',c2);
grid on
ax = gca;
ax.GridLineStyle = ':';
ax.GridAlpha = 0.5;
m = min(ner); m = m*0.9;
if isnan(m); m = 0; end
axis([start_epoch end_epoch m 1])
ylabel('NER and sensitivities')
xlabel('epochs')
hold off
box on
end