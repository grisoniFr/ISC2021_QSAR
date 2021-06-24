function varargout = visualize_clusteranalysis(varargin)

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
                   'gui_OpeningFcn', @visualize_clusteranalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_clusteranalysis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before visualize_clusteranalysis is made visible.
function visualize_clusteranalysis_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for visualize_clusteranalysis
handles.output = hObject;
handles.model = varargin{1};
% parameters for position
x_position = 3.5;
step_for_text = 1.6;
% set main dimension
handles.manage_size.minimum_size = [0 0 150 40];
set(handles.output,'Position',handles.manage_size.minimum_size);
% uipanel
set(handles.myuipanel,'Position',[3.5 24 30 14]);%17
set(handles.text_xaxis,'Position',[x_position 10.5+step_for_text 23 1]);
set(handles.pop_xaxis,'Position',[x_position 10.5 23 1.5]);
set(handles.button_help,'Position',[x_position 1 23 2]);
set(handles.button_export,'Position',[x_position 4 23 2]);
set(handles.button_save_clusters,'Position',[x_position 7 23 2]);
% plot area
[g4] = getplotposition(handles);
set(handles.myplot,'Position',g4);
movegui(handles.visualize_clusteranalysis,'center');
g2 = get(handles.myuipanel,'Position');
handles.manage_size.initial_frame = get(handles.output,'Position');
handles.manage_size.initial_height_uipanel = g2(2);
% set combo x axis
str_disp = {};
max_clust = 10;
if size(handles.model.settings.raw_data,1) < max_clust
    max_clust = floor(size(handles.model.settings.raw_data,1)/2);
end
for k = 1:max_clust;
    str_disp{k} = num2str(k);
end
set(handles.pop_xaxis,'String',str_disp);
set(handles.pop_xaxis,'Value',1);
% update plot
update_plot(handles,0);
% update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_clusteranalysis_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes when visualize_clusteranalysis is resized.
function visualize_clusteranalysis_SizeChangedFcn(hObject, eventdata, handles)
if isfield(handles,'output')
    [g2] = getuipanelposition(handles);
    set(handles.myuipanel,'Position',g2);
    [g4] = getplotposition(handles);
    set(handles.myplot,'Position',g4);
end

% ---------------------------------------------------------
function [g2] = getuipanelposition(handles)
g1 = get(handles.output,'Position');
g2 = get(handles.myuipanel,'Position');
g2(2) = handles.manage_size.initial_height_uipanel + g1(4) - handles.manage_size.initial_frame(4);

% ---------------------------------------------------------
function [g4] = getplotposition(handles)
g1 = get(handles.output,'Position');
g2 = get(handles.myuipanel,'Position');
g4 = get(handles.myplot,'Position');
p = (g1(3) - g2(3) - 4*g2(1))/g1(3);
g4(1) = 1 - p;
g4(3) = p*0.95;

% --- Executes on selection change in pop_xaxis.
function pop_xaxis_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% --- Executes during object creation, after setting all properties.
function pop_xaxis_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in button_export.
function button_export_Callback(hObject, eventdata, handles)
update_plot(handles,1)

% --- Executes on button press in button_help.
function button_help_Callback(hObject, eventdata, handles)
web('help/gui_results.htm','-browser')

% --- Executes on button press in button_save_clusters.
function button_save_clusters_Callback(hObject, eventdata, handles)
num_cluster = get(handles.pop_xaxis,'Value');
T = cluster(handles.model.L,'maxclust',num_cluster);
visualize_export(T,'cluster')

% -------------------------------------------------------------------------
function update_plot(handles,external)
x = get(handles.pop_xaxis,'Value');
% settings
L = handles.model.L;
num_cluster = get(handles.pop_xaxis,'Value');
find_thr = L(:,3);
thr = find_thr(end - num_cluster + 1);
thr = thr + 0.00001;

% display
if external
    figure; title('dendrogram'); set(gcf,'color','white'); box on; 
else
    axes(handles.myplot);
end
box on;
dendrogram(L,size(handles.model.settings.raw_data,1),'colorthreshold',thr);
xlabel('samples')
ylabel('distance')
box on; 
