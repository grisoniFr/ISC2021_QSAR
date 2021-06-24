function varargout = visualize_settings_big(varargin)

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
% version 5.2 - November 2018
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visualize_settings_big_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_settings_big_OutputFcn, ...
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


% --- Executes just before visualize_settings_big is made visible.
function visualize_settings_big_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% get inputs
handles.model_type = varargin{1};
handles.num_samples = varargin{2};
handles.model_is_present = varargin{3};
handles.model_loaded = varargin{4};
handles.maxparam = varargin{5};
handles.disable_combo = varargin{6};
% parameters for positions
x_position = 3.5;
x_position_button = 50;
y_position = [25.2 21.2 17.2 13.2 9.2 5.2 1.2];
translate_form = 7.5;
step_for_text = 1.8;
% reorder list of popup menu
if strcmp(handles.model_type,'svm')
    y_position = y_position([6 7 4 5 1 2 3]);
    translate_form = 0;
elseif strcmp(handles.model_type,'plsda') || strcmp(handles.model_type,'pcada')
    y_position = y_position([4 5 1 2 3 6 7]);
elseif strcmp(handles.model_type,'knn')
    y_position = y_position([4 5 1 2 3 6 7]);
end
y_position = y_position - translate_form;
% set positions
set(hObject,'Position',[103.8571 45.4706 70 32-translate_form]);
set(handles.text01,'Position',[x_position y_position(1)+step_for_text 33 1.1]);
set(handles.pop_menu_cv_type,'Position',[x_position y_position(1) 33 1.7]);
set(handles.text02,'Position',[x_position y_position(2)+step_for_text 33 1.1]);
set(handles.pop_menu_cv_groups,'Position',[x_position y_position(2) 33 1.7]);
set(handles.text03,'Position',[x_position y_position(3)+step_for_text 33 1.1]);
set(handles.pop_menu_03,'Position',[x_position y_position(3) 33 1.7]);
set(handles.text04,'Position',[x_position y_position(4)+step_for_text 33 1.1]);
set(handles.pop_menu_04,'Position',[x_position y_position(4) 33 1.7]);
set(handles.text05,'Position',[x_position y_position(5)+step_for_text 33 1.1]);
set(handles.pop_menu_05,'Position',[x_position y_position(5) 33 1.7]);
set(handles.text06,'Position',[x_position y_position(6)+step_for_text 33 1.1]);
set(handles.pop_menu_06,'Position',[x_position y_position(6) 33 1.7]);
set(handles.text07,'Position',[x_position y_position(7)+step_for_text 33 1.1]);
set(handles.pop_menu_07,'Position',[x_position y_position(7) 33 1.7]);
% set buttons and panel
set(handles.button_help,'Position',[x_position_button 23-translate_form 17 2]);
set(handles.button_cancel,'Position',[x_position_button 26-translate_form 17 2]);
set(handles.button_calculate_model,'Position',[x_position_button 29-translate_form 17 2]);
set(handles.panel_settings,'Position',[3 1.4 42 30-translate_form]);
movegui(handles.visualize_settings_big,'center')

% set cv type combo
str_disp={};
str_disp{1} = 'none';
str_disp{2} = 'venetian blinds cross validation';
str_disp{3} = 'contiguous blocks cross validation';
if handles.disable_combo == 0 % only if no optimisation is needed
    str_disp{4} = 'montecarlo 20% out';
    str_disp{5} = 'bootstrap';
end
set(handles.pop_menu_cv_type,'String',str_disp);
set(handles.pop_menu_cv_type,'Value',2);

% set cv groups combo
handles = set_cvgroups_combo(handles);
% customize window
handles = custom_form(handles);
% initialize values
handles.domodel = 0;
% enable/disable combo
handles = enable_disable(handles);
guidata(hObject, handles);
uiwait(handles.visualize_settings_big);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_settings_big_OutputFcn(hObject, eventdata, handles)
len = length(handles);
if len > 0
    w = get(handles.pop_menu_cv_groups,'Value');
    cv_groups = get(handles.pop_menu_cv_groups,'String');
    cv_groups = cv_groups{w};
    cv_groups = str2num(cv_groups);
    varargout{1} = cv_groups;
    if get(handles.pop_menu_cv_type,'Value') == 1
        set_this = 'none';
    elseif get(handles.pop_menu_cv_type,'Value') == 2
        set_this = 'vene';
    elseif get(handles.pop_menu_cv_type,'Value') == 3
        set_this = 'cont'; 
    elseif get(handles.pop_menu_cv_type,'Value') == 4
        set_this = 'rand';
    else
        set_this = 'boot';
    end
    varargout{2} = set_this;
    varargout{3} = takevaluefrompopmenu(get(handles.pop_menu_03,'String'),get(handles.pop_menu_03,'Value'));
    varargout{4} = takevaluefrompopmenu(get(handles.pop_menu_04,'String'),get(handles.pop_menu_04,'Value'));
    varargout{5} = takevaluefrompopmenu(get(handles.pop_menu_05,'String'),get(handles.pop_menu_05,'Value'));
    varargout{6} = takevaluefrompopmenu(get(handles.pop_menu_06,'String'),get(handles.pop_menu_06,'Value'));
    varargout{7} = takevaluefrompopmenu(get(handles.pop_menu_07,'String'),get(handles.pop_menu_07,'Value'));
    varargout{8} = handles.domodel;
    delete(handles.visualize_settings_big)
