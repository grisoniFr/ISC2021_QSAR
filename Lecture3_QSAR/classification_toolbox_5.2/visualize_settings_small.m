function varargout = visualize_settings_small(varargin)

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
                   'gui_OpeningFcn', @visualize_settings_small_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_settings_small_OutputFcn, ...
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


% --- Executes just before visualize_settings_small is made visible.
function visualize_settings_small_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
handles.model_type = varargin{1};
handles.num_samples = varargin{2};
handles.model_is_present = varargin{3};
model_loaded = varargin{4};
% parameters for positions
x_position = 3.5;
x_position_button = 50;
step_for_text = 1.8;
y_position = [9.3 5.3 1.3];
if strcmp(handles.model_type,'da')
    y_position = y_position([2 3 1]);
end
set(hObject,'Position',[103.8571 45.4706 70 16]);
set(handles.text01,'Position',[x_position y_position(1)+step_for_text 33 1.1]);
set(handles.pop_menu_cv_type,'Position',[x_position y_position(1) 33 1.7]);
set(handles.text02,'Position',[x_position y_position(2)+step_for_text 33 1.1]);
set(handles.pop_menu_cv_groups,'Position',[x_position y_position(2) 33 1.7]);
set(handles.text03,'Position',[x_position y_position(3)+step_for_text 33 1.1]);
set(handles.pop_menu_disc_type,'Position',[x_position y_position(3) 33 1.7]);
set(handles.button_help,'Position',[x_position_button 7 17 2]);
set(handles.button_cancel,'Position',[x_position_button 10 17 2]);
set(handles.button_calculate_model,'Position',[x_position_button 13 17 2]);
set(handles.panel_settings,'Position',[3 1.4 42 14]);
movegui(handles.visualize_settings_small,'center')

% set cv type combo
str_disp={};
str_disp{1} = 'none';
str_disp{2} = 'venetian blinds cross validation';
str_disp{3} = 'contiguous blocks cross validation';
str_disp{4} = 'montecarlo 20% out';
str_disp{5} = 'bootstrap';
set(handles.pop_menu_cv_type,'String',str_disp);
set(handles.pop_menu_cv_type,'Value',2);

% set cv groups combo
handles = set_cvgroups_combo(handles);

% set disc type combo
str_disp={};
str_disp{1} = 'linear';
str_disp{2} = 'quadratic';
set(handles.pop_menu_disc_type,'String',str_disp);

% customize window
handles = custom_form(handles);

% initialize values
handles.domodel = 0;
% if we get a calculated model, we load the same settings
if handles.model_is_present == 2
    if strcmp(model_loaded.type,'qda')
        set(handles.pop_menu_disc_type,'Value',2);
    else
        set(handles.pop_menu_disc_type,'Value',1);
    end
end

% enable/disable combo
handles = enable_disable(handles);

guidata(hObject, handles);
uiwait(handles.visualize_settings_small);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_settings_small_OutputFcn(hObject, eventdata, handles)
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
    if get(handles.pop_menu_disc_type,'Value') == 1
        set_this = 'lda';
    else
        set_this = 'qda';
    end
    varargout{3} = set_this;
    varargout{4} = handles.domodel;
    delete(handles.visualize_settings_small)
else
    handles.settings.cv_groups = NaN;
    handles.settings.cv_type = NaN;
    handles.settings.disc = NaN;
    handles.domodel = 0;
    varargout{1} = handles.settings.cv_groups;
    varargout{2} = handles.settings.cv_type;
    varargout{3} = handles.settings.disc;
    varargout{4} = handles.domodel;
end

% --- Executes on button press in button_calculate_model.
function button_calculate_model_Callback(hObject, eventdata, handles)
handles.domodel = 1;
guidata(hObject,handles)
uiresume(handles.visualize_settings_small)

% --- Executes on button press in button_cancel.
function button_cancel_Callback(hObject, eventdata, handles)
handles.settings = NaN;
guidata(hObject,handles)
uiresume(handles.visualize_settings_small)

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
if strcmp(handles.model_type,'da')
    set(handles.pop_menu_disc_type,'Visible','on');
    set(handles.text03,'Visible','on');
    set(handles.visualize_settings_small,'Name','DA settings')
else
    set(handles.pop_menu_disc_type,'Visible','off');
    set(handles.text03,'Visible','off');
    set(handles.visualize_settings_small,'Name','CART settings')
end

% --- Executes during object creation, after setting all properties.
function pop_menu_disc_type_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in pop_menu_disc_type.
function pop_menu_disc_type_Callback(hObject, eventdata, handles)

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
