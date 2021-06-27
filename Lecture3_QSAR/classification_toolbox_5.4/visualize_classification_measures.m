function varargout = visualize_classification_measures(varargin)

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

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visualize_classification_measures_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_classification_measures_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before visualize_classification_measures is made visible.
function visualize_classification_measures_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
movegui(handles.visualize_classification_measures,'center');

handles.model = varargin{1};
handles.pred = varargin{2};
handles.cv = handles.model.cv;

% parameters for positions
x_position = 1.5;
x_position_button = 67;
text_error_position = [1 2.2 25 4.5];
param_position = [24.5 0.6 36 6];
panel_width = 63;
panel_height = 8.5;
% set dimensions
height_form = 18.5;    % only fit results
if isstruct(handles.pred)
    if isfield(handles.pred,'class_param')
        height_form = 28;    % both fit, cv and pred results
    end
end
% set positions
set(hObject,'Position',[103.8571 53.8 94 height_form]);
set(handles.training_text_error,'Position',text_error_position);
set(handles.training_table_param,'Position',param_position);
set(handles.cv_text_error,'Position',text_error_position);
set(handles.cv_table_param,'Position',param_position);
set(handles.pred_text_error,'Position',text_error_position);
set(handles.pred_table_param,'Position',param_position);
% set buttons and panel
set(handles.button_help,'Position',[x_position_button height_form-12 24 2]);
set(handles.button_class_calc,'Position',[x_position_button height_form-9 24 2]);
set(handles.button_view_cm,'Position',[x_position_button height_form-3 24 2]);
set(handles.button_class_measures,'Position',[x_position_button height_form-6 24 2]);
set(handles.panel_training,'Position',[x_position height_form-9 panel_width panel_height]);
set(handles.panel_cv,'Position',[x_position height_form-18 panel_width panel_height]);
set(handles.panel_pred,'Position',[x_position height_form-27 panel_width panel_height]);
movegui(handles.visualize_classification_measures,'center')
% update
handles = update_fitting(handles);
handles = update_cv(handles);
if isstruct(handles.pred)
    if isfield(handles.pred,'class_param')
        handles = update_pred(handles);
    end
end
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_classification_measures_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% --- Executes on button press in button_class_measures.
function button_class_measures_Callback(hObject, eventdata, handles)
[~,table_sp] = update_fitting(handles);
assignin('base','tmp_class_measures_training',table_sp);
openvar('tmp_class_measures_training');
if isstruct(handles.cv)
    [~,table_sp] = update_cv(handles);
    assignin('base','tmp_class_measures_cv',table_sp);
    openvar('tmp_class_measures_cv');
end
if isstruct(handles.pred)
    if isfield(handles.pred,'class_param')
        [~,table_sp] = update_pred(handles);
        assignin('base','tmp_class_measures_test',table_sp);
        openvar('tmp_class_measures_test');
    end
end

% --- Executes on button press in button_class_calc.
function button_class_calc_Callback(hObject, eventdata, handles)
if length(handles.model.labels.class_labels) == 0
    assignin('base','tmp_predicted_class_training',handles.model.class_calc);
    openvar('tmp_predicted_class_training');
    if isstruct(handles.cv)
        assignin('base','tmp_predicted_class_cv',handles.cv.class_pred);
        openvar('tmp_predicted_class_cv');
    end
    if isstruct(handles.pred)
        assignin('base','tmp_predicted_class_test',handles.pred.class_pred);
        openvar('tmp_predicted_class_test');
    end
else
    assignin('base','tmp_predicted_class_training',handles.model.class_calc_string);
    openvar('tmp_predicted_class_training');
    if isstruct(handles.cv)
        assignin('base','tmp_predicted_class_cv',handles.cv.class_pred_string);
        openvar('tmp_predicted_class_cv');
    end
    if isstruct(handles.pred)
        assignin('base','tmp_predicted_class_test',handles.pred.class_pred_string);
        openvar('tmp_predicted_class_test');
    end
end

% --- Executes on button press in button_view_cm.
function button_view_cm_Callback(hObject, eventdata, handles)
if strcmp(handles.model.type,'simca') || strcmp(handles.model.type,'uneq') || strcmp(handles.model.type,'pf')
    class_labels = handles.model.labels.class_labels_classmodelling;
    target_class = handles.model.settings.target_class;
else
    class_labels = handles.model.labels.class_labels;
    target_class = NaN;
end
conf_mat = print_conf_mat(handles.model.class_param.conf_mat,class_labels,handles.model.type,target_class);
assignin('base','tmp_confusion_matrix_training',conf_mat);
openvar('tmp_confusion_matrix_training');
if isstruct(handles.cv)
    conf_mat = print_conf_mat(handles.cv.class_param.conf_mat,class_labels,handles.model.type,target_class);
    assignin('base','tmp_confusion_matrix_cv',conf_mat);
    openvar('tmp_confusion_matrix_cv');
end
if isstruct(handles.pred)
    conf_mat = print_conf_mat(handles.pred.class_param.conf_mat,class_labels,handles.model.type,target_class);
    assignin('base','tmp_confusion_matrix_test',conf_mat);
    openvar('tmp_confusion_matrix_test');
