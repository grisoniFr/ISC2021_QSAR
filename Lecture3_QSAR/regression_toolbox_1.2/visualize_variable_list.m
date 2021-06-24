function varargout = visualize_variable_list(varargin)

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
                   'gui_OpeningFcn', @visualize_variable_list_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_variable_list_OutputFcn, ...
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

% --- Executes just before visualize_variable_list is made visible.
function visualize_variable_list_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
movegui(handles.visualize_variable_list,'center');
handles.variable_list = varargin{1};
% set dimensions
height_form = 20;
width_form = 40;
% parameters for positions
x_position = 2;
panel_width = 36; % 63
panel_height = 16; %8.5
% set positions
set(hObject,'Position',[103.8571 53.8 width_form height_form]);
% set buttons and panel
set(handles.listbox_variable_list,'Position',[x_position 2 panel_width panel_height]);
movegui(handles.visualize_variable_list,'center')
% update
handles = update_list(handles);
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_variable_list_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% --- Executes on selection change in listbox_variable_list.
function listbox_variable_list_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function listbox_variable_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%------------------------------------------------------------------------
function handles = update_list(handles)
set(handles.listbox_variable_list,'String',handles.variable_list);
