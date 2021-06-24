function varargout = visualize_contributions_samples(varargin)

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
                   'gui_OpeningFcn', @visualize_contributions_samples_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_contributions_samples_OutputFcn, ...
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


% --- Executes just before visualize_contributions_samples is made visible.
function visualize_contributions_samples_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for visualize_contributions_samples
handles.output = hObject;
%init data
handles.data.datain = varargin{1};
handles.data.datain_scal = varargin{2};
handles.data.variable_labels = varargin{3};
handles.data.sample_label = varargin{4};
closest = varargin{5};
handles.data.Tcont = varargin{6};
handles.data.Qcont = varargin{7};
handles.data.T2 = handles.data.Tcont(closest,:);
handles.data.Qres = handles.data.Qcont(closest,:);
% calculate T2 and Q res normnalised
[handles.data.T2_norm] = T2_Qres_normalised(handles.data.Tcont,handles.data.T2);
[handles.data.Qres_norm] = T2_Qres_normalised(handles.data.Qcont,handles.data.Qres);
% parameters for position
x_position = 3;
step_for_text = 1.6;
% set main dimension
handles.manage_size.minimum_size = [0 0 150 45];
set(handles.output,'Position',handles.manage_size.minimum_size);
% uipanel
set(handles.myuipanel,'Position',[3.5 28 30 15]);%28
set(handles.text_xaxis,'Position',[x_position 11.5+step_for_text 26 1]);
set(handles.pop_xaxis,'Position',[x_position 11.5 23 1.5]);
set(handles.text_yaxis,'Position',[x_position 8+step_for_text 26 1]);
set(handles.pop_yaxis,'Position',[x_position 8 23 1.5]);
set(handles.button_help,'Position',[x_position 1 23 2]);
set(handles.button_export,'Position',[x_position 4 23 2]);
% plot area
[g4,g5,g6] = getplotposition(handles);
set(handles.plot_variables,'Position',g4);
set(handles.plot_T2,'Position',g5);
set(handles.plot_Qres,'Position',g6);
movegui(handles.visualize_contributions_samples,'center');
g2 = get(handles.myuipanel,'Position');
handles.manage_size.initial_frame = get(handles.output,'Position');
handles.manage_size.initial_height_uipanel = g2(2);

% set Hot and Qres combo
str_disp={};
str_disp{1} = 'raw';
str_disp{2} = 'normalised';
set(handles.pop_yaxis,'String',str_disp);
set(handles.pop_yaxis,'Value',2);

% init profiles combo
str_disp={};
str_disp{1} = 'raw data';
str_disp{2} = 'scaled data';
set(handles.pop_xaxis,'String',str_disp);
set(handles.pop_xaxis,'Value',2);

% update plot
update_plot(handles,0);
% update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_contributions_samples_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes when visualize_contributions_samples is resized.
function visualize_contributions_samples_SizeChangedFcn(hObject, eventdata, handles)
if isfield(handles,'output')
    [g2] = getuipanelposition(handles);
    set(handles.myuipanel,'Position',g2);
    [g4,g5,g6] = getplotposition(handles);
    set(handles.plot_variables,'Position',g4);
    set(handles.plot_T2,'Position',g5);
    set(handles.plot_Qres,'Position',g6);
end

% ---------------------------------------------------------
function [g2] = getuipanelposition(handles)
g1 = get(handles.output,'Position');
g2 = get(handles.myuipanel,'Position');
g2(2) = handles.manage_size.initial_height_uipanel + g1(4) - handles.manage_size.initial_frame(4);

% ---------------------------------------------------------
function [g4,g5,g6] = getplotposition(handles)
g1 = get(handles.output,'Position');
g2 = get(handles.myuipanel,'Position');
g4 = get(handles.plot_variables,'Position');
g5 = get(handles.plot_T2,'Position');
g6 = get(handles.plot_Qres,'Position');
p = (g1(3) - g2(3) - 4*g2(1))/g1(3);
g4(1) = 1 - p;
g4(3) = p*0.95;
g5(1) = 1 - p;
g5(3) = p*0.95;
g6(1) = 1 - p;
g6(3) = p*0.95;

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

% -------------------------------------------------------------------------
function contrnorm = T2_Qres_normalised(tr,test)
[o,v]=size(tr);
p=o*.95;
[a,b]=sort(abs(tr));
if p==floor(p)
    cl=a(p,:);
else
    cl=a(floor(p),:).*(ceil(p)-p)+a(ceil(p),:).*(p-floor(p));
end
contrnorm = test./cl;

% ---------------------------------------------------------
function update_plot(handles,external)
max_variable_for_barplot = 20;
[~,col_default] = visualize_colors;
% plot variable profiles
if get(handles.pop_xaxis,'Value') == 1
    inplot_variables = handles.data.datain;
    title_list{1} = ['variable profile of sample ' handles.data.sample_label ' - raw data'];
else
    inplot_variables = handles.data.datain_scal;
    title_list{1} = ['variable profile of sample ' handles.data.sample_label ' - scaled data'];
