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
% D. Ballabio (2015), A MATLAB toolbox for Principal Component Analysis and unsupervised exploration of data structure
% Chemometrics and Intelligent Laboratory Systems, 149 Part B, 1-9
% 
% PCA toolbox for MATLAB
% version 1.4 - December 2018
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
handles.max_param = varargin{2};
handles.model_is_present = varargin{3};
handles.model_loaded = varargin{4};
handles.num_samples = varargin{5};
% parameters for positions
x_position = 3.5;
x_position_button = 50;
step_for_text = 1.8;
y_position = [9.3 5.3 1.3];
if strcmp(handles.model_type,'pcacomp')
    y_position = y_position([2 3 1]);
end
set(hObject,'Position',[103.8571 45.4706 70 16]);
set(handles.text01,'Position',[x_position y_position(1)+step_for_text 33 1.1]);
set(handles.pop_menu_01,'Position',[x_position y_position(1) 33 1.7]);
set(handles.text02,'Position',[x_position y_position(2)+step_for_text 33 1.1]);
set(handles.pop_menu_02,'Position',[x_position y_position(2) 33 1.7]);
set(handles.text03,'Position',[x_position y_position(3)+step_for_text 33 1.1]);
set(handles.pop_menu_03,'Position',[x_position y_position(3) 33 1.7]);
set(handles.button_help,'Position',[x_position_button 7 17 2]);
set(handles.button_cancel,'Position',[x_position_button 10 17 2]);
set(handles.button_calculate_model,'Position',[x_position_button 13 17 2]);
set(handles.panel_settings,'Position',[3 1.4 42 14]);
movegui(handles.visualize_settings_small,'center')

% set cv type combo: components for PCA
handles = set_combo_01(handles);

% set cv groups combo: scaling for PCA
handles = set_combo_02(handles);

% set disc type combo
handles = set_combo_03(handles);

% customize window
handles = custom_form(handles);

% initialize values
handles.domodel = 0;

guidata(hObject, handles);
uiwait(handles.visualize_settings_small);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_settings_small_OutputFcn(hObject, eventdata, handles)
len = length(handles);
if len > 0
    varargout{1} = takevaluefrompopmenu(get(handles.pop_menu_01,'String'),get(handles.pop_menu_01,'Value'));
    varargout{2} = takevaluefrompopmenu(get(handles.pop_menu_02,'String'),get(handles.pop_menu_02,'Value'));
    varargout{3} = takevaluefrompopmenu(get(handles.pop_menu_03,'String'),get(handles.pop_menu_03,'Value'));
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
function pop_menu_02_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in pop_menu_02.
function pop_menu_02_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_01_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in pop_menu_01.
function pop_menu_01_Callback(hObject, eventdata, handles)

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
function A = takevaluefrompopmenu(list,val)
A = list(val);
A = cell2mat(A);
[num, status] = str2num(A);
if status
    A = num;
else
    % exceptions
    if strcmp(A,'mean centering')
        A = 'cent';
    elseif strcmp(A,'autoscaling')
        A = 'auto';
    elseif strcmp(A,'range scaling')
        A = 'rang';
    elseif strcmp(A,'venetian blinds cross validation')
        A = 'vene';
    elseif strcmp(A,'contiguous blocks cross validation')
        A = 'cont';
    end
end

% ------------------------------------------------------------------------
function handles = custom_form(handles)
if strcmp(handles.model_type,'compsel') || strcmp(handles.model_type,'cluster')
    set(handles.pop_menu_03,'Visible','on');
    set(handles.text03,'Visible','on');
    if strcmp(handles.model_type,'compsel')
        set(handles.visualize_settings_small,'Name','cross validation settings')
    else
        set(handles.visualize_settings_small,'Name','Cluster Analysis settings')
    end
else
    set(handles.pop_menu_03,'Visible','off');
    set(handles.text03,'Visible','off');
    if strcmp(handles.model_type,'pca')
        set(handles.visualize_settings_small,'Name','PCA settings')
    else
        set(handles.visualize_settings_small,'Name','MDS settings')
    end
end

