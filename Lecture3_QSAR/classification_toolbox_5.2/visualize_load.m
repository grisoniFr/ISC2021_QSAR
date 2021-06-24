function varargout = visualize_load(varargin)

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
                   'gui_OpeningFcn', @visualize_load_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_load_OutputFcn, ...
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


% --- Executes just before visualize_load is made visible.
function visualize_load_OpeningFcn(hObject, eventdata, handles, varargin)

%handles.output = hObject;
set(hObject,'Position',[103 47 74 12]);
set(handles.button_load_from_file,'Position',[2 1 17 2]);
set(handles.button_cancel,'Position',[55 1 17 2]);
set(handles.text1,'Position',[2 10.5 32 1.1]);
set(handles.button_load,'Position',[35 1 17 2]);
set(handles.listbox_variables,'Position',[2 3.85 70 6.5]);
movegui(handles.visualize_load_form,'center');
if varargin{1} == 1
    handles.load_type = 'data';
elseif varargin{1} == 2
    handles.load_type = 'class';    
elseif varargin{1} == 3
    handles.load_type = 'model'; 
elseif varargin{1} == 4
    handles.load_type = 'sample_labels';     
elseif varargin{1} == 5
    handles.load_type = 'variable_labels';     
end

handles.num_samples = varargin{2};
handles.output.loaded_file = NaN;
handles.output.from_file = 0;

% update listbox
vars = evalin('base','whos');
handles = update_listbox(handles,vars);

guidata(hObject, handles);
uiwait(handles.visualize_load_form);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_load_OutputFcn(hObject, eventdata, handles)
len = length(handles);
if len > 0
    varargout{1} = handles.output;
    delete(handles.visualize_load_form)
else
    handles.output.loaded_file = NaN;
    varargout{1} = handles.output;
end

% --- Executes during object creation, after setting all properties.
function listbox_variables_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in listbox_variables.
function listbox_variables_Callback(hObject, eventdata, handles)

% --- Executes on button press in button_load.
function button_load_Callback(hObject, eventdata, handles)
if length(handles.vars_listed) == 0
    handles.output.loaded_file = NaN;
    guidata(hObject,handles)
    uiresume(handles.visualize_load_form)
else
    errortype = 'none';
    if strcmp(handles.load_type,'class')
        errortype = check_class(handles);
    elseif strcmp(handles.load_type,'model')
        errortype = check_model(handles);
    elseif strcmp(handles.load_type,'sample_labels')
        errortype = check_sample_labels(handles);
    elseif strcmp(handles.load_type,'variable_labels')
        errortype = check_variable_labels(handles);
    end
    if strcmp(errortype,'none')
        in = get(handles.listbox_variables,'Value');
        handles.output.name = handles.vars_listed(in).name;
        handles.output.loaded_file = 1;
        guidata(hObject,handles)
        uiresume(handles.visualize_load_form)
    else
        errordlg(errortype,'loading error') 
    end
end

% --- Executes on button press in button_cancel.
function button_cancel_Callback(hObject, eventdata, handles)
handles.output.loaded_file = NaN;
guidata(hObject,handles)
uiresume(handles.visualize_load_form)

% --- Executes on button press in button_load_from_file.
function button_load_from_file_Callback(hObject, eventdata, handles)
[FileName,PathName] = uigetfile('*.mat','Select mat-file');
if isstr(FileName)
    vars = whos('-file',[PathName FileName]);
    handles = update_listbox(handles,vars);
    handles.output.path = [PathName FileName];
    handles.output.from_file = 1;
    guidata(hObject,handles)
end

% -------------------------------------------------------------------------
function handles = update_listbox(handles,vars)

% filter type of data to be loaded
set(handles.listbox_variables,'Value',1);
cnt = 1;
vars_are_listed = 0;
if strcmp(handles.load_type,'data')
    for k = 1:length(vars)
        if strcmp (vars(k).class,'double')
            if (vars(k).size(2) > 1 & vars(k).size(1) > 1) & length(vars(k).size) == 2
                label_vars_in{cnt} = [vars(k).name '     [' num2str(vars(k).size(1)) 'x' num2str(vars(k).size(2)) ']     ' vars(k).class];
                vars_listed(cnt) = vars(k);
                vars_are_listed = 1;
                cnt = cnt + 1;
            end
        end
    end
elseif strcmp(handles.load_type,'class')
    for k = 1:length(vars)
        if strcmp (vars(k).class,'double') || strcmp (vars(k).class,'cell')
            if (vars(k).size(2) == 1 | vars(k).size(1) == 1)
                label_vars_in{cnt} = [vars(k).name '     [' num2str(vars(k).size(1)) 'x' num2str(vars(k).size(2)) ']     ' vars(k).class];
                vars_listed(cnt) = vars(k);
                vars_are_listed = 1;
                cnt = cnt + 1;
            end
        end
    end
