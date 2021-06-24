function varargout = visualize_settings_big(varargin)

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
handles.X = varargin{6};
handles.y = varargin{7};
% parameters for positions
x_position = 3.5;
x_position_button = 46;
y_position = [29.2 25.2 21.2 17.2 13.2 9.2 5.2 1.2];
translate_form = 11.5;
step_for_text = 1.8;
% reorder list of popup menu
if strcmp(handles.model_type,'pls') || strcmp(handles.model_type,'pcr') 
    y_position = y_position([3 4 1 2 5 6 7 8]);
    translate_form = 15.5;
elseif strcmp(handles.model_type,'lr')
    y_position = y_position([5 6 2 3 4 1 7 8]);
    translate_form = 8;
elseif strcmp(handles.model_type,'ridge')
    y_position = y_position([2 3 1 4 5 6 7 8]);
    translate_form = 19;
end
y_position = y_position - translate_form;
% set positions
set(hObject,'Position',[103.8571 45.4706 70 36-translate_form]);
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
set(handles.text08,'Position',[x_position y_position(8)+step_for_text 33 1.1]);
set(handles.pop_menu_08,'Position',[x_position y_position(8) 33 1.7]);
% set buttons and panel
set(handles.button_help,'Position',[x_position_button 24-translate_form 23 2]);
set(handles.button_cancel,'Position',[x_position_button 27-translate_form 23 2]);
set(handles.button_optimal,'Position',[x_position_button 30-translate_form 23 2]);
set(handles.button_calculate_model,'Position',[x_position_button 33-translate_form 23 2]);
set(handles.panel_settings,'Position',[3 1.4 42 34-translate_form]);
movegui(handles.visualize_settings_big,'center')
% set cv type combo
str_disp={};
str_disp{1} = 'none';
str_disp{2} = 'venetian blinds cross validation';
str_disp{3} = 'contiguous blocks cross validation';
str_disp{4} = 'montecarlo 20% out';
str_disp{5} = 'bootstrap';
set(handles.pop_menu_cv_type,'String',str_disp);
set(handles.pop_menu_cv_type,'Value',2);
handles.bnnparam_seq = [0.1:0.1:2];
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
    varargout{8} = get(handles.pop_menu_08,'Value') - 1;
    varargout{9} = handles.domodel;
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
    varargout{8} = 0;
    varargout{9} = handles.domodel;
end

% --- Executes on button press in button_calculate_model.
function button_calculate_model_Callback(hObject, eventdata, handles)
handles.domodel = 1;
guidata(hObject,handles)
uiresume(handles.visualize_settings_big)

% --- Executes on button press in button_optimal.
function button_optimal_Callback(hObject, eventdata, handles)
do_optimal(handles);

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

% --- Executes during object creation, after setting all properties.
function pop_menu_05_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_06.
function pop_menu_06_Callback(hObject, eventdata, handles)
if strcmp(handles.model_type,'lr')
    handles = setparamcombo(handles);
    guidata(hObject,handles)
end

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

% --- Executes on selection change in pop_menu_08.
function pop_menu_08_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_08_CreateFcn(hObject, eventdata, handles)
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
    elseif strcmp(A,'binned Nearest Neighbours')
        A = 'bnn';
    elseif strcmp(A,'k Nearest Neighbours')
        A = 'knn';        
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
if handles.model_is_present == 2 % a model is already calculated
    model_memory = 1;
else
    model_memory = 0;
end
% scaling
str_scaling={};
str_scaling{1} = 'none';
str_scaling{2} = 'mean centering';
str_scaling{3} = 'autoscaling';
if strcmp(handles.model_type,'pls')
    set(handles.visualize_settings_big,'Name','PLS settings')
    set(handles.button_optimal,'String','optimal LV')
    % num comp
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','number of LV:');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param);
    if model_memory && strcmp(handles.model_loaded.type,'pls')
        set(handles.pop_menu_03,'Value',size(handles.model_loaded.T,2));
    else
        set(handles.pop_menu_03,'Value',length(str_param));
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','data scaling:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && strcmp(handles.model_loaded.type,'pls')
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
    set(handles.text07,'Visible','off');
    set(handles.pop_menu_07,'String',{'NaN'});
    set(handles.pop_menu_07,'Visible','off');
    set(handles.text08,'Visible','off');
    set(handles.pop_menu_08,'String',{'NaN'});
    set(handles.pop_menu_08,'Visible','off');