% --------------------------------------------------------
function handles = set_combo_01(handles)
str_disp{1}=''; set_this = 1; string_this = '';
if strcmp(handles.model_type,'pca')
    for j=1:handles.max_param
        str_disp{j} = num2str(j);
    end
    if handles.model_is_present == 2 && strcmp(handles.model_loaded.type,'pca')
        set_this = handles.model_loaded.settings.num_comp;
    else
        set_this = handles.max_param;
    end
    string_this = 'number of components:';
elseif strcmp(handles.model_type,'compsel')
    str_disp{1} = 'none';
    str_disp{2} = 'mean centering';
    str_disp{3} = 'autoscaling';
    str_disp{4} = 'range scaling';
    set_this = 3;
    string_this = 'data scaling:';
else
    str_disp={};
    str_disp{1} = 'euclidean';
    str_disp{2} = 'cityblock';
    str_disp{3} = 'mahalanobis';
    str_disp{4} = 'minkowski';
    str_disp{5} = 'jaccard';
    if handles.model_is_present == 2 && (strcmp(handles.model_loaded.type,'mds') || strcmp(handles.model_loaded.type,'cluster'))
        if strcmp(handles.model_loaded.settings.distance,'euclidean')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.distance,'cityblock')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.distance,'mahalanobis')
            set_this = 3;
        elseif strcmp(handles.model_loaded.settings.distance,'minkowski')
            set_this = 4;
        else
            set_this = 5;            
        end      
    else
        set_this = 1;
    end
    string_this = 'distance:';
end
set(handles.pop_menu_01,'String',str_disp);
set(handles.pop_menu_01,'Value',set_this);
set(handles.text01,'String',string_this);

% --------------------------------------------------------
function handles = set_combo_02(handles)
str_disp{1}=''; set_this = 1; string_this = ' ';
if strcmp(handles.model_type,'compsel')
    str_disp{1} = 'venetian blinds cross validation';
    str_disp{2} = 'contiguous blocks cross validation';
    set_this = 1;
    string_this = 'validation:';
else
    str_disp{1} = 'none';
    str_disp{2} = 'mean centering';
    str_disp{3} = 'autoscaling';
    str_disp{4} = 'range scaling';
    if handles.model_is_present == 2
        if strcmp(handles.model_loaded.settings.param.pret_type,'none')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.param.pret_type,'cent')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.param.pret_type,'auto')
            set_this = 3;
        else 
            set_this = 4;
        end
    else
        set_this = 3;
    end
    string_this = 'data scaling:';    
end
set(handles.pop_menu_02,'String',str_disp);
set(handles.pop_menu_02,'Value',set_this);
set(handles.text02,'String',string_this);

% --------------------------------------------------------
function handles = set_combo_03(handles)
str_disp{1}=''; set_this = 1; string_this = ' ';
if strcmp(handles.model_type,'compsel') 
    cv_group(1) = 2;
    cv_group(2) = 3;
    cv_group(3) = 4;
    cv_group(4) = 5;
    cv_group(5) = 10;
    cv_group(6) = handles.num_samples;
    for j=1:length(cv_group)
        str_disp{j} = cv_group(j);
    end
    string_this = 'number of cv groups:';
    set_this = 4;
elseif strcmp(handles.model_type,'cluster') 
    str_disp={};
    str_disp{1} = 'single';
    str_disp{2} = 'complete';
    str_disp{3} = 'average';
    str_disp{4} = 'centroid';
    string_this = 'linkage:';
    if handles.model_is_present == 2 && strcmp(handles.model_loaded.type,'cluster')
        if strcmp(handles.model_loaded.settings.linkage_type,'single')
            set_this = 1;
        elseif strcmp(handles.model_loaded.settings.linkage_type,'complete')
            set_this = 2;
        elseif strcmp(handles.model_loaded.settings.linkage_type,'average')
            set_this = 3;
        else
            set_this = 4;
        end
    else
        set_this = 1;
    end
end
set(handles.pop_menu_03,'String',str_disp);
set(handles.pop_menu_03,'Value',set_this);
set(handles.text03,'String',string_this);
