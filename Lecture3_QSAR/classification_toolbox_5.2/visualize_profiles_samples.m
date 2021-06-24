function varargout = visualize_profiles_samples(varargin)

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
                   'gui_OpeningFcn', @visualize_profiles_samples_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_profiles_samples_OutputFcn, ...
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


% --- Executes just before visualize_profiles_samples is made visible.
function visualize_profiles_samples_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for visualize_profiles_samples
handles.output = hObject;
% parameters for position
x_position = 3.5;
step_for_text = 1.6;
% set main dimension
handles.manage_size.minimum_size = [0 0 150 38];
set(handles.output,'Position',handles.manage_size.minimum_size);
% uipanel
set(handles.myuipanel,'Position',[3.5 22 30 15]);%28
set(handles.text_xaxis,'Position',[x_position 11.5+step_for_text 23 1]);
set(handles.pop_xaxis,'Position',[x_position 11.5 23 1.5]);
set(handles.text_yaxis,'Position',[x_position 8+step_for_text 23 1]);
set(handles.pop_yaxis,'Position',[x_position 8 23 1.5]);
set(handles.button_help,'Position',[x_position 1 23 2]);
set(handles.button_export,'Position',[x_position 4 23 2]);
% plot area
[g4,g5] = getplotposition(handles);
set(handles.plot_raw,'Position',g4);
set(handles.plot_scaled,'Position',g5);
movegui(handles.visualize_profiles_samples,'center');
g2 = get(handles.myuipanel,'Position');
handles.manage_size.initial_frame = get(handles.output,'Position');
handles.manage_size.initial_height_uipanel = g2(2);
% get data
data_here = varargin{1};
handles.data = data_here.X;
handles.class = data_here.class;
handles.var_labels = data_here.variable_labels;
handles.var_labels = data_here.variable_labels;
handles.class_labels =  data_here.class_labels;

% set combo
str_disp={};
str_disp{1} = 'none';
str_disp{2} = 'mean centering';
str_disp{3} = 'autoscaling';
str_disp{4} = 'range scaling';
set(handles.pop_yaxis,'String',str_disp);
set(handles.pop_yaxis,'Value',3);

% init profiles combo
str_disp={};
str_disp{1} = 'samples';
str_disp{2} = 'average';
set(handles.pop_xaxis,'String',str_disp);
set(handles.pop_xaxis,'Value',2);

% update plot
update_plot(handles,0);
% update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_profiles_samples_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes when visualize_profiles_samples is resized.
function visualize_profiles_samples_SizeChangedFcn(hObject, eventdata, handles)
if isfield(handles,'output')
    [g2] = getuipanelposition(handles);
    set(handles.myuipanel,'Position',g2);
    [g4,g5] = getplotposition(handles);
    set(handles.plot_raw,'Position',g4);
    set(handles.plot_scaled,'Position',g5);
end

% ---------------------------------------------------------
function [g2] = getuipanelposition(handles)
g1 = get(handles.output,'Position');
g2 = get(handles.myuipanel,'Position');
g2(2) = handles.manage_size.initial_height_uipanel + g1(4) - handles.manage_size.initial_frame(4);

% ---------------------------------------------------------
function [g4,g5] = getplotposition(handles)
g1 = get(handles.output,'Position');
g2 = get(handles.myuipanel,'Position');
g4 = get(handles.plot_raw,'Position');
g5 = get(handles.plot_scaled,'Position');
p = (g1(3) - g2(3) - 4*g2(1))/g1(3);
g4(1) = 1 - p;
g4(3) = p*0.95;
g5(1) = 1 - p;
g5(3) = p*0.95;

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
web('help/gui_view.htm','-browser')

% ---------------------------------------------------------
function update_plot(handles,external)
data_raw = handles.data;
if get(handles.pop_yaxis,'Value') == 1
    pret_type = 'none';
elseif get(handles.pop_yaxis,'Value') == 2
    pret_type = 'cent';
elseif get(handles.pop_yaxis,'Value') == 3
    pret_type = 'auto';
else
    pret_type = 'rang';
end
data_scaled = data_pretreatment(data_raw,pret_type);
% plot raw data
if external
    figure; set(gcf,'color','white'); subplot(2,1,1); box on;