elseif strcmp(handles.model_type,'pcr')
    set(handles.visualize_settings_big,'Name','PCR settings')
    set(handles.button_optimal,'String','optimal PC')
    % num comp
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','number of PC:');
    set(handles.pop_menu_03,'Visible','on');
    set(handles.pop_menu_03,'String',str_param);
    if model_memory && strcmp(handles.model_loaded.type,'pcr')
        set(handles.pop_menu_03,'Value',size(handles.model_loaded.T,2));
    else
        set(handles.pop_menu_03,'Value',length(str_param));
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','data scaling:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && strcmp(handles.model_loaded.type,'pcr')
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
    set(handles.text07,'Visible','off');
    set(handles.pop_menu_07,'String',{'NaN'});
    set(handles.pop_menu_07,'Visible','off');
    set(handles.text08,'Visible','off');
    set(handles.pop_menu_08,'String',{'NaN'});
    set(handles.pop_menu_08,'Visible','off');
elseif strcmp(handles.model_type,'ridge')
    set(handles.visualize_settings_big,'Name','Ridge settings')
    set(handles.button_optimal,'String','optimal K')
    % num comp
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','k value:');
    set(handles.pop_menu_03,'Visible','on');
    str_disp={};
    for k=1:30;str_disp{k} = num2str(k/10); end
    set(handles.pop_menu_03,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'ridge')
        valhere = round(handles.model_loaded.settings.K*10);
        set(handles.pop_menu_03,'Value',valhere);
    else
        set(handles.pop_menu_03,'Value',1);
    end
    % disabled
    set(handles.text04,'Visible','off');
    set(handles.pop_menu_04,'String',{'NaN'});
    set(handles.pop_menu_04,'Visible','off');
    set(handles.text05,'Visible','off');
    set(handles.pop_menu_05,'String',{'NaN'});
    set(handles.pop_menu_05,'Visible','off');
    set(handles.text06,'Visible','off');
    set(handles.pop_menu_06,'String',{'NaN'});
    set(handles.pop_menu_06,'Visible','off');
    set(handles.text07,'Visible','off');
    set(handles.pop_menu_07,'String',{'NaN'});
    set(handles.pop_menu_07,'Visible','off');
    set(handles.text08,'Visible','off');
    set(handles.pop_menu_08,'String',{'NaN'});
    set(handles.pop_menu_08,'Visible','off');    
