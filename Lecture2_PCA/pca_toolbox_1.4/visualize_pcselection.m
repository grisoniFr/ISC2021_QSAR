function varargout = visualize_pcselection(varargin)

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
                   'gui_OpeningFcn', @visualize_pcselection_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_pcselection_OutputFcn, ...
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


% --- Executes just before visualize_pcselection is made visible.
function visualize_pcselection_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for visualize_pcselection
handles.output = hObject;
handles.res_compsel = varargin{1};
% parameters for position
x_position = 3.5;
step_for_text = 1.6;
% set main dimension
handles.manage_size.minimum_size = [0 0 150 40];
set(handles.output,'Position',handles.manage_size.minimum_size);
% uipanel
set(handles.myuipanel,'Position',[3.5 20 30 18]);%17
set(handles.text_xaxis,'Position',[x_position 14.5+step_for_text 23 1]);
set(handles.pop_xaxis,'Position',[x_position 14.5 23 1.5]);
set(handles.text_yaxis,'Position',[x_position 11+step_for_text 23 1]);
set(handles.pop_yaxis,'Position',[x_position 11 23 1.5]);
set(handles.button_help,'Position',[x_position 1 23 2]);
set(handles.button_export,'Position',[x_position 4 23 2]);
set(handles.button_eigen,'Position',[x_position 7 23 2]);
% plot area
[g4] = getplotposition(handles);
set(handles.myplot,'Position',g4);
movegui(handles.visualize_pcselection,'center');
g2 = get(handles.myuipanel,'Position');
handles.manage_size.initial_frame = get(handles.output,'Position');
handles.manage_size.initial_height_uipanel = g2(2);
% set combo x axis
str_disp={};
str_disp{1} = 'eigenvalues';
str_disp{2} = 'explained var';
str_disp{3} = 'cumulative var';
str_disp{4} = 'RMSECV';
str_disp{5} = 'IE';
str_disp{6} = 'IND';
set(handles.pop_xaxis,'String',str_disp);
set(handles.pop_xaxis,'Value',1);
% set combo y axis
str_disp = {};
num_comp = length(handles.res_compsel.settings.E)-1;
if num_comp > 20
    num_comp = 20;
end
for j=1:num_comp
    str_disp{j} = num2str(j+1);
end
set(handles.pop_yaxis,'String',str_disp);
set(handles.pop_yaxis,'Value',length(str_disp));
% update plot
update_plot(handles,0);
% update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_pcselection_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes when visualize_pcselection is resized.
function visualize_pcselection_SizeChangedFcn(hObject, eventdata, handles)
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
web('help/gui_calculate.htm','-browser')

% --- Executes on button press in button_eigen.
function button_eigen_Callback(hObject, eventdata, handles)
E = handles.res_compsel.settings.E;
exp_var = handles.res_compsel.settings.exp_var;
cum_var = handles.res_compsel.settings.cum_var;
str{1,1} = 'component';
str{1,2} = 'eigenvalue';
str{1,3} = 'explained variance %';
str{1,4} = 'cumulative variance %';
for k=1:length(E)
    str{k+1,1} = ['PC' num2str(k)];
    str{k+1,2} = num2str(E(k));
    str{k+1,3} = num2str((exp_var(k)*100*100)/100);
    str{k+1,4} = num2str((cum_var(k)*100*100)/100);
end
assignin('base','tmp_eigenvalues',str);
openvar('tmp_eigenvalues');

% -------------------------------------------------------------------------
function update_plot(handles,external)
[~,col_default] = visualize_colors;
maxcomp = get(handles.pop_yaxis,'Value') + 1;
whattoplot = get(handles.pop_xaxis,'String');
whattoplot = whattoplot(get(handles.pop_xaxis,'Value'));
if strcmp(whattoplot,'IND')
    plot_this = handles.res_compsel.IND(1:maxcomp);
    y_label = 'Malinowski Indicator Function';
elseif strcmp(whattoplot,'explained var')
    plot_this = handles.res_compsel.settings.exp_var(1:maxcomp);
    y_label = 'explained variance %';
elseif strcmp(whattoplot,'cumulative var')    
    plot_this = handles.res_compsel.settings.cum_var(1:maxcomp);
    y_label = 'cumulative variance %';
elseif strcmp(whattoplot,'RMSECV')
    if maxcomp <= length(handles.res_compsel.rmsecv)
        plot_this = handles.res_compsel.rmsecv(1:maxcomp);
    else
        plot_this = handles.res_compsel.rmsecv(1:length(handles.res_compsel.rmsecv));
    end
    y_label = ['RMSECV - ' num2str(handles.res_compsel.settings.cv_groups) ' cv groups'];
elseif strcmp(whattoplot,'IE')    
    plot_this = handles.res_compsel.IE(1:maxcomp);
    y_label = 'Imbedded Error';
else
    plot_this = handles.res_compsel.settings.E(1:maxcomp);
    y_label = 'eigenvalues';
end
if external; figure; set(gcf,'color','white'); else; axes(handles.myplot); end
cla;
hold on
box on
xmin = 0.5; xmax = (maxcomp + 0.5);
if strcmp(whattoplot,'eigenvalues')
    plot(plot_this,'Color',col_default(1,:))
    plot(plot_this,'o','MarkerSize',6,'MarkerFaceColor','w','MarkerEdgeColor',col_default(1,:))
    % AEC e CAEC lines
    if strcmp(handles.res_compsel.settings.pret_type,'auto')
        yline = 1;
    else
        yline = mean(handles.res_compsel.settings.E);
    end
    line([xmin xmax],[yline yline],'Color','r','LineStyle',':')
    line([xmin xmax],[yline*0.7 yline*0.7],'Color','b','LineStyle',':')
    set(gca,'YGrid','on','GridLineStyle',':')
    ymin = 0; ymax = max(plot_this)+0.1*max(plot_this);
    % AEC, CAEC, KP, KL labels
    line([handles.res_compsel.AEC handles.res_compsel.AEC],[ymin ymax],'Color','k','LineStyle',':')
    text(handles.res_compsel.AEC + 0.1,ymax - ymax/20,'AEC')
    line([handles.res_compsel.CAEC handles.res_compsel.CAEC],[ymin ymax],'Color','k','LineStyle',':')
    text(handles.res_compsel.CAEC + 0.1,ymax - 2*ymax/20,'CAEC')
    line([handles.res_compsel.KP handles.res_compsel.KP],[ymin ymax],'Color','k','LineStyle',':')
    text(handles.res_compsel.KP + 0.1,ymax - 3*ymax/20,'KP')
    line([handles.res_compsel.KL handles.res_compsel.KL],[ymin ymax],'Color','k','LineStyle',':')
    text(handles.res_compsel.KL + 0.1,ymax - 4*ymax/20,'KL')
elseif strcmp(whattoplot,'explained var') || strcmp(whattoplot,'cumulative var')
    bar(plot_this*100,'FaceColor',col_default(1,:))
    ymin = 0; ymax = 100;
    set(gca,'YGrid','on','GridLineStyle',':')
else
    plot(plot_this,'Color',col_default(1,:))
    plot(plot_this,'o','MarkerSize',6,'MarkerFaceColor','w','MarkerEdgeColor',col_default(1,:))
    set(gca,'YGrid','on','GridLineStyle',':')
    ymin = min(plot_this)-0.1*min(plot_this); ymax = max(plot_this)+0.1*max(plot_this);
end
set(gca,'xtick',[1:maxcomp]);
xlabel('Principal Components')
ylabel(y_label)
axis([xmin xmax ymin ymax])
hold off
