function varargout = visualize_lambda(varargin)

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
                   'gui_OpeningFcn', @visualize_lambda_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_lambda_OutputFcn, ...
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


% --- Executes just before visualize_lambda is made visible.
function visualize_lambda_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
% parameters for position
x_position = 3.5;
step_for_text = 1.8;
% set main dimension
set(handles.output,'Position',[100 33 145 26]);
% uipanel
set(handles.myuipanel,'Position',[2 10.5 30 15]);
set(handles.text13,'Position',[x_position 10+step_for_text 26 1.1]);
set(handles.number_var_pop,'Position',[x_position 10 23 1.7]);
set(handles.button_help,'Position',[x_position 1 23 2]);
set(handles.select_variables_button,'Position',[x_position 4 23 2]);
set(handles.noselect_variables_button,'Position',[x_position 7 23 2]);
set(handles.wilks_plot,'Position',[45 4 97 21]);
movegui(handles.visualize_lambda,'center');
handles.data = varargin{1};

% initialize combo
str_disp = {};
for k = 1:size(handles.data.X,2)
    str_disp{k} = num2str(k);
end
set(handles.number_var_pop,'String',str_disp);
set(handles.number_var_pop,'Value',size(handles.data.X,2));
handles.select_var = 0;

X = handles.data.X;
class = handles.data.class;
[lambda,rank] = wilks_lambda(X,class);
handles.lambda = lambda;
handles.rank = rank;
% do plot
update_plot(handles);
guidata(hObject, handles);
uiwait(handles.visualize_lambda);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_lambda_OutputFcn(hObject, eventdata, handles)
len = length(handles);
if len > 0
    if handles.select_var == 1
        varargout{1} = handles.rank(1:get(handles.number_var_pop,'Value'));
        delete(handles.visualize_lambda)
    else
        varargout{1} = [];
        delete(handles.visualize_lambda)
    end
else
    varargout{1} = [];
end

% --- Executes on button press in select_variables_button.
function select_var_button_Callback(hObject, eventdata, handles)
handles.select_var = 1;
guidata(hObject,handles)
uiresume(handles.visualize_lambda)

% --- Executes on button press in noselect_variables_button.
function noselect_variables_button_Callback(hObject, eventdata, handles)
handles.select_var = 0;
guidata(hObject,handles)
uiresume(handles.visualize_lambda)

% --- Executes on button press in button_help.
function button_help_Callback(hObject, eventdata, handles)
web('help/gui_view.htm','-browser')

% --- Executes during object creation, after setting all properties.
function number_var_pop_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in number_var_pop.
function number_var_pop_Callback(hObject, eventdata, handles)
update_plot(handles);

% ---------------------------------------------------------
function update_plot(handles)
[~,col_default] = visualize_colors;
rank = handles.rank;
lambda = handles.lambda;
num_var_in = get(handles.number_var_pop,'Value');
axes(handles.wilks_plot); 
cla
bar(lambda,'FaceColor','w')
hold on
bar(lambda(1:num_var_in),'FaceColor',col_default(1,:))
hold off
variable_labels = handles.data.variable_labels;
variable_labels = variable_labels(rank);
set(gca,'xtick',[1:length(variable_labels)]);
set(gca,'xticklabel',variable_labels);
ylabel('Wilks lambda')
xlabel('variables')
box on
str{1,1} = 'variable';
str{1,2} = 'Wilks lambda';
axis([0 length(variable_labels) + 1 0 max(lambda) + max(lambda)/20 ])