end

% --- Executes on button press in button_help.
function button_help_Callback(hObject, eventdata, handles)
web('help/classparameters.htm','-browser')

% -------------------------------------------------------------------------
function [handles,table_sp] = update_pred(handles)
class_param = handles.pred.class_param;
nformat2 = '%1.2f';
er  = sprintf(nformat2,class_param.er);
ner = sprintf(nformat2,class_param.ner);    
na  = sprintf(nformat2,class_param.not_ass);
ac  = sprintf(nformat2,class_param.accuracy);
na_num = class_param.not_ass;
sp  = class_param.specificity;
sn  = class_param.sensitivity;
pr  = class_param.precision;
if strcmp(handles.model.type,'simca') || strcmp(handles.model.type,'uneq') || strcmp(handles.model.type,'pf')
    num_class = 1;
else
    num_class = length(sn);
end
% error rates
str_er{1} = ['error rate: ' er];
str_er{2} = ['non-error rate: ' ner];
str_er{3} = ['accuracy: ' ac];
if na_num > 0
    str_er{4} = ['not-assigned: ' na];
end
table_sp{1,1} = 'class'; table_sp{1,2} = 'sensitivity';
table_sp{1,3} = 'specificity'; table_sp{1,4} = 'precision';
for k=1:num_class
    if length(handles.model.labels.class_labels) == 0
        if strcmp(handles.model.type,'simca') || strcmp(handles.model.type,'uneq') || strcmp(handles.model.type,'pf')
            class_labels{k} = ['class ' num2str(handles.model.settings.target_class) ' (target)'];
        else
            class_labels{k} = ['class ' num2str(k)];
        end
    else
        if strcmp(handles.model.type,'simca') || strcmp(handles.model.type,'uneq') || strcmp(handles.model.type,'pf')
            class_labels{k} = handles.model.labels.class_labels_classmodelling{k};
        else
            class_labels{k} = handles.model.labels.class_labels{k};
        end
    end
    sp_in = sprintf(nformat2,sp(k));
    sn_in = sprintf(nformat2,sn(k));
    pr_in = sprintf(nformat2,pr(k));
    table_sp{k+1,1} = class_labels{k};
    table_sp{k+1,2} = sn_in;
    table_sp{k+1,3} = sp_in;
    table_sp{k+1,4} = pr_in;
end
set(handles.pred_text_error,'String',str_er);
handles.pred_table_param.ColumnName = {'class';'sens';'spec';'prec'};
handles.pred_table_param.ColumnWidth = {55 40 40 40};
handles.pred_table_param.RowName = {};
handles.pred_table_param.RowStriping = 'off';
str_sp = table_sp(2:end,:);
handles.pred_table_param.Data = str_sp;

% -------------------------------------------------------------------------
function [handles,table_sp] = update_cv(handles)
if isstruct(handles.cv)
    nformat2 = '%1.2f';
    er  = sprintf(nformat2,handles.cv.class_param.er);
    ner = sprintf(nformat2,handles.cv.class_param.ner);
    na  = sprintf(nformat2,handles.cv.class_param.not_ass);
    ac  = sprintf(nformat2,handles.cv.class_param.accuracy);
    na_num = handles.cv.class_param.not_ass;
    sp  = handles.cv.class_param.specificity;
    sn  = handles.cv.class_param.sensitivity;
    pr  = handles.cv.class_param.precision;
    if strcmp(handles.model.type,'simca') || strcmp(handles.model.type,'uneq') || strcmp(handles.model.type,'pf')
        num_class = 1;
    else
        num_class = length(sn);
    end
    % error rates
    str_er{1} = ['error rate: ' er];
    str_er{2} = ['non-error rate: ' ner];
    str_er{3} = ['accuracy: ' ac];
    if na_num > 0
        str_er{4} = ['not-assigned: ' na];
    end 
    table_sp{1,1} = 'class'; table_sp{1,2} = 'sensitivity'; 
    table_sp{1,3} = 'specificity'; table_sp{1,4} = 'precision'; 
    for k=1:num_class
        if length(handles.model.labels.class_labels) == 0
            if strcmp(handles.model.type,'simca') || strcmp(handles.model.type,'uneq') || strcmp(handles.model.type,'pf')
                class_labels{k} = ['class ' num2str(handles.model.settings.target_class) ' (target)'];
            else
                class_labels{k} = ['class ' num2str(k)];
            end
        else
            if strcmp(handles.model.type,'simca') || strcmp(handles.model.type,'uneq') || strcmp(handles.model.type,'pf')
                class_labels{k} = handles.model.labels.class_labels_classmodelling{k};
            else
                class_labels{k} = handles.model.labels.class_labels{k};
            end
        end
        sp_in = sprintf(nformat2,sp(k));
        sn_in = sprintf(nformat2,sn(k));
        pr_in = sprintf(nformat2,pr(k));
        table_sp{k+1,1} = class_labels{k};
        table_sp{k+1,2} = sn_in;
        table_sp{k+1,3} = sp_in;
        table_sp{k+1,4} = pr_in;
    end
    set(handles.cv_text_error,'String',str_er);
    handles.cv_table_param.ColumnName = {'class';'sens';'spec';'prec'};
    handles.cv_table_param.ColumnWidth = {55 40 40 40};
    handles.cv_table_param.RowName = {};
    handles.cv_table_param.RowStriping = 'off';
    str_sp = table_sp(2:end,:);
    handles.cv_table_param.Data = str_sp;
    handles.cv_table_param.Visible = 'on';