elseif strcmp(handles.model_type,'lr')
    set(handles.visualize_settings_big,'Name','Local regression settings')
    set(handles.button_optimal,'String','optimal k/alpha')
    % type
    set(handles.text06,'Visible','on');
    set(handles.text06,'String','type of local regression:');
    set(handles.pop_menu_06,'Visible','on');
    str_disp={};
    str_disp{1} = 'k Nearest Neighbours';
    str_disp{2} = 'binned Nearest Neighbours';
    set(handles.pop_menu_06,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'knn') 
        set(handles.pop_menu_06,'Value',1);
    elseif model_memory && strcmp(handles.model_loaded.type,'bnn')
        set(handles.pop_menu_06,'Value',2);
    else
        set(handles.pop_menu_06,'Value',1);
    end
    % num k
    set(handles.text03,'Visible','on');
    set(handles.text03,'String','number of neighbours (K):');
    set(handles.pop_menu_03,'Visible','on');
    if model_memory && strcmp(handles.model_loaded.type,'knn') 
        set(handles.pop_menu_03,'String',str_param);
        set(handles.pop_menu_03,'Value',handles.model_loaded.settings.K);
    elseif model_memory && strcmp(handles.model_loaded.type,'bnn')
        set(handles.text03,'String','alpha:');
        str_param={};
        for j=1:length(handles.bnnparam_seq)
            str_param{j} = handles.bnnparam_seq(j);
        end
        set(handles.pop_menu_03,'String',str_param);
        w = findvalue(handles.bnnparam_seq,handles.model_loaded.settings.alpha);
        set(handles.pop_menu_03,'Value',w);
    else
        set(handles.pop_menu_03,'String',str_param);
        set(handles.pop_menu_03,'Value',1);
    end
    % scaling
    set(handles.text04,'Visible','on');
    set(handles.text04,'String','data scaling:');
    set(handles.pop_menu_04,'Visible','on');
    set(handles.pop_menu_04,'String',str_scaling);
    if model_memory && strcmp(handles.model_loaded.type,'knn') || model_memory && strcmp(handles.model_loaded.type,'bnn')
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
    % distance
    set(handles.text05,'Visible','on');
    set(handles.text05,'String','distance:');
    str_disp={};
    str_disp{1} = 'euclidean';
    str_disp{2} = 'mahalanobis';
    str_disp{3} = 'cityblock';
    str_disp{4} = 'minkowski';
    set(handles.pop_menu_05,'Visible','on');
    set(handles.pop_menu_05,'String',str_disp);
    if model_memory && strcmp(handles.model_loaded.type,'knn') || model_memory && strcmp(handles.model_loaded.type,'bnn')
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
    set(handles.text07,'Visible','off');
    set(handles.pop_menu_07,'String',{'NaN'});
    set(handles.pop_menu_07,'Visible','off');
    set(handles.text08,'Visible','off');
    set(handles.pop_menu_08,'String',{'NaN'});
    set(handles.pop_menu_08,'Visible','off');
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
function handles = setparamcombo(handles)
% set kernel parameter combo
w = get(handles.pop_menu_06,'value');
if w == 1 % kNN
    for j=1:handles.maxparam; str_param{j} = num2str(j); end
    set(handles.text03,'String','number of neighbours (K):');
    set(handles.pop_menu_03,'String',str_param);
    set(handles.pop_menu_03,'Value',1);
else % BNN
    str_param={};
    for j=1:length(handles.bnnparam_seq); str_param{j} = handles.bnnparam_seq(j); end
    set(handles.text03,'String','alpha:');
    set(handles.pop_menu_03,'String',str_param);
    set(handles.pop_menu_03,'Value',1);
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
function do_optimal(handles)
if get(handles.pop_menu_cv_type,'Value') == 1 || get(handles.pop_menu_cv_type,'Value') > 3
    h1 = ['Optimisation must be based on venetian blind or contiguous block cross validation'];
    warndlg([h1],'Variable selection')
