function varargout = visualize_settings_ga(varargin)

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
                   'gui_OpeningFcn', @visualize_settings_ga_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_settings_ga_OutputFcn, ...
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

% --- Executes just before visualize_settings_ga is made visible.
function visualize_settings_ga_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% get inputs
handles.num_variables = varargin{1};
handles.num_samples = varargin{2};
% parameters for positions
x_position = 3.5;
x_position_button = 92;
y_position = [29.2 25.2 21.2 17.2 13.2 9.2 5.2 1.2];
translate_form = 11.5;
step_for_text = 1.8;
% reorder list of popup menu
y_position = y_position([1 2 3 4 5 6 7 8]);
y_position = y_position - translate_form;
handles.y_position = y_position;
% set positions
set(hObject,'Position',[103.8571 45.4706 112 36-translate_form]);
set(handles.text01,'Position',[x_position y_position(1)+step_for_text 33 1.1]);
set(handles.pop_menu_01,'Position',[x_position y_position(1) 33 1.7]);
set(handles.text02,'Position',[x_position y_position(2)+step_for_text 33 1.1]);
set(handles.pop_menu_02,'Position',[x_position y_position(2) 33 1.7]);
set(handles.text03,'Position',[x_position y_position(3)+step_for_text 33 1.1]);
set(handles.pop_menu_03,'Position',[x_position y_position(3) 33 1.7]);
set(handles.text04,'Position',[x_position y_position(4)+step_for_text 33 1.1]);
set(handles.pop_menu_04,'Position',[x_position y_position(4) 33 1.7]);
set(handles.text05,'Position',[x_position y_position(5)+step_for_text 33 1.1]);
set(handles.pop_menu_05,'Position',[x_position y_position(5) 33 1.7]);
% set position modelling
set(handles.text01mod,'Position',[x_position y_position(1)+step_for_text 33 1.1]);
set(handles.pop_menu_01mod,'Position',[x_position y_position(1) 33 1.7]);
set(handles.text02mod,'Position',[x_position y_position(2)+step_for_text 33 1.1]);
set(handles.pop_menu_02mod,'Position',[x_position y_position(2) 33 1.7]);
set(handles.text03mod,'Position',[x_position y_position(3)+step_for_text 33 1.1]);
set(handles.pop_menu_03mod,'Position',[x_position y_position(3) 33 1.7]);
set(handles.text04mod,'Position',[x_position y_position(4)+step_for_text 33 1.1]);
set(handles.pop_menu_04mod,'Position',[x_position y_position(4) 33 1.7]);
set(handles.text05mod,'Position',[x_position y_position(5)+step_for_text 33 1.1]);
set(handles.pop_menu_05mod,'Position',[x_position y_position(5) 33 1.7]);
% set buttons
set(handles.button_help,'Position',[x_position_button 27-translate_form 17 2]);
set(handles.button_cancel,'Position',[x_position_button 30-translate_form 17 2]);
set(handles.button_calculate_model,'Position',[x_position_button 33-translate_form 17 2]);
% set panels
set(handles.panel_settings,'Position',[48 1.4 42 34-translate_form]);
set(handles.panel_modelling,'Position',[3 1.4 42 34-translate_form]);
movegui(handles.visualize_settings_ga,'center')
% save handles positions
handles.mypositions.y_position = y_position;
handles.mypositions.x_position = x_position;
handles.mypositions.step_for_text = step_for_text;
% customize window
set(handles.text01mod,'Visible','on');
set(handles.text01mod,'String','regression method:');
set(handles.pop_menu_01mod,'Visible','on');
str_param = {};
str_param{1} = 'Ordinary Least Squares'; handles.model_type{1} = 'ols';
str_param{2} = 'Partial Least Squares'; handles.model_type{2} = 'pls';
str_param{3} = 'Principal Component Regression'; handles.model_type{3} = 'pcr';
str_param{4} = 'Ridge'; handles.model_type{4} = 'ridge';
str_param{5} = 'k Nearest Neighbours'; handles.model_type{5} = 'knn';
str_param{6} = 'binned Nearest Neighbours'; handles.model_type{6} = 'bnn';
set(handles.pop_menu_01mod,'String',str_param);
set(handles.pop_menu_01mod,'Value',1);
handles = custom_formtype(handles);
handles = custom_form(handles);
handles = custom_form_modelling(handles);
% initialize values
handles.domodel = 0;
% enable/disable combo
guidata(hObject, handles);
uiwait(handles.visualize_settings_ga);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_settings_ga_OutputFcn(hObject, eventdata, handles)
len = length(handles);
if len > 0
    varargout{1} = takevaluefrompopmenu(get(handles.pop_menu_01,'String'),get(handles.pop_menu_01,'Value'));
    varargout{2} = takevaluefrompopmenu(get(handles.pop_menu_02,'String'),get(handles.pop_menu_02,'Value'));
    varargout{3} = takevaluefrompopmenu(get(handles.pop_menu_03,'String'),get(handles.pop_menu_03,'Value'));
    varargout{4} = takevaluefrompopmenu(get(handles.pop_menu_04,'String'),get(handles.pop_menu_04,'Value'));
    varargout{5} = takevaluefrompopmenu(get(handles.pop_menu_05,'String'),get(handles.pop_menu_05,'Value'));
    varargout{6} = handles.model_type{get(handles.pop_menu_01mod,'Value')};
    varargout{7} = takevaluefrompopmenu(get(handles.pop_menu_02mod,'String'),get(handles.pop_menu_02mod,'Value'));
    varargout{8} = takevaluefrompopmenu(get(handles.pop_menu_03mod,'String'),get(handles.pop_menu_03mod,'Value'));
    varargout{9} = takevaluefrompopmenu(get(handles.pop_menu_04mod,'String'),get(handles.pop_menu_04mod,'Value'));
    varargout{10} = takevaluefrompopmenu(get(handles.pop_menu_05mod,'String'),get(handles.pop_menu_05mod,'Value'));    
    varargout{11} = handles.domodel;
    delete(handles.visualize_settings_ga)
