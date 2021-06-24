function varargout = visualize_gafrequencies(varargin)

% This is an internal routine for the graphical interface of the toolbox.
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

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visualize_gafrequencies_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_gafrequencies_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before visualize_gafrequencies is made visible.
function visualize_gafrequencies_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for visualize_gafrequencies
handles.output = hObject;
handles.ga_res = varargin{1};
handles.variable_labels = varargin{2};
handles.X = varargin{3};
handles.y = varargin{4};
handles.var_selected = NaN;
handles.opt_param = NaN;
% parameters for position
x_position = 3.5;
step_for_text = 1.6;
% set main dimension
handles.manage_size.minimum_size = [0 0 210 40];
set(handles.output,'Position',handles.manage_size.minimum_size);
% uipanel
set(handles.myuipanel,'Position',[3.5 17 30 21]);%17
set(handles.button_allsubset,'Position',[x_position 17.5 23 2]);
set(handles.button_forward,'Position',[x_position 14.5 23 2]);
set(handles.text_freq,'Position',[x_position 9+step_for_text 23 3.5]);
set(handles.pop_freq,'Position',[x_position 9 23 1.5]);
set(handles.button_help,'Position',[x_position 1 23 2]);
set(handles.button_cancel,'Position',[x_position 4 23 2]);
% plot area
[g4] = getplotposition(handles);
set(handles.myplot,'Position',g4);
movegui(handles.visualize_gafrequencies,'center');
g2 = get(handles.myuipanel,'Position');
handles.manage_size.initial_frame = get(handles.output,'Position');
handles.manage_size.initial_height_uipanel = g2(2);
% set combo freq
str_disp={};
freq = [0.00:0.05:0.95];
freq = -sort(-freq);
F = handles.ga_res.num_selection./handles.ga_res.options.runs;
w = find(freq < max(F)-0.001);
freq = freq(w);
for j=1:length(freq)
    str_disp{j} = num2str(freq(j));
end
set(handles.pop_freq,'String',str_disp);
w = round(length(freq)/2);
if w < 1; w = 1; end
set(handles.pop_freq,'Value',w);
% update plot
update_plot(handles,0);
% update handles structure
guidata(hObject, handles);
uiwait(handles.visualize_gafrequencies);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_gafrequencies_OutputFcn(hObject, eventdata, handles) 
len = length(handles);
if len > 0
    varargout{1} = handles.var_selected;
    varargout{2} = handles.opt_param;
    varargout{3} = handles.domodel;
    delete(handles.visualize_gafrequencies)
else
    handles.opt_param = NaN;
    handles.var_selected = NaN;
    handles.domodel = 0;
    varargout{1} = handles.var_selected;
    varargout{2} = handles.opt_param;
    varargout{3} = handles.domodel;
end

% --- Executes when visualize_gafrequencies is resized.
function visualize_gafrequencies_SizeChangedFcn(hObject, eventdata, handles)
if isfield(handles,'output')
    [g2] = getuipanelposition(handles);
    set(handles.myuipanel,'Position',g2);
    [g4] = getplotposition(handles);
    set(handles.myplot,'Position',g4);
end

% ---------------------------------------------------------
function [g2] = getuipanelposition(handles)
g1 = get(handles.output,'Position');
g2 = get(handles.myuipanel,'Position');
g2(2) = handles.manage_size.initial_height_uipanel + g1(4) - handles.manage_size.initial_frame(4);

% ---------------------------------------------------------
function [g4] = getplotposition(handles)
g1 = get(handles.output,'Position');
g2 = get(handles.myuipanel,'Position');
g4 = get(handles.myplot,'Position');
p = (g1(3) - g2(3) - 4*g2(1))/g1(3);
g4(1) = 1 - p;
g4(3) = p*0.95;

% --- Executes on selection change in pop_freq.
function pop_freq_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% --- Executes during object creation, after setting all properties.
function pop_freq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in button_cancel.
function button_cancel_Callback(hObject, eventdata, handles)
handles.domodel = 0;
guidata(hObject,handles)
uiresume(handles.visualize_gafrequencies)

% --- Executes on button press in button_help.
function button_help_Callback(hObject, eventdata, handles)
web('help/gui_calculate.htm','-browser')

