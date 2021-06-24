function varargout = visualize_settings_classmodelling(varargin)

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
                   'gui_OpeningFcn', @visualize_settings_classmodelling_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_settings_classmodelling_OutputFcn, ...
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

% --- Executes just before visualize_settings_classmodelling is made visible.
function visualize_settings_classmodelling_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% get inputs
handles.model_type = varargin{1};
handles.num_samples = varargin{2};
handles.model_is_present = varargin{3};
handles.model_loaded = varargin{4};
handles.num_classes = varargin{5};
handles.maxparam = varargin{6};
handles.class_labels = varargin{7};
handles.disable_combo = varargin{8};
if strcmp(handles.model_type,'pf')
    handles.param_range = [0.1:0.1:1.2];
elseif strcmp(handles.model_type,'simca') || strcmp(handles.model_type,'uneq')
    handles.param_range = [1:1:handles.maxparam];
end
% parameters for positions
x_position = 3.5 + 38;
x_position_classpopmenu = 3.5;
x_position_button = 88;
y_position = [21 17 13 9 5 1];
y_position_classpopmenu = y_position;
step_for_text = 1.8;
if handles.num_classes == 5
    translate_form = 3.5;
else
    translate_form = 7.5;
end
% reorder list of popup menu
if strcmp(handles.model_type,'pf')
    y_position = y_position([5 6 3 4 1 2]);
    translate_form = 0;
elseif strcmp(handles.model_type,'simca') || strcmp(handles.model_type,'uneq')
    y_position = y_position([3 4 1 2 5 6]);  
end
y_position = y_position - translate_form;
y_position_classpopmenu = y_position_classpopmenu - translate_form;
% set positions
set(hObject,'Position',[103.8571 45.4706 108 28-translate_form]);
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
% set positions popmenu class
set(handles.text_class01,'Position',[x_position_classpopmenu y_position_classpopmenu(1)+step_for_text 33 1.1]);
set(handles.pop_menu_class01,'Position',[x_position_classpopmenu y_position_classpopmenu(1) 33 1.7]);
set(handles.text_class02,'Position',[x_position_classpopmenu y_position_classpopmenu(2)+step_for_text 33 1.1]);
set(handles.pop_menu_class02,'Position',[x_position_classpopmenu y_position_classpopmenu(2) 33 1.7]);
set(handles.text_class03,'Position',[x_position_classpopmenu y_position_classpopmenu(3)+step_for_text 33 1.1]);
set(handles.pop_menu_class03,'Position',[x_position_classpopmenu y_position_classpopmenu(3) 33 1.7]);
set(handles.text_class04,'Position',[x_position_classpopmenu y_position_classpopmenu(4)+step_for_text 33 1.1]);
set(handles.pop_menu_class04,'Position',[x_position_classpopmenu y_position_classpopmenu(4) 33 1.7]);
set(handles.text_class05,'Position',[x_position_classpopmenu y_position_classpopmenu(5)+step_for_text 33 1.1]);
set(handles.pop_menu_class05,'Position',[x_position_classpopmenu y_position_classpopmenu(5) 33 1.7]);
% set class pop menu not visible
set(handles.text_class01,'Visible','off');
set(handles.pop_menu_class01,'Visible','off');
set(handles.text_class02,'Visible','off');
set(handles.pop_menu_class02,'Visible','off');
set(handles.text_class03,'Visible','off');
set(handles.pop_menu_class03,'Visible','off');
set(handles.text_class04,'Visible','off');
set(handles.pop_menu_class04,'Visible','off');
set(handles.text_class05,'Visible','off');
set(handles.pop_menu_class05,'Visible','off');
% set buttons and panel
set(handles.button_help,'Position',[x_position_button 19-translate_form 17 2]);
set(handles.button_cancel,'Position',[x_position_button 22-translate_form 17 2]);
set(handles.button_calculate_model,'Position',[x_position_button 25-translate_form 17 2]);
set(handles.panel_settings,'Position',[3 1.4 80 26-translate_form]);
movegui(handles.visualize_settings_class_modelling,'center')

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
uiwait(handles.visualize_settings_class_modelling);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_settings_classmodelling_OutputFcn(hObject, eventdata, handles)
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
    set_this = [];
    set_this(1) = takevaluefrompopmenu(get(handles.pop_menu_class01,'String'),get(handles.pop_menu_class01,'Value'));
    set_this(2) = takevaluefrompopmenu(get(handles.pop_menu_class02,'String'),get(handles.pop_menu_class02,'Value'));
    if handles.num_classes == 3 || handles.num_classes == 4 || handles.num_classes == 5; set_this(3) = takevaluefrompopmenu(get(handles.pop_menu_class03,'String'),get(handles.pop_menu_class03,'Value')); end;
    if handles.num_classes == 4 || handles.num_classes == 5; set_this(4) = takevaluefrompopmenu(get(handles.pop_menu_class04,'String'),get(handles.pop_menu_class04,'Value')); end;
    if handles.num_classes == 5; set_this(5) = takevaluefrompopmenu(get(handles.pop_menu_class05,'String'),get(handles.pop_menu_class05,'Value')); end;
    varargout{7} = set_this; % values from class pop menu
    varargout{8} = handles.domodel;
    delete(handles.visualize_settings_class_modelling)
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
uiresume(handles.visualize_settings_class_modelling)

