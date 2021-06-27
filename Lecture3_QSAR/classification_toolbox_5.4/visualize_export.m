function varargout = visualize_export(varargin)

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
                   'gui_OpeningFcn', @visualize_export_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_export_OutputFcn, ...
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


% --- Executes just before visualize_export is made visible.
function visualize_export_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
set(hObject,'Position',[103 52 56 7]);
set(handles.cancel_button,'Position',[35 1 17 2]);
set(handles.save_button,'Position',[3.5 1 17 2]);
set(handles.variable_name_text,'Position',[3.5 3.4 49 1.5]);
set(handles.text1,'Position',[3.5 5 47.5 1.1]);
movegui(handles.visualize_export,'center');
guidata(hObject, handles);

% set data to be saved
handles.output = varargin{1};
type    = varargin{2};

if strcmp (type,'model')
    set(handles.variable_name_text,'String','model_name')
elseif strcmp (type,'cv')
    set(handles.variable_name_text,'String','cv_name')
elseif strcmp (type,'settings')
    set(handles.variable_name_text,'String','settings_name')
elseif strcmp (type,'cluster')
    set(handles.variable_name_text,'String','cluster_name')
elseif strcmp (type,'pred')
    set(handles.variable_name_text,'String','pred_name')    
end
guidata(hObject, handles);
uiwait(handles.visualize_export);


% --- Outputs from this function are returned to the command line.
function varargout = visualize_export_OutputFcn(hObject, eventdata, handles)
len = length(handles);
if len > 0
    varargout{1} = handles.output;
    delete(handles.visualize_export)
else
    handles.output = NaN;
    varargout{1} = handles.output;
end

% --- Executes during object creation, after setting all properties.
function variable_name_text_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function variable_name_text_Callback(hObject, eventdata, handles)

% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
variable_name = get(handles.variable_name_text,'String');
if length(variable_name) > 0
    assignin('base',variable_name,handles.output)
end
guidata(hObject, handles);
uiresume(handles.visualize_export)

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
uiresume(handles.visualize_export)
