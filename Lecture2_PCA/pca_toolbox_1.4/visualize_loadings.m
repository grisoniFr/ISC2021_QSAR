function varargout = visualize_loadings(varargin)

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
                   'gui_OpeningFcn', @visualize_loadings_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_loadings_OutputFcn, ...
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


% --- Executes just before visualize_loadings is made visible.
function visualize_loadings_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for visualize_loadings
handles.output = hObject;
% parameters for position
x_position = 3.5;
step_for_text = 1.6;
% set main dimension
handles.manage_size.minimum_size = [0 0 150 40];
set(handles.output,'Position',handles.manage_size.minimum_size);
% uipanel
set(handles.myuipanel,'Position',[3.5 21 30 17]);%28
set(handles.text_xaxis,'Position',[x_position 13.5+step_for_text 23 1]);
set(handles.pop_xaxis,'Position',[x_position 13.5 23 1.5]);
set(handles.text_yaxis,'Position',[x_position 10+step_for_text 23 1]);
set(handles.pop_yaxis,'Position',[x_position 10 23 1.5]);
set(handles.chk_labels,'Position',[x_position 7.5 23 1.5]);
set(handles.button_help,'Position',[x_position 1 23 2]);
set(handles.button_export,'Position',[x_position 4 23 2]);
% plot area
[g4] = getplotposition(handles);
set(handles.myplot,'Position',g4);
movegui(handles.visualize_loadings,'center');
g2 = get(handles.myuipanel,'Position');
handles.manage_size.initial_frame = get(handles.output,'Position');
handles.manage_size.initial_height_uipanel = g2(2);
% get data
handles.model = varargin{1};
% set combo axis
handles = set_variable_combo(handles);
% update plot
update_plot(handles,0);
% update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_loadings_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes when visualize_loadings is resized.
function visualize_loadings_SizeChangedFcn(hObject, eventdata, handles)
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

% --- Executes on selection change in pop_yaxis.
function pop_yaxis_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% --- Executes during object creation, after setting all properties.
function pop_yaxis_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in button_export.
function button_export_Callback(hObject, eventdata, handles)
update_plot(handles,1)

% --- Executes on button press in button_help.
function button_help_Callback(hObject, eventdata, handles)
web('help/gui_results.htm','-browser')

% --- Executes on button press in chk_labels.
function chk_labels_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% ---------------------------------------------------------
function update_plot(handles,external)
[~,col_default] = visualize_colors;
label_variable = get(handles.chk_labels, 'Value');
max_variable_for_barplot = 20;
variable_labels = handles.model.labels.variable_labels;
x = get(handles.pop_xaxis, 'Value');
y = get(handles.pop_yaxis, 'Value');
[Tx,Lab_Tx] = find_what_to_plot(handles,x);
[Ty,Lab_Ty] = find_what_to_plot(handles,y);
% display variables
if external; figure; title('variable plot'); set(gcf,'color','white'); box on; else; axes(handles.myplot); end
cla reset;
hold on
if strcmp(Lab_Tx,'variables')
    if length(Ty) < max_variable_for_barplot
        bar(Ty,'FaceColor',col_default(1,:))
    else
        plot(Ty,'Color',col_default(1,:))
    end
elseif strcmp(Lab_Ty,'variables')
    barh(Tx,'FaceColor',col_default(1,:))
else
    plot(Tx,Ty,'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',col_default(1,:))
end
xlabel(Lab_Tx)
ylabel(Lab_Ty)
if strcmp(Lab_Tx,'variables')
    range_span_y = (max(Ty) - min(Ty));
    y_lim(1) = min(Ty) - range_span_y/10;
    y_lim(2) = max(Ty) + range_span_y/10;
    x_lim = [0.5 length(Ty)+0.5];
    axis([x_lim(1) x_lim(2) y_lim(1) y_lim(2)])
    if length(Ty) < max_variable_for_barplot
        set(gca,'XTick',[1:length(Ty)])
        set(gca,'XTickLabel',variable_labels)
    else
        step = round(length(Ty)/10);
        set(gca,'XTick',[1:step:length(Ty)])
        set(gca,'XTickLabel',variable_labels([1:step:length(Ty)]))
    end
elseif strcmp(Lab_Ty,'variables')
    range_span_x = (max(Tx) - min(Tx));
    if min(Tx) > 0
        x_lim(1) = 0;
        x_lim(2) = max(Tx) + max(Tx)/10;
    elseif max(Tx) < 0
        x_lim(2) = 0;
        x_lim(1) = min(Tx) - min(Tx)/10;
    else
        x_lim(1) = min(Tx) - range_span_x/10;
        x_lim(2) = max(Tx) + range_span_x/10;
    end
    y_lim = [0.5 length(Ty)+0.5];
    axis([x_lim(1) x_lim(2) y_lim(1) y_lim(2)])
    if length(Tx) < max_variable_for_barplot
        set(gca,'YTick',[1:length(Tx)])
        set(gca,'YTickLabel',variable_labels)
    else
        step = round(length(Tx)/10);
        set(gca,'YTick',[1:step:length(Tx)])
        set(gca,'YTickLabel',variable_labels([1:step:length(Tx)]))
    end
else
    range_span_x = (max(Tx) - min(Tx));
    range_span_y = (max(Ty) - min(Ty));
    y_lim(1) = min(Ty) - range_span_y/10; y_lim(2) = max(Ty) + range_span_y/10;
    x_lim(1) = min(Tx) - range_span_x/10; x_lim(2) = max(Tx) + range_span_x/10;
    axis([x_lim(1) x_lim(2) y_lim(1) y_lim(2)])
end
line(x_lim,[0 0],'Color','k','LineStyle',':')
line([0 0],y_lim,'Color','k','LineStyle',':')
if (label_variable & ~strcmp(Lab_Ty,'variables')) & (label_variable & ~strcmp(Lab_Tx,'variables'))
    range_span = (x_lim(2) - x_lim(1));
    plot_string_label(Tx,Ty,'k',variable_labels,range_span);
end
box on
hold off

% ---------------------------------------------------------
function plot_string_label(X,Y,col,lab,range_span)
add_span = range_span/100;
for j=1:length(X); text(X(j)+add_span,Y(j),lab{j},'Color',col); end

% ---------------------------------------------------------
function [T,lab_T] = find_what_to_plot(handles,x)
T = handles.store_for_plot{x}.val;
lab_T = handles.store_for_plot{x}.lab;

% ---------------------------------------------------------
function handles = set_variable_combo(handles)
model = handles.model;
k = 0;
str_disp = {};
% variables ID
k = k + 1;
str_disp{k} = 'variables';
store_for_plot{k}.val = [1:size(model.settings.raw_data,2)]';
store_for_plot{k}.lab = 'variables';
if strcmp(model.type,'pca')
    % components
    for p = 1:size(model.L,2)
        k = k + 1;
        str_disp{k} = ['loadings on PC ' num2str(p)];
        store_for_plot{k}.val = model.L(:,p);
        lab = (['loadings on PC ' num2str(p) ' - EV = ' num2str(round(model.exp_var(p)*10000)/100) '%']);
        store_for_plot{k}.lab = lab;
        store_for_plot{k}.pred = [];
    end
end
if size(model.T,2) > 1
    start_x = 2; start_y = 3;
else
    start_x = 1; start_y = 2;
end
set(handles.pop_xaxis,'String',str_disp);
set(handles.pop_xaxis,'Value',start_x);
set(handles.pop_yaxis,'String',str_disp);
set(handles.pop_yaxis,'Value',start_y);
handles.store_for_plot = store_for_plot;