% --- Executes on button press in button_cancel.
function button_cancel_Callback(hObject, eventdata, handles)
handles.settings = NaN;
guidata(hObject,handles)
uiresume(handles.visualize_settings_class_modelling)


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

% --- Executes on selection change in pop_menu_class01.
function pop_menu_class01_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_class01_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_class02.
function pop_menu_class02_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_class02_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_class03.
function pop_menu_class03_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_class03_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_class04.
function pop_menu_class04_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_class04_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_class05.
function pop_menu_class05_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_class05_CreateFcn(hObject, eventdata, handles)
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
    if handles.num_classes == max(handles.model_loaded.settings.class)
        % check if the number of classes of the present model coincide with
        % the number of classes of the loaded data
        model_memory = 1;
    else
        model_memory = 0;
    end
else
    model_memory = 0;
end
% scaling
str_scaling={};
str_scaling{1} = 'none';
str_scaling{2} = 'mean centering';
str_scaling{3} = 'autoscaling';
if strcmp(handles.model_type,'simca')
    set(handles.visualize_settings_class_modelling,'Name','SIMCA settings')
    % assignation criterion
    str_param_here{1} = 'class modeling';
    str_param_here{2} = 'distance';
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','assignation criterion:');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param_here);
    if model_memory && strcmp(handles.model_loaded.type,'simca')
        if strcmp('class modeling',handles.model_loaded.settings.assign_method)
            set_this = 1;
        else
            set_this = 2;
        end
        set(handles.pop_menu_03,'Value',set_this);
    else
        set(handles.pop_menu_03,'Value',1);
    end
    if handles.disable_combo
        set(handles.pop_menu_03,'Enable','off');
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','data scaling:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && strcmp(handles.model_loaded.type,'simca')
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
    % disabled
    set(handles.text05,'Visible','off');
    set(handles.pop_menu_05,'String',{'NaN'});
    set(handles.pop_menu_05,'Visible','off');
    set(handles.text06,'Visible','off');
    set(handles.pop_menu_06,'String',{'NaN'});
    set(handles.pop_menu_06,'Visible','off');
    % class components
    if model_memory && strcmp(handles.model_loaded.type,'simca')
        handles = setval_in_combo(handles,handles.model_loaded.settings.num_comp,'PCs - ');
    else
        handles = setval_in_combo(handles,handles.maxparam*ones(handles.num_classes,1),'PCs - ');
    end
elseif strcmp(handles.model_type,'uneq')
    set(handles.visualize_settings_class_modelling,'Name','UNEQ settings')
    % assignation criterion
    str_param_here{1} = 'class modeling';
    str_param_here{2} = 'distance';
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','assignation criterion:');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param_here);
    if model_memory && strcmp(handles.model_loaded.type,'uneq')
        if strcmp('class modeling',handles.model_loaded.settings.assign_method)
            set_this = 1;
        else
            set_this = 2;
        end
        set(handles.pop_menu_03,'Value',set_this);
    else
        set(handles.pop_menu_03,'Value',1);
    end
    if handles.disable_combo
        set(handles.pop_menu_03,'Enable','off');
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','data scaling:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && strcmp(handles.model_loaded.type,'uneq')
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
    % disabled
    set(handles.text05,'Visible','off');
    set(handles.pop_menu_05,'String',{'NaN'});
    set(handles.pop_menu_05,'Visible','off');
    set(handles.text06,'Visible','off');
    set(handles.pop_menu_06,'String',{'NaN'});
    set(handles.pop_menu_06,'Visible','off');
    % class components
    if model_memory && strcmp(handles.model_loaded.type,'uneq')
        handles = setval_in_combo(handles,handles.model_loaded.settings.num_comp,'PCs - ');
    else
        handles = setval_in_combo(handles,handles.maxparam*ones(handles.num_classes,1),'PCs - ');
    end