else
    str_er = 'not calculated';
    str_sp = '';
    set(handles.cv_text_error,'String',str_er);
    handles.cv_table_param.ColumnName = {' ';' ';' ';' '};
    handles.cv_table_param.ColumnWidth = {55 40 40 40};
    handles.cv_table_param.RowName = {};
    handles.cv_table_param.RowStriping = 'off';
    handles.cv_table_param.Data = str_sp;
    handles.cv_table_param.Visible = 'off';
end

% -------------------------------------------------------------------------
function [handles,table_sp] = update_fitting(handles)
nformat2 = '%1.2f';
er  = sprintf(nformat2,handles.model.class_param.er);
ner = sprintf(nformat2,handles.model.class_param.ner);    
na  = sprintf(nformat2,handles.model.class_param.not_ass);
ac = sprintf(nformat2,handles.model.class_param.accuracy);
na_num = handles.model.class_param.not_ass;
sp  = handles.model.class_param.specificity;
sn  = handles.model.class_param.sensitivity;
pr  = handles.model.class_param.precision;
if strcmp(handles.model.type,'simca') || strcmp(handles.model.type,'uneq') || strcmp(handles.model.type,'pf')
    num_class = 1;
else
    num_class = length(sn);
end
% error rates
str_er{1} = ['error rate: ' er];
str_er{2} = ['non-error rate: ' ner];
str_er{3} = ['accuracy: ' ac];
if na_num > 0
    str_er{4} = ['not-assigned: ' na];
end
table_sp{1,1} = 'class'; table_sp{1,2} = 'sensitivity'; 
table_sp{1,3} = 'specificity'; table_sp{1,4} = 'precision'; 
for k=1:num_class
    if length(handles.model.labels.class_labels) == 0
        if strcmp(handles.model.type,'simca') || strcmp(handles.model.type,'uneq') || strcmp(handles.model.type,'pf')
            class_labels{k} = ['class ' num2str(handles.model.settings.target_class) ' (target)'];
        else
            class_labels{k} = ['class ' num2str(k)];
        end
    else
        if strcmp(handles.model.type,'simca') || strcmp(handles.model.type,'uneq') || strcmp(handles.model.type,'pf')
            class_labels{k} = handles.model.labels.class_labels_classmodelling{k};
        else
            class_labels{k} = handles.model.labels.class_labels{k};
        end
    end
    sp_in = sprintf(nformat2,sp(k));
    sn_in = sprintf(nformat2,sn(k));
    pr_in = sprintf(nformat2,pr(k));
    table_sp{k+1,1} = class_labels{k};
    table_sp{k+1,2} = sn_in;
    table_sp{k+1,3} = sp_in;
    table_sp{k+1,4} = pr_in;
end
set(handles.training_text_error,'String',str_er);
handles.training_table_param.ColumnName = {'class';'sens';'spec';'prec'};
handles.training_table_param.ColumnWidth = {55 40 40 40};
handles.training_table_param.RowName = {};
handles.training_table_param.RowStriping = 'off';
str_sp = table_sp(2:end,:);
handles.training_table_param.Data = str_sp;

% -------------------------------------------------------------------------
function S = print_conf_mat(conf_mat,class_labels,model_type,target_class)
S{1,1} = 'real/predicted';
for g=1:size(conf_mat,1)
    if length(class_labels) == 0
        if strcmp(model_type,'simca') || strcmp(model_type,'uneq') || strcmp(model_type,'pf')
            if g == 1
                S{1,g+1} = ['class ' num2str(target_class) ' (target)'];
            else
                S{1,g+1} = ['class not ' num2str(target_class)];
            end
        else
            S{1,g+1} = ['class ' num2str(g)];
        end
    else
        S{1,g+1} = class_labels{g};    
    end
end
S{1,size(conf_mat,1) + 2}=['not assigned']; 
for g=1:size(conf_mat,1)
    if length(class_labels) == 0
        if strcmp(model_type,'simca') || strcmp(model_type,'uneq') || strcmp(model_type,'pf')
            if g == 1
                S{g+1,1} = ['class ' num2str(target_class) ' (target)'];
            else
                S{g+1,1} = ['class not ' num2str(target_class)];
            end
        else
            S{g+1,1} = ['class ' num2str(g)];
        end
    else
        S{g+1,1} = class_labels{g};
    end
    for k=1:size(conf_mat,2)
        S{g+1,k+1} = num2str(conf_mat(g,k));    
    end
end