else
    handles.domodel = 0;
    varargout{1} = 0;
    varargout{2} = 0;
    varargout{3} = 0;
    varargout{4} = 0;
    varargout{5} = 0;
    varargout{6} = 0;
    varargout{7} = 0;
    varargout{8} = 0;
    varargout{9} = 0;
    varargout{10} = 0;    
    varargout{11} = handles.domodel;
end

% --- Executes on button press in button_calculate_model.
function button_calculate_model_Callback(hObject, eventdata, handles)
num_windows = takevaluefrompopmenu(get(handles.pop_menu_05,'String'),get(handles.pop_menu_05,'Value'));
type = takevaluefrompopmenu(get(handles.pop_menu_01,'String'),get(handles.pop_menu_01,'Value'));
if ~ischar(num_windows) && 2*num_windows > handles.num_variables
    h1 = ['The number of windows (intervals of variables) must be higher than the double of the number of variables (' num2str(handles.num_variables) ')'];
    warndlg([h1],'Variable selection')
elseif strcmp(type,'rsr')
    minvar = takevaluefrompopmenu(get(handles.pop_menu_02,'String'),get(handles.pop_menu_02,'Value'));
    maxvar = takevaluefrompopmenu(get(handles.pop_menu_03,'String'),get(handles.pop_menu_03,'Value'));
    if maxvar<= minvar
        h1 = ['The minimum number of variables must be lower than the maximum'];
        warndlg([h1],'Variable selection')
    else
        handles.domodel = 1;
        guidata(hObject,handles)
        uiresume(handles.visualize_settings_ga)
    end
elseif get(handles.pop_menu_01,'Value') == 1 % forward
    model_type = handles.model_type(get(handles.pop_menu_01mod,'Value'));
    if strcmp('pls',model_type) || strcmp('pcr',model_type) || strcmp('ridge',model_type)
        maxvar = takevaluefrompopmenu(get(handles.pop_menu_02,'String'),get(handles.pop_menu_02,'Value'));
        numwindows = takevaluefrompopmenu(get(handles.pop_menu_05,'String'),get(handles.pop_menu_05,'Value'));
        if  maxvar > numwindows
            h1 = ['The number of windows (intervals of variables) must be higher than the maximum number of variables to be selected (' num2str(maxvar) ')'];
            warndlg([h1],'Variable selection')
        else
            handles.domodel = 1;
            guidata(hObject,handles)
            uiresume(handles.visualize_settings_ga)
        end
    else
        handles.domodel = 1;
        guidata(hObject,handles)
        uiresume(handles.visualize_settings_ga)
    end
