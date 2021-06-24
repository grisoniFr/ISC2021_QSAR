function varargout = visualize_gaselection(varargin)

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
                   'gui_OpeningFcn', @visualize_gaselection_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_gaselection_OutputFcn, ...
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


% --- Executes just before visualize_gaselection is made visible.
function visualize_gaselection_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
x_position = 3.5;
set(hObject,'Position',[103 48 223 25]);
set(handles.myuipanel,'Position',[x_position 1.5 31 22]);
set(handles.pop_models,'Position',[x_position 18 24 1.7]);
set(handles.text_model,'Position',[x_position 20 24 1.2]);
set(handles.select_button,'Position',[x_position 15 24 2]);
set(handles.plot_button,'Position',[x_position 10 24 2]);
set(handles.export_button,'Position',[x_position 7 24 2]);
set(handles.help_button,'Position',[x_position 4 24 2]);
set(handles.cancel_button,'Position',[x_position 1 24 2]);
set(handles.model_table,'Position',[x_position+31+3.5 1.5 180 22]);
movegui(handles.visualize_gaselection,'center');
guidata(hObject, handles);
% set data to be saved
handles.res_selection = varargin{1};
handles.X = varargin{2};
handles.variable_labels = varargin{3};
handles.ga_options = varargin{4};

% init model combo
str_disp={};
for j=1:length(handles.res_selection)
    str_disp{j} = num2str(j);
end
set(handles.pop_models,'String',str_disp);
set(handles.pop_models,'Value',1);
handles = update_table(handles);
handles = update_button_string(handles);
guidata(hObject, handles);
uiwait(handles.visualize_gaselection);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_gaselection_OutputFcn(hObject, eventdata, handles)
len = length(handles);
if len > 0
    varargout{1} = handles.var_selected;
    varargout{2} = handles.opt_param;
    varargout{3} = handles.domodel;
    delete(handles.visualize_gaselection)
else
    varargout{1} = NaN;
    varargout{2} = NaN;
    varargout{3} = 0;
end

% --- Executes on button press in select_button.
function select_button_Callback(hObject, eventdata, handles)
w = get(handles.pop_models,'Value');
% order variables on original rank
var_selected = handles.res_selection(w).selected_variables;
var_selected = sort(var_selected);
handles.var_selected = var_selected;
handles.opt_param = handles.res_selection(w).param;
handles.domodel = 1;
guidata(hObject, handles);
uiresume(handles.visualize_gaselection)

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
handles.opt_param = NaN;
handles.var_selected = NaN;
handles.domodel = 0;
guidata(hObject, handles);
uiresume(handles.visualize_gaselection)

% --- Executes during object creation, after setting all properties.
function pop_models_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in pop_models.
function pop_models_Callback(hObject, eventdata, handles)
handles = update_table(handles);
handles = update_button_string(handles);
guidata(hObject, handles);

% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
web('help/gui_calculate.htm','-browser')

% --- Executes on button press in export_button.
function export_button_Callback(hObject, eventdata, handles)
[~,table_export] = update_table(handles);
assignin('base','tmp_list_models_with_selected_variables',table_export);
openvar('tmp_list_models_with_selected_variables');

% --- Executes on button press in plot_button.
function plot_button_Callback(hObject, eventdata, handles)
figure; 
set(gcf,'color','white');
[~,col_default] = visualize_colors;
for k=1:length(handles.res_selection)
    F(k) = handles.res_selection(k).r2cv;
end
% do plot
hold on
bar(F,'FaceColor',col_default,'EdgeColor','k');
xlabel('model ID')
ylabel('R2 cv')
set(gca, 'YGrid', 'on', 'XGrid', 'off','GridLineStyle',':')
set(gca,'XTick',[1:length(F)])
xlim = [0 length(F) + 1];
if min(F) > 0.5
    miny = 0.5;
else
    miny = 0;
end
ylim = [miny 1];
axis([xlim ylim]);
box on
hold off

% -----------------------------------------------------------------------
function handles = update_button_string(handles)
disp_here = ['select model ' num2str(get(handles.pop_models,'Value'))];
set(handles.select_button,'String',disp_here);

