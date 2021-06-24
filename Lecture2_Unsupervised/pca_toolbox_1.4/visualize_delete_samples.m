function varargout = visualize_delete_samples(varargin)

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
                   'gui_OpeningFcn', @visualize_delete_samples_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_delete_samples_OutputFcn, ...
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


% --- Executes just before visualize_delete_samples is made visible.
function visualize_delete_samples_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
set(hObject,'Position',[103 48 56 11]);
set(handles.txt_sample,'Position',[2.5 3 48 4]);
set(handles.pop_samples,'Position',[2.5 8.7 22 1.7]);
set(handles.cancel_button,'Position',[2.5 1 17 2]);
set(handles.delete_button,'Position',[36.4 1 17 2]);
set(handles.text1,'Position',[2.5 7 47.5 1.1]);
movegui(handles.visualize_delete_samples,'center');
guidata(hObject, handles);

% set data to be saved
handles.num_samples = varargin{1};
handles.class = varargin{2};
handles.response = varargin{3};
handles.sample_labels = varargin{4};
handles.class_string = varargin{5};

% init sample combo
if length(handles.sample_labels) == 0
    for j=1:handles.num_samples; sample_labels{j} = ['sample ' num2str(j)]; end
else
    sample_labels = handles.sample_labels;
end
str_disp={};
for j=1:length(sample_labels)
    str_disp{j} = sample_labels{j};
end
set(handles.pop_samples,'String',str_disp);
set(handles.pop_samples,'Value',1);
handles = update_txtsample(handles);
guidata(hObject, handles);
uiwait(handles.visualize_delete_samples);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_delete_samples_OutputFcn(hObject, eventdata, handles)
len = length(handles);
if len > 0
    if handles.do_delete
        sample_out = get(handles.pop_samples,'Value');
        varargout{1} = sample_out;
    else
        varargout{1} = NaN;
    end
    delete(handles.visualize_delete_samples)
else
    varargout{1} = NaN;
end

% --- Executes on button press in delete_button.
function delete_button_Callback(hObject, eventdata, handles)
handles.do_delete = 1;
guidata(hObject, handles);
uiresume(handles.visualize_delete_samples)

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
handles.do_delete = 0;
guidata(hObject, handles);
uiresume(handles.visualize_delete_samples)

% --- Executes during object creation, after setting all properties.
function pop_samples_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in pop_samples.
function pop_samples_Callback(hObject, eventdata, handles)
handles = update_txtsample(handles);
guidata(hObject, handles);

% -----------------------------------------------------------
function handles = update_txtsample(handles)
in = get(handles.pop_samples,'Value');
h1 = ['sample id: ' num2str(in)];
if length(handles.class) > 0
    if length(handles.class_string) == 0
        h2 = ['sample class: ' num2str(handles.class(in))];
    else
        h2 = ['sample class: ' handles.class_string{in}];
    end
elseif length(handles.response) > 0
    h2 = ['sample response: ' num2str(handles.response(in))];
else
    h2 = ['sample class/response: not loaded'];
end
if length(handles.sample_labels) > 0
    h3 = ['sample label: ' handles.sample_labels{in}];
else
    h3 = ['sample label: not loaded'];
end
hr = sprintf('\n');
set(handles.txt_sample,'String',[h1 hr h2 hr h3]);