else
    handles.domodel = 1;
    guidata(hObject,handles)
    uiresume(handles.visualize_settings_ga)
end

% --- Executes on button press in button_cancel.
function button_cancel_Callback(hObject, eventdata, handles)
handles.settings = NaN;
guidata(hObject,handles)
uiresume(handles.visualize_settings_ga)

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
handles = custom_form(handles);
guidata(hObject,handles);

% --- Executes on selection change in pop_menu_04.
function pop_menu_04_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_03_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in pop_menu_03.
function pop_menu_03_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_04_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_05.
function pop_menu_05_Callback(hObject, eventdata, handles)
if get(handles.pop_menu_01,'Value') == 2 || get(handles.pop_menu_01,'Value') == 1 % GA or forward
    model_type = handles.model_type(get(handles.pop_menu_01mod,'Value'));
    if strcmp('pls',model_type) || strcmp('pcr',model_type) || strcmp('ridge',model_type)
        if get(handles.pop_menu_05,'Value') > 1 % num windows > 0
            if get(handles.pop_menu_01,'Value') == 2 %GA
                set(handles.text03,'String','maximum number of windows:');
            elseif get(handles.pop_menu_01,'Value') == 1 %forward
                set(handles.text02,'String','maximum number of windows:');
            end    
        else
            if get(handles.pop_menu_01,'Value') == 2 %GA
                set(handles.text03,'String','maximum number of variables:');
            elseif get(handles.pop_menu_01,'Value') == 1 %forward
                set(handles.text02,'String','maximum number of variables:');
            end 
        end
    end
end

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

