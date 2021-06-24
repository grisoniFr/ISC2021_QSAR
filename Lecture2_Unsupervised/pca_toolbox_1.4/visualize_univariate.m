function varargout = visualize_univariate(varargin)

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
                   'gui_OpeningFcn', @visualize_univariate_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_univariate_OutputFcn, ...
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


% --- Executes just before visualize_univariate is made visible.
function visualize_univariate_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for visualize_univariate
handles.output = hObject;
data_here = varargin{1};
handles.data = data_here.X;
handles.class = data_here.class;
handles.var_labels = data_here.variable_labels;
handles.sample_labels = data_here.sample_labels;
handles.class_labels =  data_here.class_labels;
handles.response =  data_here.response;
% parameters for position
x_position = 3.5;
step_for_text = 1.6;
% set main dimension
handles.manage_size.minimum_size = [0 0 150 40];
set(handles.output,'Position',handles.manage_size.minimum_size);
% uipanel
set(handles.myuipanel,'Position',[3.5 17 30 21]);%17
set(handles.text_xaxis,'Position',[x_position 17.5+step_for_text 23 1]);
set(handles.pop_xaxis,'Position',[x_position 17.5 23 1.5]);
set(handles.text_yaxis,'Position',[x_position 14+step_for_text 23 1]);
set(handles.pop_yaxis,'Position',[x_position 14 23 1.5]);
set(handles.chk_labels,'Position',[x_position 11.5 23 1.5]);
set(handles.chk_legend,'Position',[x_position 9.5 23 1.5]);
set(handles.button_help,'Position',[x_position 1 23 2]);
set(handles.button_export,'Position',[x_position 4 23 2]);
set(handles.button_class,'Position',[x_position 7 23 2]);
% plot area
[g4] = getplotposition(handles);
set(handles.myplot,'Position',g4);
movegui(handles.visualize_univariate,'center');
g2 = get(handles.myuipanel,'Position');
handles.manage_size.initial_frame = get(handles.output,'Position');
handles.manage_size.initial_height_uipanel = g2(2);
% set combo x axis
str_disp={};
for j=1:length(handles.var_labels)
    str_disp{j} = handles.var_labels{j};
end
set(handles.pop_xaxis,'String',str_disp);
set(handles.pop_xaxis,'Value',1);
% set combo y axis
str_disp={};
str_disp{1} = 'hist';
str_disp{2} = 'boxplot';
for j=1:length(handles.var_labels)
    str_disp{j+2} = handles.var_labels{j};
end
set(handles.pop_yaxis,'String',str_disp);
set(handles.pop_yaxis,'Value',1);
% update plot
update_plot(handles,0);
handles = enable_disable(handles);
% update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_univariate_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes when visualize_univariate is resized.
function visualize_univariate_SizeChangedFcn(hObject, eventdata, handles)
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
handles = enable_disable(handles);

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

% --- Executes on button press in button_class.
function button_class_Callback(hObject, eventdata, handles)
update_plot(handles,2)

% --- Executes on button press in chk_labels.
function chk_labels_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% --- Executes on button press in chk_legend.
function chk_legend_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% -------------------------------------------------------------------------
function handles = enable_disable(handles)
if (length(handles.class) > 0 || length(handles.response) > 0) && get(handles.pop_yaxis,'Value') > 2
    set(handles.chk_legend,'Enable','on');
else
    set(handles.chk_legend,'Enable','off');
end
if get(handles.pop_yaxis,'Value') > 2
    set(handles.chk_labels,'Enable','on');
else
    set(handles.chk_labels,'Enable','off');
end
if length(handles.class) > 0 && get(handles.pop_yaxis,'Value') < 3
    set(handles.button_class,'Enable','on');
else
    set(handles.button_class,'Enable','off');
end

% -------------------------------------------------------------------------
function update_plot(handles,external)
[col_ass,col_default] = visualize_colors;
x = get(handles.pop_xaxis,'Value');
y = get(handles.pop_yaxis,'Value');
show_label = get(handles.chk_labels,'Value');
show_legend = get(handles.chk_legend,'Value');
class_labels = handles.class_labels;
if size(handles.data,1) > 100
    bins = 20;
else
    bins = 10;
end
step = (max(handles.data(:,x)) - min(handles.data(:,x)))/bins;
binhere = [min(handles.data(:,x)):step:max(handles.data(:,x))];
% do raw profiles
if external > 0
    figure; set(gcf,'color','white'); box on;