% --- Executes on button press in button_allsubset.
function button_allsubset_Callback(hObject, eventdata, handles)
x = get(handles.pop_freq,'Value');
s = get(handles.pop_freq,'String');
thr_freq = str2num(s{x});
[var_selected,opt_param,domodel] = dopostselection('allsubsets',handles.X,handles.y,handles.ga_res,handles.variable_labels,thr_freq);
if domodel
    handles.var_selected = var_selected;
    handles.opt_param = opt_param;
    handles.domodel = domodel;
    guidata(hObject, handles);
    uiresume(handles.visualize_gafrequencies)
end

% --- Executes on button press in button_forward.
function button_forward_Callback(hObject, eventdata, handles)
x = get(handles.pop_freq,'Value');
s = get(handles.pop_freq,'String');
thr_freq = str2num(s{x});
[var_selected,opt_param,domodel] = dopostselection('forward',handles.X,handles.y,handles.ga_res,handles.variable_labels,thr_freq);
if domodel
    handles.var_selected = var_selected;
    handles.opt_param = opt_param;
    handles.domodel = domodel;
    guidata(hObject, handles);
    uiresume(handles.visualize_gafrequencies)
end

% -------------------------------------------------------------------------
function update_plot(handles,external)
[col_ass,col_default] = visualize_colors;
x = get(handles.pop_freq,'Value');
s = get(handles.pop_freq,'String');
thr_freq = str2num(s{x});
max_variable_for_labels = 30;
axes(handles.myplot); 
cla;
F = handles.ga_res.num_selection./handles.ga_res.options.runs;
F(handles.ga_res.var_sorted) = F;
if handles.ga_res.options.num_windows == 1
    variable_labels = handles.variable_labels;
else
    for k=1:length(F); variable_labels{k} = ['W' num2str(k)]; end
end
% do plot
hold on
xlim = [0 length(F) + 1];
ylim = [0 ceil(max(F)*10)/10];
line(xlim,[0.25 0.25],'Color',[0.753 0.753 0.753],'LineStyle',':')
line(xlim,[0.50 0.50],'Color',[0.753 0.753 0.753],'LineStyle',':')
line(xlim,[0.75 0.75],'Color',[0.753 0.753 0.753],'LineStyle',':')
Fred = F;
Fred(find(F > thr_freq + 0.001)) = 0;
bar(Fred,'FaceColor',col_default(1,:),'EdgeColor','k');
Fred = F;
Fred(find(F < thr_freq + 0.001)) = 0;
bar(Fred,'FaceColor',col_ass(3,:),'EdgeColor','k');
% line
line(xlim,[thr_freq thr_freq],'Color','r','LineStyle',':','LineWidth',2)
axis([xlim ylim]);
if handles.ga_res.options.num_windows == 1
    xlabel('variables')
else
    xlabel('windows (intervals of variables)')
end
ylabel('frequency of selection over GA runs')
% variable labels
if length(F) < max_variable_for_labels
    set(gca,'XTick',[1:length(F)])
    set(gca,'XTickLabel',variable_labels)
else
    step = round(length(F)/10);
    set(gca,'XTick',[1:step:length(F)])
    set(gca,'XTickLabel',variable_labels([1:step:length(F)]))
end
box on
hold off

% -------------------------------------------------------------------------
function [var_selected,opt_param,domodel] = dopostselection(selection_type,X,y,ga_res,variable_labels,thr_freq)
max_var_allsubsets = 10;
F = ga_res.num_selection./ga_res.options.runs;
F(ga_res.var_sorted) = F;
var_in = find(F > thr_freq + 0.001);
if ga_res.options.num_windows > 1
    variable_labels_selection = {};
    for k=1:length(F); variable_labels_selection{k} = ['W' num2str(k)]; end
else
    variable_labels_selection = variable_labels;
end
if strcmp('allsubsets',selection_type) && length(var_in) > max_var_allsubsets
    h1 = ['The number of variables to perform all subset selection is limited to ' num2str(max_var_allsubsets) '. Please, increase the frequency threshold to reduce the number of variables to be considered.'];
    warndlg([h1],'Variable selection')
    var_selected = NaN;
    opt_param = NaN;
    domodel = 0;