elseif strcmp(handles.model_type,'pf')
    set(handles.visualize_settings_class_modelling,'Name','Potential Functions settings')
    % num comp
    str_param_here{1} = 'none';
    str_param_here{2} = 'automatic';
    for j=3:handles.maxparam+2; str_param_here{j} = num2str(j-2); end
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','Apply on PCs:');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param_here);
    if model_memory && strcmp(handles.model_loaded.type,'pf')
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
    if model_memory && strcmp(handles.model_loaded.type,'pf')
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
    str_disp{1} = 'gaussian';
    str_disp{2} = 'triangular';
    set(handles.pop_menu_05,'Visible','on');
    set(handles.pop_menu_05,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'pf')
        if strcmp(handles.model_loaded.settings.type,'gaus')
            set_this = 1;
        else
            set_this = 2;
        end
        set(handles.pop_menu_05,'Value',set_this);
    else
        set(handles.pop_menu_05,'Value',1);
    end
    % percentile
    str_disp={};
    perc_list(1) = 80;
    perc_list(2) = 90;
    perc_list(3) = 95;
    perc_list(4) = 99;
    for j=1:length(perc_list); str_disp{j} = perc_list(j); end
    set(handles.text06,'Visible','on');
    set(handles.text06,'String','percentile for class:');
    set(handles.pop_menu_06,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'pf')
        if handles.model_loaded.settings.perc == 80
            set_this = 1;
        elseif handles.model_loaded.settings.perc == 90
            set_this = 2;
        elseif handles.model_loaded.settings.perc == 99
            set_this = 4;
        else
            set_this = 3;
        end
        set(handles.pop_menu_06,'Value',set_this);
    else
        set(handles.pop_menu_06,'Value',3);
    end
    % class smoothing
    if model_memory && strcmp(handles.model_loaded.type,'pf')
        handles = setval_in_combo(handles,handles.model_loaded.settings.smoot,'smoothing - ');
    else
        handles = setval_in_combo(handles,ones(handles.num_classes,1)*0.1,'smoothing - ');
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

% --------------------------------------------------------
function handles = setval_in_combo(handles,param_list,string_text)
% combo smoothing
str_disp={};
for j=1:length(handles.param_range)
    str_disp{j} = num2str(handles.param_range(j));
end
for g=1:length(param_list)
    if length(handles.class_labels) == 0
        text_here = [string_text 'class ' num2str(g) ':'];
    else
        text_here = [string_text handles.class_labels{g} ':'];
    end
    if g == 1
        set(handles.pop_menu_class01,'String',str_disp);
        w = findvalue(handles.param_range,param_list(g));
        set(handles.pop_menu_class01,'Value',w);
        set(handles.text_class01,'String',text_here);
        set(handles.text_class01,'Visible','on');
        set(handles.pop_menu_class01,'Visible','on');
    elseif g == 2
        set(handles.pop_menu_class02,'String',str_disp);
        w = findvalue(handles.param_range,param_list(g));
        set(handles.pop_menu_class02,'Value',w);
        set(handles.text_class02,'String',text_here);
        set(handles.text_class02,'Visible','on');
        set(handles.pop_menu_class02,'Visible','on');
    elseif g == 3
        set(handles.pop_menu_class03,'String',str_disp);
        w = findvalue(handles.param_range,param_list(g));
        set(handles.pop_menu_class03,'Value',w);
        set(handles.text_class03,'String',text_here);
        set(handles.text_class03,'Visible','on');
        set(handles.pop_menu_class03,'Visible','on');
    elseif g == 4
        set(handles.pop_menu_class04,'String',str_disp);
        w = findvalue(handles.param_range,param_list(g));
        set(handles.pop_menu_class04,'Value',w);
        set(handles.text_class04,'String',text_here);
        set(handles.text_class04,'Visible','on');
        set(handles.pop_menu_class04,'Visible','on');
    elseif g == 5
        set(handles.pop_menu_class05,'String',str_disp);
        w = findvalue(handles.param_range,param_list(g));
        set(handles.pop_menu_class05,'Value',w);
        set(handles.text_class05,'String',text_here);
        set(handles.text_class05,'Visible','on');
        set(handles.pop_menu_class05,'Visible','on');
    end
end
if handles.disable_combo
    set(handles.pop_menu_class01,'Enable','off');
    set(handles.pop_menu_class02,'Enable','off');
    set(handles.pop_menu_class03,'Enable','off');
    set(handles.pop_menu_class04,'Enable','off');
    set(handles.pop_menu_class05,'Enable','off');
end

% --------------------------------------------------------
function w = findvalue(param_range,v)
w = find(param_range == v);
if length(w) == 0
    param_range = round(param_range*10);
    v = round(v * 10);
    w = find(param_range == v);
    if length(w) == 0
        w = 1;
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