else
    axes(handles.myplot); 
end
cla;
if y == 1
    if external < 2
        hist(handles.data(:,x),binhere)
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor',col_default(1,:),'EdgeColor','k');
        xlabel(handles.var_labels{x})
    else
        for g=1:max(handles.class)
            subplot(max(handles.class),1,g)
            color_in = col_ass(g+1,:);
            hist(handles.data(find(handles.class==g),x),binhere)
            h = findobj(gca,'Type','patch');
            set(h,'FaceColor',color_in,'EdgeColor','k');
            if length(class_labels) == 0
                x_str = [handles.var_labels{x} ' - class ' num2str(g)];
            else
                x_str = [handles.var_labels{x} ' - class ' class_labels{g}];
            end
            xlabel(x_str)
        end
    end
elseif y == 2
    if external < 2
        boxplot(handles.data(:,x))
        xlabel(handles.var_labels{x})
    else
        y_lim(1) = min(min(handles.data(:,x)));
        y_lim(2) = max(max(handles.data(:,x)));
        add_space_y = (y_lim(2) - y_lim(1))/20;
        y_lim(1) = y_lim(1) - add_space_y;
        y_lim(2) = y_lim(2) + add_space_y;
        for g=1:max(handles.class)
            subplot(1,max(handles.class),g)
            boxplot(handles.data(find(handles.class==g),x))
            xlabel([handles.var_labels{x} ' - class ' num2str(g)])
            axis([0.5 1.5 y_lim(1) y_lim(2)])
        end
    end
else
    if length(handles.class) > 0
        hold on
        for g=1:max(handles.class)
            color_in = col_ass(g+1,:);
            plot(handles.data(find(handles.class==g),x),handles.data(find(handles.class==g),y-2),'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',color_in)
            if length(class_labels) == 0
                legend_label{g} = ['class ' num2str(g)];
            else
                legend_label{g} = class_labels{g};
            end
        end
        hold off
    elseif length(handles.response) > 0
        hold on
        [My,wheremax] = max(handles.response);
        [my,wheremin] = min(handles.response);
        % add max and min for legend
        color_here = 1 - (handles.response(wheremax) - my)/(My - my);
        color_in = [color_here color_here color_here];
        plot(handles.data(wheremax,x),handles.data(wheremax,y-2),'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',color_in)
        legend_label{1} = ['max response'];
        color_here = 1 - (handles.response(wheremin) - my)/(My - my);
        color_in = [color_here color_here color_here];
        plot(handles.data(wheremin,x),handles.data(wheremin,y-2),'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',color_in)
        legend_label{2} = ['min response'];
        for g=1:length(handles.response)
            color_here = 1 - (handles.response(g) - my)/(My - my);
            color_in = [color_here color_here color_here];
            plot(handles.data(g,x),handles.data(g,y-2),'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',color_in)
        end
        hold off
    else
        plot(handles.data(:,x),handles.data(:,y-2),'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor','w')
    end
    y_lim(1) = min(min(handles.data(:,y-2)));
    y_lim(2) = max(max(handles.data(:,y-2)));
    x_lim(1) = min(min(handles.data(:,x)));
    x_lim(2) = max(max(handles.data(:,x)));
    add_space_y = (y_lim(2) - y_lim(1))/20;
    add_space_x = (x_lim(2) - x_lim(1))/20;
    y_lim(1) = y_lim(1) - add_space_y;
    y_lim(2) = y_lim(2) + add_space_y;
    x_lim(1) = x_lim(1) - add_space_x;
    x_lim(2) = x_lim(2) + add_space_x;
    axis([x_lim(1) x_lim(2) y_lim(1) y_lim(2)])
    xlabel(handles.var_labels{x})
    ylabel(handles.var_labels{y-2})
    if show_label
        hold on
        range_span = x_lim(2) - x_lim(1);
        add_span = range_span/100;
        for i=1:size(handles.data,1); text(handles.data(i,x)+add_span,handles.data(i,y-2),handles.sample_labels{i},'Color','k'); end;
        hold off
    end
    if show_legend
        legend(legend_label)
    else
        legend off
    end
end
if external == 1
    if y == 1
        title(['histogram of ' handles.var_labels{x}]);
    elseif y == 2
        title(['boxplot of ' handles.var_labels{x}]);
    else
        title(['biplot of ' handles.var_labels{x} ' and ' handles.var_labels{y-2}]); 
    end
end
box on