% --- Executes on selection change in pop_menu_08.
function pop_menu_08_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_08_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_01mod.
function pop_menu_01mod_Callback(hObject, eventdata, handles)
handles = custom_form_modelling(handles);
handles = custom_form(handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function pop_menu_01mod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_02mod.
function pop_menu_02mod_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_02mod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_03mod.
function pop_menu_03mod_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_03mod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_04mod.
function pop_menu_04mod_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_04mod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_menu_05mod.
function pop_menu_05mod_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pop_menu_05mod_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

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
    elseif strcmp(A,'gaussian')
        A = 'gaus';
    elseif strcmp(A,'triangular')
        A = 'tria';
    elseif strcmp(A,'binned Nearest Neighbours')
        A = 'bnn';
    elseif strcmp(A,'k Nearest Neighbours')
        A = 'knn'; 
    elseif strcmp(A,'Partial Least Squares')
        A = 'pls'; 
    elseif strcmp(A,'Principal Component Regression')
        A = 'pcr';
    elseif strcmp(A,'Ordinary Least Squares')
        A = 'pcr';
    elseif strcmp(A,'Ridge')
        A = 'ridge';
    elseif strcmp(A,'Genetic algorithms')
        A = 'ga';   
    elseif strcmp(A,'Reshaped Sequential Replacement')
        A = 'rsr';
    elseif strcmp(A,'Forward selection')
        A = 'forward';
    elseif strcmp(A,'venetian blinds cross validation')
        A = 'vene';        
    elseif strcmp(A,'contiguous blocks cross validation')
        A = 'cont';           
    elseif strcmp(A,'All subset selection')
        A = 'allsubset';
    end
end

% ------------------------------------------------------------------------
function handles = custom_formtype(handles)
% selection type
set(handles.text01,'Visible','on');
set(handles.text01,'String','selection method:');
set(handles.pop_menu_01,'Visible','on');
str_param = {};
str_param{1} = 'Forward selection';
str_param{2} = 'Genetic algorithms';
str_param{3} = 'Reshaped Sequential Replacement';
if handles.num_variables <= 15
    str_param{4} = 'All subset selection';
end
set(handles.pop_menu_01,'String',str_param);
set(handles.pop_menu_01,'Value',1);

% ------------------------------------------------------------------------
function handles = custom_form_modelling(handles)
% set cv type combo
set(handles.text04mod,'String','validation:');
str_disp={};
str_disp{1} = 'venetian blinds cross validation';
str_disp{2} = 'contiguous blocks cross validation';
set(handles.pop_menu_04mod,'String',str_disp);
set(handles.pop_menu_04mod,'Value',1);
% set cv groups
str_disp={};
cv_group(1) = 2;
cv_group(2) = 3;
cv_group(3) = 4;
cv_group(4) = 5;
cv_group(5) = 10;
cv_group(6) = handles.num_samples;
for j=1:length(cv_group)
    str_disp{j} = cv_group(j);
end
set(handles.text05mod,'String','number of cv groups:');
set(handles.pop_menu_05mod,'String',str_disp);
set(handles.pop_menu_05mod,'Value',4);
if get(handles.pop_menu_01mod,'Value') == 1 || get(handles.pop_menu_01mod,'Value') == 4 % ols or ridge
    set(handles.pop_menu_02mod,'Visible','off');
    set(handles.pop_menu_02mod,'String',{'none'});
    set(handles.pop_menu_03mod,'Visible','off');
    set(handles.pop_menu_03mod,'String',{'none'});
    set(handles.text02mod,'Visible','off');
    set(handles.text03mod,'Visible','off');
    y_position = handles.mypositions.y_position;
    x_position = handles.mypositions.x_position;
    step_for_text = handles.mypositions.step_for_text;
    set(handles.text02mod,'Position',[x_position y_position(4)+step_for_text 33 1.1]);
    set(handles.pop_menu_02mod,'Position',[x_position y_position(4) 33 1.7]);
    set(handles.text03mod,'Position',[x_position y_position(5)+step_for_text 33 1.1]);
    set(handles.pop_menu_03mod,'Position',[x_position y_position(5) 33 1.7]);
    set(handles.text04mod,'Position',[x_position y_position(2)+step_for_text 33 1.1]);
    set(handles.pop_menu_04mod,'Position',[x_position y_position(2) 33 1.7]);
    set(handles.text05mod,'Position',[x_position y_position(3)+step_for_text 33 1.1]);
    set(handles.pop_menu_05mod,'Position',[x_position y_position(3) 33 1.7]);
elseif get(handles.pop_menu_01mod,'Value') == 2 || get(handles.pop_menu_01mod,'Value') == 3 % pls or pcr
    set(handles.text02mod,'Visible','on');
    set(handles.pop_menu_02mod,'Visible','on');
    set(handles.text02mod,'String','data scaling:');
    str_scaling={};
    str_scaling{1} = 'none';
    str_scaling{2} = 'mean centering';
    str_scaling{3} = 'autoscaling';
    str_scaling{4} = 'range scaling';
    set(handles.pop_menu_02mod,'String',str_scaling);
    set(handles.pop_menu_02mod,'Value',3);
    set(handles.pop_menu_03mod,'Visible','off');
    set(handles.pop_menu_03mod,'String',{'none'});
    set(handles.text03mod,'Visible','off');
    y_position = handles.mypositions.y_position;
    x_position = handles.mypositions.x_position;
    step_for_text = handles.mypositions.step_for_text;
    set(handles.text02mod,'Position',[x_position y_position(2)+step_for_text 33 1.1]);
    set(handles.pop_menu_02mod,'Position',[x_position y_position(2) 33 1.7]);
    set(handles.text03mod,'Position',[x_position y_position(5)+step_for_text 33 1.1]);
    set(handles.pop_menu_03mod,'Position',[x_position y_position(5) 33 1.7]);
    set(handles.text04mod,'Position',[x_position y_position(3)+step_for_text 33 1.1]);
    set(handles.pop_menu_04mod,'Position',[x_position y_position(3) 33 1.7]);
    set(handles.text05mod,'Position',[x_position y_position(4)+step_for_text 33 1.1]);
    set(handles.pop_menu_05mod,'Position',[x_position y_position(4) 33 1.7]);
elseif get(handles.pop_menu_01mod,'Value') == 5 || get(handles.pop_menu_01mod,'Value') == 6 % knn or bnn
    set(handles.text02mod,'Visible','on');
    set(handles.pop_menu_02mod,'Visible','on');
    set(handles.text02mod,'String','data scaling:');
    str_scaling={};
    str_scaling{1} = 'none';
    str_scaling{2} = 'mean centering';
    str_scaling{3} = 'autoscaling';
    set(handles.pop_menu_02mod,'String',str_scaling);
    set(handles.pop_menu_02mod,'Value',3);
    set(handles.pop_menu_03mod,'Visible','on');
    set(handles.text03mod,'Visible','on');
    set(handles.text03mod,'String','distance:');
    str_disp={};
    str_disp{1} = 'euclidean';
    str_disp{2} = 'mahalanobis';
    str_disp{3} = 'cityblock';
    str_disp{4} = 'minkowski';
    set(handles.pop_menu_03mod,'String',str_disp);
    set(handles.pop_menu_03mod,'Value',1);    
    y_position = handles.mypositions.y_position;
    x_position = handles.mypositions.x_position;
    step_for_text = handles.mypositions.step_for_text;
    set(handles.text02mod,'Position',[x_position y_position(2)+step_for_text 33 1.1]);
    set(handles.pop_menu_02mod,'Position',[x_position y_position(2) 33 1.7]);
    set(handles.text03mod,'Position',[x_position y_position(3)+step_for_text 33 1.1]);
    set(handles.pop_menu_03mod,'Position',[x_position y_position(3) 33 1.7]);
    set(handles.text04mod,'Position',[x_position y_position(4)+step_for_text 33 1.1]);
    set(handles.pop_menu_04mod,'Position',[x_position y_position(4) 33 1.7]);
    set(handles.text05mod,'Position',[x_position y_position(5)+step_for_text 33 1.1]);
    set(handles.pop_menu_05mod,'Position',[x_position y_position(5) 33 1.7]);    
end

% ------------------------------------------------------------------------
function handles = custom_form(handles)
set(handles.visualize_settings_ga,'Name','Selection settings')
% num runs / min var
set(handles.text02,'Visible','on');
if get(handles.pop_menu_01,'Value') == 2 % ga
    set(handles.text02,'String','number of runs:');
elseif get(handles.pop_menu_01,'Value') == 3 % RSR
    set(handles.text02,'String','minimum number of variables:');
elseif get(handles.pop_menu_01,'Value') == 1 || get(handles.pop_menu_01,'Value') == 4 % forward or all subset
    set(handles.text02,'String','maximum number of variables:');
end
set(handles.pop_menu_02,'Visible','on');
str_param = {};
if get(handles.pop_menu_01,'Value') == 2
    str_param{1} = 50;
    str_param{2} = 100;
    str_param{3} = 500;
    set(handles.pop_menu_02,'String',str_param);
    set(handles.pop_menu_02,'Value',2);
elseif get(handles.pop_menu_01,'Value') == 3
    str_param{1} = 2;
    str_param{2} = 5;
    str_param{3} = 7;
    str_param{4} = 10;
    set(handles.pop_menu_02,'String',str_param);
    set(handles.pop_menu_02,'Value',1);
elseif get(handles.pop_menu_01,'Value') == 1
    nk = floor(handles.num_variables/10);
    if nk < 1
        str_param{1} = handles.num_variables;
    else
        for k=1:nk; str_param{k} = k*10; end
    end
    set(handles.pop_menu_02,'String',str_param);
    set(handles.pop_menu_02,'Value',1);
elseif get(handles.pop_menu_01,'Value') == 4
    str_param{1} = 2;
    str_param{2} = 3;
    str_param{3} = 4;
    str_param{4} = 5;
    set(handles.pop_menu_02,'String',str_param);
    set(handles.pop_menu_02,'Value',3);
end
% max var
set(handles.text03,'Visible','on');
set(handles.text03,'String','maximum number of variables:');
set(handles.pop_menu_03,'Visible','on');
str_param = {};
str_param{1} = 5;
str_param{2} = 10;
if handles.num_variables > 15
    str_param{3} = 15;
end
set(handles.pop_menu_03,'String',str_param);
set(handles.pop_menu_03,'Value',2);
if get(handles.pop_menu_01,'Value') == 1 || get(handles.pop_menu_01,'Value') == 4 % hide for forward and all subset
    set(handles.text03,'Visible','off');
    set(handles.text03,'String',{'NaN'});
    set(handles.pop_menu_03,'Visible','off');
else
    set(handles.text03,'Visible','on');
    set(handles.pop_menu_03,'Visible','on');    
end
% perc valid / seeds
set(handles.text04,'Visible','on');
if get(handles.pop_menu_01,'Value') == 3
    set(handles.text04,'String','number of seeds:');
end
set(handles.pop_menu_04,'Visible','on');
str_param = {};
str_param{1} = 2;
str_param{2} = 3;
str_param{3} = 4;
str_param{4} = 5;
set(handles.pop_menu_04,'String',str_param);
set(handles.pop_menu_04,'Value',2);
if get(handles.pop_menu_01,'Value') == 3 % RSR
    set(handles.text04,'Visible','on');
    set(handles.pop_menu_04,'Visible','on');   
else
    set(handles.text04,'Visible','off');
    set(handles.text04,'String',{'NaN'});
    set(handles.pop_menu_04,'Visible','off');
end
% num windows / tabu list
if get(handles.pop_menu_01,'Value') == 2 || get(handles.pop_menu_01,'Value') == 1 % GA or forward
    model_type = handles.model_type(get(handles.pop_menu_01mod,'Value'));
    if strcmp('ols',model_type) || strcmp('bnn',model_type) || strcmp('knn',model_type)
        set(handles.text05,'Visible','off');
        set(handles.pop_menu_05,'String',{'NaN'});
        set(handles.pop_menu_05,'Visible','off');
    else
        set(handles.text05,'Visible','on');
        set(handles.text05,'String','number of windows (intervals):');
        set(handles.pop_menu_05,'Visible','on');
        str_param = {};
        str_param{1} = 'none';
        str_param{2} = 25;
        str_param{3} = 50;
        str_param{4} = 100;
        str_param{5} = 150;
        str_param{6} = 200;
        set(handles.pop_menu_05,'String',str_param);
        set(handles.pop_menu_05,'Value',1);
        if get(handles.pop_menu_01,'Value') == 1 % forward
            set(handles.text05,'Position',[handles.mypositions.x_position handles.mypositions.y_position(3)+handles.mypositions.step_for_text 33 1.1]);
            set(handles.pop_menu_05,'Position',[handles.mypositions.x_position handles.mypositions.y_position(3) 33 1.7]);
        else % GA
            set(handles.text05,'Position',[handles.mypositions.x_position handles.mypositions.y_position(4)+handles.mypositions.step_for_text 33 1.1]);
            set(handles.pop_menu_05,'Position',[handles.mypositions.x_position handles.mypositions.y_position(4) 33 1.7]); 
        end 
    end
elseif get(handles.pop_menu_01,'Value') == 3 % RSR
    set(handles.text05,'Visible','on');
    set(handles.text05,'String','tabu list (faster selection):');
    set(handles.pop_menu_05,'Visible','on');
    str_param = {};
    str_param{1} = 'active';
    str_param{2} = 'inactive';
    set(handles.pop_menu_05,'String',str_param);
    set(handles.pop_menu_05,'Value',1);
    set(handles.text05,'Position',[handles.mypositions.x_position handles.mypositions.y_position(5)+handles.mypositions.step_for_text 33 1.1]);
    set(handles.pop_menu_05,'Position',[handles.mypositions.x_position handles.mypositions.y_position(5) 33 1.7]);
elseif get(handles.pop_menu_01,'Value') == 4 % all subset
    set(handles.text05,'Visible','off');
    set(handles.pop_menu_05,'String',{'NaN'});
    set(handles.pop_menu_05,'Visible','off');
end