else
    handles.settings.cv_groups = NaN;
    handles.settings.cv_type = NaN;
    handles.domodel = 0;
    varargout{1} = handles.settings.cv_groups;
    varargout{2} = handles.settings.cv_type;
    varargout{3} = 0;
    varargout{4} = 0;
    varargout{5} = 0;
    varargout{6} = 0;
    varargout{7} = 0;
    varargout{8} = handles.domodel;
end

% --- Executes on button press in button_calculate_model.
function button_calculate_model_Callback(hObject, eventdata, handles)
handles.domodel = 1;
guidata(hObject,handles)
uiresume(handles.visualize_settings_big)

% --- Executes on button press in button_cancel.
function button_cancel_Callback(hObject, eventdata, handles)
handles.settings = NaN;
guidata(hObject,handles)
uiresume(handles.visualize_settings_big)

% --- Executes on button press in button_help.
function button_help_Callback(hObject, eventdata, handles)
web('help/gui_calculate.htm','-browser')

% --- Executes during object creation, after setting all properties.
function pop_menu_cv_groups_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in pop_menu_cv_groups.
function pop_menu_cv_groups_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_cv_type_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in pop_menu_cv_type.
function pop_menu_cv_type_Callback(hObject, eventdata, handles)
handles = set_cvgroups_combo(handles);
handles = enable_disable(handles);
guidata(hObject,handles)

% --- Executes on selection change in pop_menu_04.
function pop_menu_04_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_04_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_05.
function pop_menu_05_Callback(hObject, eventdata, handles)
if strcmp(handles.model_type,'svm')
    handles = setparamcombo(handles,NaN);
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_05_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_06.
function pop_menu_06_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_06_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_07.
function pop_menu_07_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_07_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ------------------------------------------------------------------------
function A = takevaluefrompopmenu(list,val)
A = list(val);
A = cell2mat(A);
[num, status] = str2num(A);
if ischar(A)
    if strcmp(A,'linear')
        status = 0;
    end
end
if status
    A = num;
else
    % exceptions
    if strcmp(A,'mean centering')
        A = 'cent';
    elseif strcmp(A,'autoscaling')
        A = 'auto';
    elseif strcmp(A,'gaussian')
        A = 'gaus';
    elseif strcmp(A,'triangular')
        A = 'tria';
    end
end

% ------------------------------------------------------------------------
function handles = enable_disable(handles)
val = get(handles.pop_menu_cv_type,'value');
if val == 1
    set(handles.pop_menu_cv_groups,'Enable','off');    
else
    set(handles.pop_menu_cv_groups,'Enable','on');
end

% ------------------------------------------------------------------------
function handles = custom_form(handles)
% param 
str_param={};
for j=1:handles.maxparam; str_param{j} = num2str(j); end
% memory of loaded model
if handles.model_is_present == 2 && handles.disable_combo == 0 % a model is already calculated
    model_memory = 1;
else
    model_memory = 0;
end
% scaling
str_scaling={};
str_scaling{1} = 'none';
str_scaling{2} = 'mean centering';
str_scaling{3} = 'autoscaling';
if strcmp(handles.model_type,'plsda')
    set(handles.visualize_settings_big,'Name','PLS-DA settings')
    % num comp
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','number of LV:');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param);
    if model_memory && strcmp(handles.model_loaded.type,'plsda')
        set(handles.pop_menu_03,'Value',size(handles.model_loaded.T,2));
    else
        set(handles.pop_menu_03,'Value',length(str_param));
    end
    if handles.disable_combo
        set(handles.pop_menu_03,'Enable','off');
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','data scaling:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && strcmp(handles.model_loaded.type,'plsda')
        if strcmp(handles.model_loaded.settings.pret_type,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.pret_type,'cent')
            set_this = 2;
        else
            set_this = 3;
        end
        set(handles.pop_menu_04,'Value',set_this);
    else
        set(handles.pop_menu_04,'Value',3);
    end
    % assignation
    set(handles.text05,'Visible','on');
    set(handles.text05,'String','assignation criterion:');
    str_disp = {};
    str_disp{1} = 'bayes';
    str_disp{2} = 'max';
    set(handles.pop_menu_05,'Visible','on');
    set(handles.pop_menu_05,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'plsda')
        if strcmp(handles.model_loaded.settings.assign_method,'bayes')
            set(handles.pop_menu_05,'Value',1);
        else
            set(handles.pop_menu_05,'Value',2);
        end
    end
    % disabled
    set(handles.text06,'Visible','off');
    set(handles.pop_menu_06,'String',{'NaN'});
    set(handles.pop_menu_06,'Visible','off');
    set(handles.text07,'Visible','off');
    set(handles.pop_menu_07,'String',{'NaN'});
    set(handles.pop_menu_07,'Visible','off');