% -----------------------------------------------------------------------
function [handles,table_export] = update_table(handles)
res_selection = handles.res_selection;
nformat3 = '%1.3f';
nformat4 = '%1.4f';
colourcell = @(color,text) ['<html><table border=0 width=900 bgcolor=',color,'><TR><TD>',text,'</TD></TR></table>'];
greytag = '#EFEFEF';
redtag = '#FC6C6C';
whitetag = '#FFFFFF';
for k=1:length(res_selection)
    colhere = 1;
    varlist = make_varlist(res_selection(k).selected_variables_labels);
    m = mod(k,2);
    if m == 1
        taghere = whitetag;
    elseif m == 0
        taghere = greytag;
    end
    if k == get(handles.pop_models,'Value')
        taghere = redtag;
    end
    table_here{k,colhere} = colourcell(taghere,num2str(length(res_selection(k).selected_variables))); 
    table_export{k,colhere} = num2str(length(res_selection(k).selected_variables));
    colhere = colhere + 1;
    if handles.ga_options.num_windows > 1
        table_here{k,colhere} = colourcell(taghere,num2str(res_selection(k).selected_windows));
        table_export{k,colhere} = num2str(res_selection(k).selected_windows);
        colhere = colhere + 1;
    end
    table_here{k,colhere} = colourcell(taghere,sprintf(nformat3,res_selection(k).r2cv)); 
    table_export{k,colhere} = sprintf(nformat3,res_selection(k).r2cv);
    colhere = colhere + 1;
    table_here{k,colhere} = colourcell(taghere,sprintf(nformat3,res_selection(k).r2)); 
    table_export{k,colhere} = sprintf(nformat3,res_selection(k).r2);
    colhere = colhere + 1;
    table_here{k,colhere} = colourcell(taghere,sprintf(nformat4,res_selection(k).rmsecv)); 
    table_export{k,colhere} = sprintf(nformat4,res_selection(k).rmsecv);
    colhere = colhere + 1;
    table_here{k,colhere} = colourcell(taghere,sprintf(nformat4,res_selection(k).rmse)); 
    table_export{k,colhere} = sprintf(nformat4,res_selection(k).rmse);
    colhere = colhere + 1;    
    if ~strcmp(handles.ga_options.method,'ols')
        table_here{k,colhere} = colourcell(taghere,[num2str(res_selection(k).param)]); 
        table_export{k,colhere} = num2str(res_selection(k).param); 
        colhere = colhere + 1;
    end
    table_here{k,colhere} = colourcell(taghere,varlist);
    table_export{k,colhere} = varlist;
end
if strcmp(handles.ga_options.method,'ols')
    handles.model_table.ColumnName = {'size';'R2 cv';'R2';'RMSE cv';'RMSE';'selected variables'};
    handles.model_table.ColumnWidth = {50 60 60 60 60 600};   
else
    if strcmp(handles.ga_options.method,'pls')
        labhere = 'LV';
    elseif strcmp(handles.ga_options.method,'pcr')
        labhere = 'PC';
    elseif strcmp(handles.ga_options.method,'knn')
        labhere = 'K';
    elseif strcmp(handles.ga_options.method,'ridge')
        labhere = 'K';
    else
        labhere = 'alpha';
    end
    if handles.ga_options.num_windows == 1
        handles.model_table.ColumnWidth = {50 60 60 60 60 50 600};
        handles.model_table.ColumnName = {'size';'R2 cv';'R2';'RMSE cv';'RMSE';labhere;'selected variables'};
    else
        handles.model_table.ColumnWidth = {50 50 60 60 60 60 50 600};
        handles.model_table.ColumnName = {'size';'windows';'R2 cv';'R2';'RMSE cv';'RMSE';labhere;'selected variables'};
    end
end
handles.model_table.RowName = 'numbered';
handles.model_table.RowStriping = 'on';
handles.model_table.Data = table_here;
table_export = [handles.model_table.ColumnName';table_export];

% -----------------------------------------------------------------------
function var_list = make_varlist(variables_labels)
var_list = variables_labels{1};
if isnumeric(var_list)
    var_list = num2str(var_list);
end
if length(variables_labels) > 1
    for k = 2:length(variables_labels)
        add_this = variables_labels{k};
        if isnumeric(add_this)
            add_this = num2str(add_this);
        end
        var_list = [var_list ', ' add_this];
    end
end