else
    % do selection with bar
    if strcmp('allsubsets',selection_type)
        res_selection = doallsubset(X,y,var_in,ga_res.options,variable_labels_selection);
    else
        res_selection = doforward(X,y,var_in,ga_res.options,variable_labels_selection);
    end
    if ga_res.options.num_windows > 1
        % take original variables, not windows
        for k=1:length(res_selection)
            W = ga_windows([1:size(X,2)],res_selection(k).selected_variables,ga_res.options.num_windows);
            res_selection(k).selected_variables = W;
            res_selection(k).selected_variables_labels = variable_labels(W);
        end
    end
    % open gaselection
    [var_selected,opt_param,domodel] = visualize_gaselection(res_selection,X,variable_labels,ga_res.options);
end

% -------------------------------------------------------------------------
function res = doallsubset(X,y,var_in,options,variable_labels)
cnt_var = 0;
count_models = 0;
total_models = 0;
% count total models to be calculated
for k=1:length(var_in)
    C = nchoosek(var_in,k);
    total_models = total_models + size(C,1);
end
hwait = waitbar(0,'all subsets selection');
for k=1:length(var_in)
    C = nchoosek(var_in,k);
    r2 = []; rmse = []; r2cv = []; rmsecv = []; param = []; selected_variables = {}; selected_variables_labels = {};
    for a=1:size(C,1)
        count_models = count_models + 1;
        waitbar(count_models/total_models);
        test_varhere = C(a,:);
        [r2cvhere,paramhere,~,rmsecvhere,r2here,rmsehere] = ga_cv(X,y,test_varhere,options,options.max_param);
        selected_variables{a,1} = test_varhere;
        selected_variables_labels{a,1} = variable_labels(test_varhere);
        r2cv(a,1) = r2cvhere;
        rmsecv(a,1) = rmsecvhere;
        r2(a,1) = r2here;
        rmse(a,1) = rmsehere;        
        param(a,1) = paramhere;
    end
    [m,s] = sort(r2cv,1,'descend');
    if size(C,1) > 3
        model_to_store_for_dimension = 3;
    else
        model_to_store_for_dimension = size(C,1);
    end
    for g =1:model_to_store_for_dimension
        cnt_var = cnt_var + 1;
        res(cnt_var,1).r2cv = r2cv(s(g),1);
        res(cnt_var,1).rmsecv = rmsecv(s(g),1);
        res(cnt_var,1).r2 = r2(s(g),1);
        res(cnt_var,1).rmse = rmse(s(g),1);        
        res(cnt_var,1).selected_variables = selected_variables{s(g)};
        res(cnt_var,1).selected_variables_labels = selected_variables_labels{s(g)};
        res(cnt_var,1).param = param(s(g),1);
        res(cnt_var,1).selected_windows = length(selected_variables{s(g)});
    end
end
delete(hwait);

% -------------------------------------------------------------------------
function res = doforward(X,y,var_in,options,variable_labels)
total_models = length(var_in);
count_models = 0;
hwait = waitbar(0,'forward selection');
goon = 1;
cnt_var = 0;
var_included = [];
while goon && length(var_included) < length(var_in)
    goon = 0;
    best_resp = 0;
    for k = 1:length(var_in)
        count_models = count_models + 1;
        waitbar(count_models/total_models);
        if length(find(var_included == var_in(k))) < 1
            test_var = [var_included var_in(k)];
            [r2cvhere,paramhere,~,rmsecvhere,r2here,rmsehere] = ga_cv(X,y,test_var,options,options.max_param);
            if r2cvhere >= best_resp
                goon = 1;
                best_resp = r2cvhere;
                best_param = paramhere;
                best_rmsecv = rmsecvhere;
                best_r2 = r2here;
                best_rmse = rmsehere;
                sel_var = var_in(k);
            end
        end
    end
    if goon == 1
        cnt_var = cnt_var + 1;
        var_included = [var_included sel_var];
        res(cnt_var,1).r2cv = best_resp;
        res(cnt_var,1).rmsecv = best_rmsecv;
        res(cnt_var,1).r2 = best_r2;
        res(cnt_var,1).rmse = best_rmse;            
        res(cnt_var,1).selected_variables = var_included;
        res(cnt_var,1).selected_variables_labels = variable_labels(var_included);
        res(cnt_var,1).param = best_param;
        res(cnt_var,1).selected_windows = length(var_included);
    end
end
delete(hwait);