elseif strcmp(handles.model_type,'knn')
    set(handles.visualize_settings_big,'Name','k-NN settings')
    % num k
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','number of neighbours (K):');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param);
    if model_memory && strcmp(handles.model_loaded.type,'knn')
        set(handles.pop_menu_03,'Value',handles.model_loaded.settings.K);
    else
        set(handles.pop_menu_03,'Value',length(str_param));
    end
    if handles.disable_combo
        set(handles.pop_menu_03,'Enable','off');
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','data scaling:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && strcmp(handles.model_loaded.type,'knn')
        if strcmp(handles.model_loaded.settings.pret_type,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.pret_type,'cent')
            set_this = 2;
        else
            set_this = 3;
        end
        set(handles.pop_menu_04,'Value',set_this);
    else
        set(handles.pop_menu_04,'Value',3);
    end
    % assignation
    set(handles.text05,'Visible','on');
    set(handles.text05,'String','distance:');
    str_disp={};
    str_disp{1} = 'euclidean';
    str_disp{2} = 'mahalanobis';
    str_disp{3} = 'cityblock';
    str_disp{4} = 'minkowski';
    set(handles.pop_menu_05,'Visible','on');
    set(handles.pop_menu_05,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'knn')
        if strcmp(handles.model_loaded.settings.dist_type,'euclidean')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.dist_type,'mahalanobis')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.dist_type,'cityblock')
            set_this = 3;
        else
            set_this = 4;
        end
        set(handles.pop_menu_05,'Value',set_this);
    end
    % disabled
    set(handles.text06,'Visible','off');
    set(handles.pop_menu_06,'String',{'NaN'});
    set(handles.pop_menu_06,'Visible','off');
    set(handles.text07,'Visible','off');
    set(handles.pop_menu_07,'String',{'NaN'});
    set(handles.pop_menu_07,'Visible','off');
elseif strcmp(handles.model_type,'pcada')
    set(handles.visualize_settings_big,'Name','PCA-DA settings')
    % num comp
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','number of components:');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param);
    if model_memory && (strcmp(handles.model_loaded.type,'pcalda') || strcmp(handles.model_loaded.type,'pcaqda'))
        set(handles.pop_menu_03,'Value',size(handles.model_loaded.settings.modelpca.T,2));
    else
        set(handles.pop_menu_03,'Value',length(str_param));
    end
    if handles.disable_combo
        set(handles.pop_menu_03,'Enable','off');
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','data scaling:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && (strcmp(handles.model_loaded.type,'pcalda') || strcmp(handles.model_loaded.type,'pcaqda'))
        if strcmp(handles.model_loaded.settings.pret_type,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.pret_type,'cent')
            set_this = 2;
        else
            set_this = 3;
        end
        set(handles.pop_menu_04,'Value',set_this);
    else
        set(handles.pop_menu_04,'Value',3);
    end
    % discrimination
    set(handles.text05,'Visible','on');
    set(handles.text05,'String','discrimination:');
    str_disp={};
    str_disp{1} = 'linear';
    str_disp{2} = 'quadratic';
    set(handles.pop_menu_05,'Visible','on');
    set(handles.pop_menu_05,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'pcalda')
        set(handles.pop_menu_05,'Value',1);
    elseif model_memory && strcmp(handles.model_loaded.type,'pcaqda')
        set(handles.pop_menu_05,'Value',2);
    end
    % disabled
    set(handles.text06,'Visible','off');
    set(handles.pop_menu_06,'String',{'NaN'});
    set(handles.pop_menu_06,'Visible','off');
    set(handles.text07,'Visible','off');
    set(handles.pop_menu_07,'String',{'NaN'});
    set(handles.pop_menu_07,'Visible','off');