else
    w = get(handles.pop_menu_cv_groups,'Value');
    cv_groups = get(handles.pop_menu_cv_groups,'String');
    cv_groups = cv_groups{w};
    cv_groups = str2num(cv_groups);
    if get(handles.pop_menu_cv_type,'Value') == 1
        cv_type = 'none';
    elseif get(handles.pop_menu_cv_type,'Value') == 2
        cv_type = 'vene';
    elseif get(handles.pop_menu_cv_type,'Value') == 3
        cv_type = 'cont'; 
    elseif get(handles.pop_menu_cv_type,'Value') == 4
        cv_type = 'rand';
    else
        cv_type = 'boot';
    end
    % activate pointer
    set(handles.visualize_settings_big,'Pointer','watch')
    % run
    if strcmp(handles.model_type,'pls')        
        scaling = takevaluefrompopmenu(get(handles.pop_menu_04,'String'),get(handles.pop_menu_04,'Value'));
        res = plscompsel(handles.X,handles.y,scaling,cv_type,cv_groups);
        if length(res.rmse) > 1
            plot_rmsecv(res,'pls');
        end
    elseif strcmp(handles.model_type,'pcr')
        scaling = takevaluefrompopmenu(get(handles.pop_menu_04,'String'),get(handles.pop_menu_04,'Value'));
        res = pcrcompsel(handles.X,handles.y,scaling,cv_type,cv_groups);
        if length(res.rmse) > 1
            plot_rmsecv(res,'pcr');
        end
    elseif strcmp(handles.model_type,'ridge')
        res = ridgeksel(handles.X,handles.y,cv_type,cv_groups);
        if length(res.rmse) > 1
            plot_rmsecv(res,'ridge');
        end
    else
        scaling = takevaluefrompopmenu(get(handles.pop_menu_04,'String'),get(handles.pop_menu_04,'Value'));
        dist_type = takevaluefrompopmenu(get(handles.pop_menu_05,'String'),get(handles.pop_menu_05,'Value'));
        type_local_regression = takevaluefrompopmenu(get(handles.pop_menu_06,'String'),get(handles.pop_menu_06,'Value'));
        if strcmp(type_local_regression,'knn')
            res = knnksel(handles.X,handles.y,dist_type,scaling,cv_type,cv_groups);
        else
            res = bnnsel(handles.X,handles.y,dist_type,scaling,cv_type,cv_groups);
        end
        if length(res.rmse) > 1
            plot_rmsecv(res,type_local_regression);
        end
    end
    set(handles.visualize_settings_big,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function plot_rmsecv(res,model_type)
[~,col_default] = visualize_colors;
num_comp = length(res.rmse);
figure
set(gcf,'color','white')
subplot(2,1,1)
hold on
plot(res.R2,'Color',col_default(1,:))
plot(res.R2,'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
ylabel('R2 cv')
ylim = get(gca, 'YLim');
axis([0.6 (num_comp + 0.4) ylim(1) ylim(2)])
if strcmp(model_type,'pls')
    lab = 'latent variables';
    set(gca,'xtick',[1:num_comp]);
elseif strcmp(model_type,'pcr')
    lab = 'principal components';
    set(gca,'xtick',[1:num_comp]);
elseif strcmp(model_type,'ridge')
    lab = 'ridge parameter k';
    labhere = [0.1:0.1:3];
    set(gca,'xtick',[1:length(labhere)]);
    set(gca,'xticklabel',labhere);
elseif strcmp(model_type,'bnn')
    lab = 'alpha';
    labhere = [0.1:0.1:2];
    set(gca,'xtick',[1:length(labhere)]);
    set(gca,'xticklabel',labhere);
else
    lab = 'K neighbours';
    set(gca,'xtick',[1:num_comp]);
end
xlabel(lab)
set(gca,'YGrid','on','GridLineStyle',':')
hold off
box on
subplot(2,1,2)
hold on
plot(res.rmse,'Color',col_default(1,:))
plot(res.rmse,'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
ylabel('RMSE cv')
ylim = get(gca, 'YLim');
axis([0.6 (num_comp + 0.4) ylim(1) ylim(2)])
if strcmp(model_type,'pls')
    lab = 'latent variables';
    set(gca,'xtick',[1:num_comp]);
elseif strcmp(model_type,'pcr')
    lab = 'principal components';
    set(gca,'xtick',[1:num_comp]);
elseif strcmp(model_type,'ridge')
    lab = 'ridge parameter k';
    labhere = [0.1:0.1:3];
    set(gca,'xtick',[1:length(labhere)]);
    set(gca,'xticklabel',labhere);
elseif strcmp(model_type,'bnn')
    lab = 'alpha';
    labhere = [0.1:0.1:2];
    set(gca,'xtick',[1:length(labhere)]);
    set(gca,'xticklabel',labhere);
else
    lab = 'K neighbours';
    set(gca,'xtick',[1:num_comp]);
end
xlabel(lab)
set(gca,'YGrid','on','GridLineStyle',':')
hold off
box on