else
    axes(handles.plot_raw);
end
cla;
if get(handles.pop_xaxis,'Value') == 1 % samples
    plot_samples(data_raw,handles.class,handles.var_labels,'raw data',handles.class_labels)
else % average
    plot_mean(data_raw,handles.class,handles.var_labels,'raw data',handles.class_labels)
end
% plot scaled data
if external
    subplot(2,1,2); box on;
else
    axes(handles.plot_scaled);
end
cla;
if get(handles.pop_xaxis,'Value') == 1 % samples
    plot_samples(data_scaled,handles.class,handles.var_labels,'scaled data',handles.class_labels)
else % average
    plot_mean(data_scaled,handles.class,handles.var_labels,'scaled data',handles.class_labels)
end
xlabel('variables')

% -------------------------------------------------------------------------
function plot_mean(X,class,variable_labels,add_ylabel,class_labels)
max_variable_for_barplot = 20;
col_ass = visualize_colors;
if length(class) == 0
    P = mean(X);
else
    for g=1:max(class)
        in = find(class == g);
        P(g,:) = mean(X(in,:));
    end
end
hold on
if length(class) == 0
    plot(P,'Color','k')
    if size(P,2) < max_variable_for_barplot
        plot(P,'o','MarkerEdgeColor','k','MarkerFaceColor','w')
    end
else
    for g=1:max(class)
        color_in = col_ass(g+1,:);
        if length(class_labels) == 0
            str_legend{g} = ['class ' num2str(g)];
        else
            str_legend{g} = class_labels{g};
        end
        plot(P(g,:),'Color',color_in)
    end
    if size(P,2) < max_variable_for_barplot
        for g=1:max(class)
            color_in = col_ass(g+1,:);
            plot(P(g,:),'o','MarkerEdgeColor','k','MarkerFaceColor',color_in)
        end
    end
    legend(str_legend)
end
hold off
box on
ylabel(['average - ' add_ylabel])
range_y = max(max(P)) - min(min(P)); 
add_space_y = range_y/20;
y_lim = [min(min(P))-add_space_y max(max(P))+add_space_y];
if y_lim(1) == y_lim(2)
    y_lim(1) = -1;
    y_lim(2) = 1;
end
axis([0.5 size(P,2)+0.5 y_lim(1) y_lim(2)])
if size(P,2) < max_variable_for_barplot
    set(gca,'XTick',[1:size(P,2)])
    set(gca,'XTickLabel',variable_labels)
else
    step = round(size(P,2)/10);
    set(gca,'XTick',[1:step:size(P,2)])
    set(gca,'XTickLabel',variable_labels([1:step:size(P,2)]))
end

% -------------------------------------------------------------------------
function plot_samples(X,class,variable_labels,add_ylabel,class_labels)
max_variable_for_barplot = 20;
col_ass = visualize_colors;
hold on
if length(class) == 0
    plot(X','Color','k')
else
    for g=1:max(class)
        in = find(class==g);
        color_in = col_ass(g+1,:);
        legend_here = plot(X(in,:)','Color',color_in);
        plegend(g) = legend_here(1);
        if length(class_labels) == 0
            str_legend{g} = ['class ' num2str(g)];
        else
            str_legend{g} = class_labels{g};
        end
    end
    legend(plegend,str_legend);
end
hold off
box on
ylabel(['samples - ' add_ylabel])
range_y = max(max(X)) - min(min(X)); 
add_space_y = range_y/20;
y_lim = [min(min(X))-add_space_y max(max(X))+add_space_y];
if y_lim(1) == y_lim(2)
    y_lim(1) = -1;
    y_lim(2) = 1;
end
axis([0.5 size(X,2)+0.5 y_lim(1) y_lim(2)])
if size(X,2) < max_variable_for_barplot
    set(gca,'XTick',[1:size(X,2)])
    set(gca,'XTickLabel',variable_labels)
else
    step = round(size(X,2)/10);
    set(gca,'XTick',[1:step:size(X,2)])
    set(gca,'XTickLabel',variable_labels([1:step:size(X,2)]))
end