elseif strcmp(handles.model_type,'svm')
    set(handles.visualize_settings_big,'Name','SVM settings')
    % num comp
    str_param_here{1} = 'none';
    str_param_here{2} = 'automatic';
    for j=3:handles.maxparam+2; str_param_here{j} = num2str(j-2); end
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','Apply on PCs:');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param_here);
    if model_memory && strcmp(handles.model_loaded.type,'svm')
        if isnan(handles.model_loaded.settings.num_comp)
            set_this = 1;
        elseif handles.model_loaded.settings.num_comp == 0
            set_this = 2;
        else
            set_this = handles.model_loaded.settings.num_comp + 2;
        end
        set(handles.pop_menu_03,'Value',set_this);
    else
        set(handles.pop_menu_03,'Value',1);
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','data scaling:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && strcmp(handles.model_loaded.type,'svm')
        if strcmp(handles.model_loaded.settings.pret_type,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.pret_type,'cent')
            set_this = 2;
        else
            set_this = 3;
        end
        set(handles.pop_menu_04,'Value',set_this);
    else
        set(handles.pop_menu_04,'Value',3);
    end
    % kernel type
    set(handles.text05,'Visible','on');
    set(handles.text05,'String','kernel type:');
    str_disp={};
    str_disp{1} = 'linear';
    str_disp{2} = 'polynomial';
    str_disp{3} = 'rbf';
    set(handles.pop_menu_05,'Visible','on');
    set(handles.pop_menu_05,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'svm')
        if strcmp(handles.model_loaded.settings.kernel,'linear')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.kernel,'polynomial')
            set_this = 2;
        else
            set_this = 3;
        end
        set(handles.pop_menu_05,'Value',set_this);
    else
        set(handles.pop_menu_05,'Value',1);
    end
    % kernel parameter
    set(handles.text06,'Visible','on');
    set(handles.text06,'String','kernel parameter:');
    if model_memory && strcmp(handles.model_loaded.type,'svm')
        set_this = handles.model_loaded.settings.kernelpar;
    else
        set_this = NaN;
    end
    handles = setparamcombo(handles,set_this);
    if handles.disable_combo
        set(handles.pop_menu_06,'Enable','off');
    end
    % cost
    set(handles.text07,'Visible','on');
    set(handles.text07,'String','cost:');
    cost_seq = [0.1 1 10 100 1000];
    str_disp={};
    for j=1:length(cost_seq); str_disp{j} = cost_seq(j); end
    set(handles.pop_menu_07,'String',str_disp);
    set(handles.pop_menu_07,'Visible','on');
    set(handles.pop_menu_07,'Value',1);
    if model_memory && strcmp(handles.model_loaded.type,'svm')
        set_this = log10(handles.model_loaded.settings.C) + 2;
        if mod(set_this,1) == 0 
            set(handles.pop_menu_07,'Value',set_this);
        end
    end
    if handles.disable_combo
        set(handles.pop_menu_07,'Enable','off');
    end
end

% --- Executes during object creation, after setting all properties.
function pop_menu_03_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in pop_menu_03.
function pop_menu_03_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function handles = setparamcombo(handles,loaded_param)
% set kernel parameter combo
val = get(handles.pop_menu_05,'string');
w = get(handles.pop_menu_05,'value');
val = val{w};
if strcmp(val,'linear')
    str_disp{1} = 'none';
    set(handles.pop_menu_06,'String',str_disp);
    set(handles.pop_menu_06,'Value',1);
else
    kernalparam_seq = [0.05	0.07	0.10	0.14	0.20	0.28	0.40	0.57	0.80	1.13	1.60	2.26	3.20	4.53	6.40	9.00];
    handles.kernalparam_seq = kernalparam_seq;
    str_disp={};
    for j=1:length(handles.kernalparam_seq)
        str_disp{j} = handles.kernalparam_seq(j);
    end
    set(handles.pop_menu_06,'String',str_disp);
    if isnan(loaded_param)
        set(handles.pop_menu_06,'Value',1);
    else
        w = find(kernalparam_seq == loaded_param);
        if length(w) == 1
            set(handles.pop_menu_06,'Value',w);
        else
            set(handles.pop_menu_06,'Value',1);
        end
    end
end

% --------------------------------------------------------
function handles = set_cvgroups_combo(handles)
str_disp={};
if get(handles.pop_menu_cv_type,'Value') < 4
    cv_group(1) = 2;
    cv_group(2) = 3;
    cv_group(3) = 4;
    cv_group(4) = 5;
    cv_group(5) = 10;
    cv_group(6) = handles.num_samples;
    for j=1:length(cv_group)
        str_disp{j} = cv_group(j);
    end
    set(handles.text02,'String','number of cv groups:');
    set(handles.pop_menu_cv_groups,'String',str_disp);
    set(handles.pop_menu_cv_groups,'Value',4);
else
    cv_group(1) = 100;
    cv_group(2) = 500;
    cv_group(3) = 1000;
    for j=1:length(cv_group)
        str_disp{j} = cv_group(j);
    end
    set(handles.text02,'String','number of iterations:');
    set(handles.pop_menu_cv_groups,'String',str_disp);
    set(handles.pop_menu_cv_groups,'Value',3);
end