elseif strcmp(handles.load_type,'model')
    for k = 1:length(vars)
        if strcmp (vars(k).class,'struct')
            if (vars(k).size(2) == 1 | vars(k).size(1) == 1)
                label_vars_in{cnt} = [vars(k).name '     [' num2str(vars(k).size(1)) 'x' num2str(vars(k).size(2)) ']     ' vars(k).class];
                vars_listed(cnt) = vars(k);
                vars_are_listed = 1;
                cnt = cnt + 1;
            end
        end
    end    
elseif strcmp(handles.load_type,'sample_labels')
    for k = 1:length(vars)
        if strcmp (vars(k).class,'cell')
            if (vars(k).size(2) == 1 | vars(k).size(1) == 1)
                label_vars_in{cnt} = [vars(k).name '     [' num2str(vars(k).size(1)) 'x' num2str(vars(k).size(2)) ']     ' vars(k).class];
                vars_listed(cnt) = vars(k);
                vars_are_listed = 1;
                cnt = cnt + 1;
            end
        end
    end
elseif strcmp(handles.load_type,'variable_labels')
    for k = 1:length(vars)
        if strcmp (vars(k).class,'cell')
            if (vars(k).size(2) == 1 | vars(k).size(1) == 1)
                label_vars_in{cnt} = [vars(k).name '     [' num2str(vars(k).size(1)) 'x' num2str(vars(k).size(2)) ']     ' vars(k).class];
                vars_listed(cnt) = vars(k);
                vars_are_listed = 1;
                cnt = cnt + 1;
            end
        end
    end  
end
if vars_are_listed
    set(handles.listbox_variables,'String',label_vars_in);
    handles.vars_listed = vars_listed;
else
    set(handles.listbox_variables,'String','no allowed variables in selected workspace');
    handles.vars_listed = [];
end

% -------------------------------------------------------------------------
function errortype = check_class(handles)
errortype = 'none';
if handles.output.from_file == 1
    tmp_data = load(handles.output.path);
    in = get(handles.listbox_variables,'Value');
    class = getfield(tmp_data,handles.vars_listed(in).name);
    if size(class,2) > size(class,1)
        class = class';
    end
else
    in = get(handles.listbox_variables,'Value');
    class = evalin('base',handles.vars_listed(in).name);
    if size(class,2) > size(class,1)
        class = class';
    end
end
if iscell(class)
    class = calc_class_string(class);
end
% class is string 
if isstr(class)                                     
    errortype = 'input error: class vectors must be a numerical vector';
    return
end
% number of classes 
if max(class) < 2 
    errortype = 'input error: not enough classes (only one class detected)';
    return
end
if max(class) > 10
    errortype = 'input error: too many classes detected. The maximum number of classes is 10';
    return
end
% no zeros
if length(find(class==0)) > 0                                         
    errortype = 'input error: class labels equal to zero are not allowed';
    return
end
% class labels are consecutive 
for g=1:max(class)
    cla_lab(g) = length(find(class == g));
end
if length(find(cla_lab == 0));     
    errortype = (['class labels must  be numbers from 1 to G (where G is the total number of classes) ' ...
                'i.e. the first class should be labelled as 1, the second one as 2 and so on.']);
    return
end
% no. of samples for data and class
if size(class,1) ~= handles.num_samples
    chk = 0;
    errortype = 'input error: data and class must have the same number of rows (objects)';
    return
end

% -------------------------------------------------------------------------
function errortype = check_model(handles)
errortype = 'none';
if handles.output.from_file == 1
    tmp_data = load(handles.output.path);
    in = get(handles.listbox_variables,'Value');
    model = getfield(tmp_data,handles.vars_listed(in).name);
else
    in = get(handles.listbox_variables,'Value');
    model = evalin('base',handles.vars_listed(in).name);
end
% model is a toolbox structure 
if ~isfield(model,'class_calc') | ~isfield(model,'class_param')
    errortype = 'input error: only classification models can be loaded. The selected structure is not recognized as a model created by this toolbox';
    return
end

% -------------------------------------------------------------------------
function errortype = check_sample_labels(handles)
errortype = 'none';
if handles.output.from_file == 1
    tmp_data = load(handles.output.path);
    in = get(handles.listbox_variables,'Value');
    labels = getfield(tmp_data,handles.vars_listed(in).name);
else
    in = get(handles.listbox_variables,'Value');
    labels = evalin('base',handles.vars_listed(in).name);
end
% settings is a toolbox structure
if length(labels) ~= handles.num_samples
    errortype = 'input error: sample labels must be structured as cell array with a number of elements equal to the number of samples';
end

% -------------------------------------------------------------------------
function errortype = check_variable_labels(handles)
errortype = 'none';
if handles.output.from_file == 1
    tmp_data = load(handles.output.path);
    in = get(handles.listbox_variables,'Value');
    labels = getfield(tmp_data,handles.vars_listed(in).name);
else
    in = get(handles.listbox_variables,'Value');
    labels = evalin('base',handles.vars_listed(in).name);
end
% settings is a toolbox structure
if length(labels) ~= handles.num_samples
    errortype = 'input error: variable labels must be structured as cell array with a number of elements equal to the number of variables';
end