end
% plot T2 and Qres
if get(handles.pop_yaxis,'Value') == 1
    inplot_T2 = handles.data.T2;
    inplot_Qres = handles.data.Qres;
    title_list{2} = ['Hotelling T^2 contributions of sample ' handles.data.sample_label];
    title_list{3} = ['Q contributions (residuals of scaled - calc) of sample ' handles.data.sample_label];
else
    inplot_T2 = handles.data.T2_norm;
    inplot_Qres = handles.data.Qres_norm;
    title_list{2} = ['normalised Hotelling T^2 contributions of sample ' handles.data.sample_label];
    title_list{3} = ['normalised Q contributions (residuals of scaled - calc) of sample ' handles.data.sample_label];
end
if external; figure; set(gcf,'color','white'); end
% plot variables
if external; subplot(3,1,1); else; axes(handles.plot_variables); end
cla;
hold on
box on
plot(inplot_variables,'Color',col_default(1,:))
if length(inplot_variables) < max_variable_for_barplot
    plot(inplot_variables,'o','MarkerSize',6,'MarkerFaceColor','w','MarkerEdgeColor',col_default(1,:))
end
range_y = max(max(inplot_variables)) - min(min(inplot_variables)); 
add_space_y = range_y/20;
y_lim = [min(min(inplot_variables))-add_space_y max(max(inplot_variables))+add_space_y];
axis([0.5 length(inplot_variables)+0.5 y_lim(1) y_lim(2)])
if length(inplot_variables) < max_variable_for_barplot
    set(gca,'XTick',[1:length(inplot_variables)])
    set(gca,'XTickLabel',handles.data.variable_labels)
else
    step = round(length(inplot_variables)/10);
    set(gca,'XTick',[1:step:length(inplot_variables)])
    set(gca,'XTickLabel',handles.data.variable_labels([1:step:length(inplot_variables)]))
end
title(title_list{1})
hold off
% plot T2
if external; subplot(3,1,2); else; axes(handles.plot_T2); end
cla;
hold on
box on
bar(inplot_T2,'FaceColor',col_default(1,:))
if length(inplot_T2) < max_variable_for_barplot
    set(gca,'XTick',[1:length(inplot_T2)])
    set(gca,'XTickLabel',handles.data.variable_labels)
else
    step = round(length(inplot_T2)/10);
    set(gca,'XTick',[1:step:length(inplot_T2)])
    set(gca,'XTickLabel',handles.data.variable_labels([1:step:length(inplot_T2)]))
end
mmT2 = min(min(inplot_T2));
MMT2 = max(max(inplot_T2));
range_y = max(inplot_T2) - min(inplot_T2);
add_space_y = range_y/20;
if get(handles.pop_yaxis,'Value') == 2
    if mmT2 > -1; mmT2 = -1; end
    if MMT2 < 1; MMT2 = 1; end
    if add_space_y < 0.1; add_space_y = 0.1; end
end
y_lim = [mmT2 - add_space_y MMT2 + add_space_y];
axis([0.5 length(inplot_T2)+0.5 y_lim(1) y_lim(2)])
if get(handles.pop_yaxis,'Value') == 2
    line([0.5 length(inplot_T2)+0.5],[-1 -1],'Color','r','LineStyle',':')
    line([0.5 length(inplot_T2)+0.5],[1 1],'Color','r','LineStyle',':')
end
title(title_list{2})
box on
hold off
% plot Qres
if external; subplot(3,1,3); else; axes(handles.plot_Qres); end
cla;
hold on
box on
bar(inplot_Qres,'FaceColor',col_default(1,:))
if length(inplot_Qres) < max_variable_for_barplot
    set(gca,'XTick',[1:length(inplot_Qres)])
    set(gca,'XTickLabel',handles.data.variable_labels)
else
    step = round(length(inplot_Qres)/10);
    set(gca,'XTick',[1:step:length(inplot_Qres)])
    set(gca,'XTickLabel',handles.data.variable_labels([1:step:length(inplot_Qres)]))
end
mmQres = min(min(inplot_Qres));
MMQres = max(max(inplot_Qres));
range_y = max(inplot_Qres) - min(inplot_Qres);
add_space_y = range_y/20;
if get(handles.pop_yaxis,'Value') == 2
    if mmQres > -1; mmQres = -1; end
    if MMQres < 1; MMQres = 1; end
    if add_space_y < 0.1; add_space_y = 0.1; end 
end
y_lim = [mmQres - add_space_y MMQres + add_space_y];
axis([0.5 length(inplot_Qres) + 0.5 y_lim(1) y_lim(2)])
if get(handles.pop_yaxis,'Value') == 2
    line([0.5 length(inplot_Qres)+0.5],[-1 -1],'Color','r','LineStyle',':')
    line([0.5 length(inplot_Qres)+0.5],[1 1],'Color','r','LineStyle',':')
end
title(title_list{3})
box on
hold off
