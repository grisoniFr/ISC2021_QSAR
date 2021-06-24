function varargout = visualize_scores(varargin)

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
                   'gui_OpeningFcn', @visualize_scores_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_scores_OutputFcn, ...
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


% --- Executes just before visualize_scores is made visible.
function visualize_scores_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for visualize_scores
handles.output = hObject;
% parameters for position
x_position = 3.5;
step_for_text = 1.6;
% set main dimension
handles.manage_size.minimum_size = [0 0 150 40];
set(handles.output,'Position',handles.manage_size.minimum_size);
% uipanel
set(handles.myuipanel,'Position',[3.5 15 30 23]);
set(handles.text_xaxis,'Position',[x_position 19.5+step_for_text 23 1]);
set(handles.pop_xaxis,'Position',[x_position 19.5 23 1.5]);
set(handles.text_yaxis,'Position',[x_position 16+step_for_text 23 1]);
set(handles.pop_yaxis,'Position',[x_position 16 23 1.5]);
set(handles.chk_labels,'Position',[x_position 13 23 1.5]);
set(handles.chk_colour,'Position',[x_position 11 23 1.5]);
set(handles.button_help,'Position',[x_position 1 23 2]);
set(handles.button_export,'Position',[x_position 4 23 2]);
set(handles.button_view,'Position',[x_position 7 23 2]);
% plot area
[g4] = getplotposition(handles);
set(handles.myplot,'Position',g4);
movegui(handles.visualize_scores,'center');
g2 = get(handles.myuipanel,'Position');
handles.manage_size.initial_frame = get(handles.output,'Position');
handles.manage_size.initial_height_uipanel = g2(2);
% get data
handles.model = varargin{1};
handles.pred = varargin{2};
if length(varargin) > 2
    handles.showspecificmodel = varargin{3};
else
    handles.showspecificmodel = 'none';
end
% set combo axis
handles = set_sample_combo(handles);
set(handles.chk_colour,'Enable','on');
set(handles.chk_colour,'Value',0);
% update plot
update_plot(handles,0);
% update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = visualize_scores_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes when visualize_scores is resized.
function visualize_scores_SizeChangedFcn(hObject, eventdata, handles)
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

% --- Executes on button press in button_view.
function button_view_Callback(hObject, eventdata, handles)
select_sample(handles)

% --- Executes on button press in chk_colour.
function chk_colour_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% --- Executes on button press in chk_labels.
function chk_labels_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% ---------------------------------------------------------
function update_plot(handles,external)
[col_ass,col_default] = visualize_colors;
X = handles.model.settings.raw_data;
sample_labels  = handles.model.labels.sample_labels;
label_sample   = get(handles.chk_labels, 'Value');
show_colour    = get(handles.chk_colour, 'Value');
x = get(handles.pop_xaxis, 'Value');
y = get(handles.pop_yaxis, 'Value');
[Tx,Lab_Tx,Tx_pred] = find_what_to_plot(handles,x);
[Ty,Lab_Ty,Ty_pred] = find_what_to_plot(handles,y);
LineWidth_for_thresholds = 1;
% set figure
if external; figure; title('sample plot'); set(gcf,'color','white'); else; axes(handles.myplot); end
cla;
hold on
% display samples
if show_colour == 1
    response_here = handles.model.settings.raw_y;
    [My,wheremax] = max(response_here);
    [my,wheremin] = min(response_here);
    % add max and min for legend
    color_here = 1 - (response_here(wheremax) - my)/(My - my);
    color_in = [color_here color_here color_here];
    plot(Tx(wheremax),Ty(wheremax),'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',color_in)
    legend_label{1} = ['max response'];
    color_here = 1 - (response_here(wheremin) - my)/(My - my);
    color_in = [color_here color_here color_here];
    plot(Tx(wheremin),Ty(wheremin),'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',color_in)
    legend_label{2} = ['min response'];
    for g=1:length(Tx)
        color_here = 1 - (response_here(g) - my)/(My - my);
        color_in = [color_here color_here color_here];
        plot(Tx(g),Ty(g),'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',color_in)
    end
else
    plot(Tx,Ty,'o','MarkerEdgeColor',col_default,'MarkerSize',5,'MarkerFaceColor',[1 1 1]);
end
% plot predicted samples
if length(Tx_pred) > 0 && length(Ty_pred) > 0
    plot(Tx_pred,Ty_pred,'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',col_ass(3,:))
    range_plot_x = [Tx;Tx_pred];
    range_plot_y = [Ty;Ty_pred];
    if label_sample
        range_span = (max(range_plot_x) - min(range_plot_x));
        plot_string_label(Tx_pred,Ty_pred,'r',handles.pred.sample_labels,range_span);
    end
else
    range_plot_x = Tx;
    range_plot_y = Ty;
end
% add labels
if label_sample
    range_span = (max(range_plot_x) - min(range_plot_x));
    plot_string_label(Tx,Ty,'k',sample_labels,range_span);
end
% set max and min for axis
range_x = max(range_plot_x) - min(range_plot_x); add_space_x = range_x/20;      
x_lim = [min(range_plot_x)-add_space_x max(range_plot_x)+add_space_x];
range_y = max(range_plot_y) - min(range_plot_y); add_space_y = range_y/20;      
y_lim = [min(range_plot_y)-add_space_y max(range_plot_y)+add_space_y];
if strcmp(Lab_Tx,'samples')
    range_x = size(X,1) + length(Tx_pred) - 1; add_space_x = range_x/20;      
    x_lim = [1-add_space_x (size(X,1) + length(Tx_pred))+add_space_x];       
elseif strcmp(Lab_Tx,'leverages')
    this = find_max_axis(x_lim(2),3*mean(handles.model.H));
    x_lim = [0 this];
elseif strcmp(Lab_Tx,'std residuals')
    this_max = find_max_axis(x_lim(2),2);
    this_min = find_min_axis(x_lim(1),-2);
    x_lim = [this_min this_max];    
elseif strcmp(Lab_Tx,'Q residuals')
    qlim = handles.model.settings.qlim;
    if ~isnan(qlim); this = find_max_axis(x_lim(2),qlim); x_lim = [x_lim(1) this]; end
elseif strcmp(Lab_Tx,'Hotelling T^2')
    tlim = handles.model.settings.tlim;
    if ~isnan(tlim); this = find_max_axis(x_lim(2),tlim); x_lim = [x_lim(1) this]; end
end
if strcmp(Lab_Ty,'samples')
    range_y = size(X,1) + length(Ty_pred) - 1; add_space_y = range_y/20;      
    y_lim = [1-add_space_y (size(X,1) + length(Tx_pred))+add_space_y]; 
elseif strcmp(Lab_Ty,'leverages')
    this = find_max_axis(y_lim(2),3*mean(handles.model.H));
    y_lim = [0 this];
elseif strcmp(Lab_Ty,'std residuals')
    this_max = find_max_axis(y_lim(2),2);
    this_min = find_min_axis(y_lim(1),-2);
    y_lim = [this_min this_max];    
elseif strcmp(Lab_Ty,'Q residuals')
    qlim = handles.model.settings.qlim;
    if ~isnan(qlim); this = find_max_axis(y_lim(2),qlim); y_lim = [y_lim(1) this]; end
elseif strcmp(Lab_Ty,'Hotelling T^2')
    tlim = handles.model.settings.tlim;
    if ~isnan(tlim); this = find_max_axis(y_lim(2),tlim); y_lim = [y_lim(1) this]; end    
end
% draw lines x axis
if strcmp(Lab_Tx,'leverages')
    line([3*mean(handles.model.H) 3*mean(handles.model.H)],y_lim,'Color','r','LineStyle',':','LineWidth',LineWidth_for_thresholds)
elseif length(strfind(Lab_Tx,'scores')) > 0
    line([0 0],y_lim,'Color','k','LineStyle',':')
elseif strcmp(Lab_Tx,'Q residuals')
    qlim = handles.model.settings.qlim;
    if ~isnan(qlim); line([qlim qlim],y_lim,'Color','r','LineStyle',':','LineWidth',LineWidth_for_thresholds); end
elseif strcmp(Lab_Tx,'Hotelling T^2')
    tlim = handles.model.settings.tlim;
    if ~isnan(tlim); line([tlim tlim],y_lim,'Color','r','LineStyle',':','LineWidth',LineWidth_for_thresholds); end
elseif strcmp(Lab_Tx,'residuals')
    line([0 0],y_lim,'Color','k','LineStyle',':')
elseif strcmp(Lab_Tx,'std residuals')
    line([0 0],y_lim,'Color','k','LineStyle',':')
    line([2 2],y_lim,'Color','r','LineStyle',':','LineWidth',LineWidth_for_thresholds)
    line([-2 -2],y_lim,'Color','r','LineStyle',':','LineWidth',LineWidth_for_thresholds)
end
% draw lines y axis
if strcmp(Lab_Ty,'leverages')
    line(x_lim,[3*mean(handles.model.H) 3*mean(handles.model.H)],'Color','r','LineStyle',':','LineWidth',LineWidth_for_thresholds)
elseif length(strfind(Lab_Ty,'scores')) > 0
    line(x_lim,[0 0],'Color','k','LineStyle',':')
elseif strcmp(Lab_Ty,'Q residuals')
    qlim = handles.model.settings.qlim;
    if ~isnan(qlim); line(x_lim,[qlim qlim],'Color','r','LineStyle',':','LineWidth',LineWidth_for_thresholds); end
elseif strcmp(Lab_Ty,'Hotelling T^2')
    tlim = handles.model.settings.tlim;
    if ~isnan(tlim); line(x_lim,[tlim tlim],'Color','r','LineStyle',':','LineWidth',LineWidth_for_thresholds); end
elseif strcmp(Lab_Ty,'residuals')
    line(x_lim,[0 0],'Color','k','LineStyle',':')
elseif strcmp(Lab_Ty,'std residuals')
    line(x_lim,[0 0],'Color','k','LineStyle',':')
    line(x_lim,[2 2],'Color','r','LineStyle',':','LineWidth',LineWidth_for_thresholds)
    line(x_lim,[-2 -2],'Color','r','LineStyle',':','LineWidth',LineWidth_for_thresholds)
end
% experimental vs calculated
if strcmp(Lab_Ty,'experimental response') && (strcmp(Lab_Tx,'calculated response') || strcmp(Lab_Tx,'cross validated response'))
    M = max([x_lim y_lim]);
    m = min([x_lim y_lim]);
    x_lim(1) = m; x_lim(2) = M; y_lim = x_lim;
    line(x_lim,y_lim,'Color','r','LineStyle',':','LineWidth',LineWidth_for_thresholds)
elseif strcmp(Lab_Tx,'experimental response') && (strcmp(Lab_Ty,'calculated response') || strcmp(Lab_Ty,'cross validated response'))
    M = max([x_lim y_lim]);
    m = min([x_lim y_lim]);
    x_lim(1) = m; x_lim(2) = M; y_lim = x_lim;
    line(x_lim,y_lim,'Color','r','LineStyle',':','LineWidth',LineWidth_for_thresholds)    
end
% set axis limits and labels
axis([x_lim(1) x_lim(2) y_lim(1) y_lim(2)])
xlabel(Lab_Tx)
ylabel(Lab_Ty)
if show_colour == 1
    legend(legend_label);
else
    legend off
end
box on; 
hold off

% ---------------------------------------------------------
function plot_string_label(X,Y,col,lab,range_span)
add_span = range_span/100;
for j=1:length(X); text(X(j)+add_span,Y(j),lab{j},'Color',col); end

% ---------------------------------------------------------
function [T,lab_T,T_pred] = find_what_to_plot(handles,x)
T = handles.store_for_plot{x}.val;
lab_T = handles.store_for_plot{x}.lab;
T_pred = handles.store_for_plot{x}.pred;

% ---------------------------------------------------------
function this = find_max_axis(x1,x2)
m = max([x1 x2]);
this = m + m/20;

% ---------------------------------------------------------
function this = find_min_axis(x1,x2)
m = min([x1 x2]);
this = m - m/20;

% ---------------------------------------------------------
function select_sample(handles)
sample_labels = handles.model.labels.sample_labels;
if isstruct (handles.pred)
    if size(sample_labels,2)> size(sample_labels,1); sample_labels = sample_labels'; end
    sample_labels = [sample_labels;handles.pred.sample_labels];
end
variable_labels = handles.model.labels.variable_labels;
x = get(handles.pop_xaxis, 'Value');
y = get(handles.pop_yaxis, 'Value');
[Tx,Lab_Tx,Tx_pred] = find_what_to_plot(handles,x);
[Ty,Lab_Ty,Ty_pred] = find_what_to_plot(handles,y);
if size(Tx,1) < size(Tx,2); Tx = Tx'; end
if size(Tx_pred,1) < size(Tx_pred,2); Tx_pred = Tx_pred'; end
if length(Tx_pred)==length(Ty_pred)
    Tx = [Tx;Tx_pred];
    Ty = [Ty;Ty_pred];
end
if size(Ty,2) > size(Ty,1); Ty=Ty'; end
if size(Tx,2) > size(Tx,1); Tx=Tx'; end
Xd = [Tx Ty];
[x_sel,y_sel] = ginput(1);
xd = [x_sel y_sel];
D_squares_x = (sum(xd'.^2))'*ones(1,size(Xd,1));
D_squares_w = sum(Xd'.^2);
D_product   = - 2*(xd*Xd');
D = (D_squares_x + D_squares_w + D_product).^0.5;
[d_min,closest] = min(D);
update_plot(handles,0)
axes(handles.myplot);
hold on
plot(Tx(closest),Ty(closest),'o','MarkerEdgeColor','r','MarkerSize',8)
plot(Tx(closest),Ty(closest),'o','MarkerEdgeColor','r','MarkerSize',11)
hold off
% find data
if isstruct (handles.pred)
    raw_data = [handles.model.settings.raw_data;handles.pred.X];
else
    raw_data = handles.model.settings.raw_data;    
end
datain = raw_data(closest,:);
if isfield(handles.model.settings,'px')
    datain_scal = test_pretreatment(datain,handles.model.settings.px);
else
    [xsc,param] = data_pretreatment(raw_data,'auto');
    datain_scal = test_pretreatment(datain,param);
end
% make plots
if strcmp(handles.model.type,'ols') || strcmp(handles.model.type,'ridge')
    max_variable_for_barplot = 20;
    [~,col_default] = visualize_colors;
    figure
    subplot(2,1,1)
    hold on
    inplot = datain_scal;
    plot(inplot)
    if length(inplot) < max_variable_for_barplot
        plot(inplot,'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
    end
    hold off
    range_y = max(max(inplot)) - min(min(inplot));
    add_space_y = range_y/20;
    y_lim = [min(min(inplot))-add_space_y max(max(inplot))+add_space_y];
    axis([0.5 length(inplot)+0.5 y_lim(1) y_lim(2)])
    if length(inplot) < max_variable_for_barplot
        set(gca,'XTick',[1:length(inplot)])
        set(gca,'XTickLabel',variable_labels)
    else
        step = round(length(inplot)/10);
        set(gca,'XTick',[1:step:length(inplot)])
        set(gca,'XTickLabel',variable_labels([1:step:length(inplot)]))
    end
    % xlabel('variables')
    title(['variable profile of sample ' sample_labels{closest} ' - scaled data'])
    set(gcf,'color','white')
    box on
    subplot(2,1,2)
    hold on
    inplot = datain;
    plot(inplot)
    if length(inplot) < max_variable_for_barplot
        plot(inplot,'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
    end
    hold off
    range_y = max(max(inplot)) - min(min(inplot));
    add_space_y = range_y/20;
    y_lim = [min(min(inplot))-add_space_y max(max(inplot))+add_space_y];
    axis([0.5 length(inplot)+0.5 y_lim(1) y_lim(2)])
    if length(inplot) < max_variable_for_barplot
        set(gca,'XTick',[1:length(inplot)])
        set(gca,'XTickLabel',variable_labels)
    else
        step = round(length(inplot)/10);
        set(gca,'XTick',[1:step:length(inplot)])
        set(gca,'XTickLabel',variable_labels([1:step:length(inplot)]))
    end
    if ~strcmp(handles.model.type,'plsda')
        xlabel('variables')
    end
    title(['variable profile of sample ' sample_labels{closest} ' - raw data'])
    set(gcf,'color','white')
    box on
else % pls, pcr
    if isstruct(handles.pred)
        Tcont = [handles.model.Tcont; handles.pred.Tcont];
        Qcont = [handles.model.Qcont; handles.pred.Qcont];
    else
        Tcont = handles.model.Tcont;
        Qcont = handles.model.Qcont;
    end
    visualize_contributions_samples(datain,datain_scal,variable_labels,sample_labels{closest},closest,Tcont,Qcont);
end

% ---------------------------------------------------------
function handles = set_sample_combo(handles)
model = handles.model;
pred = handles.pred;
k = 0;
str_disp = {};
% samples ID
k = k + 1;
str_disp{k} = 'samples';
store_for_plot{k}.val = [1:size(model.settings.raw_data,1)]';
store_for_plot{k}.lab = 'samples';
store_for_plot{k}.pred = [];
if isstruct(pred)
    ntrain = size(model.settings.raw_data,1);
    store_for_plot{k}.pred = [ntrain + 1:ntrain + size(pred.X,1)]';
end
% experimental y
k = k + 1;
str_disp{k} = 'y exp';
store_for_plot{k}.val = model.settings.raw_y;
store_for_plot{k}.lab = 'experimental response';
store_for_plot{k}.pred = [];
if isstruct(pred)
    if isfield(pred,'response')
        store_for_plot{k}.pred = pred.response;
    end
end
% calculated y
k = k + 1;
str_disp{k} = 'y calc';
store_for_plot{k}.val = model.yc;
store_for_plot{k}.lab = 'calculated response';
store_for_plot{k}.pred = [];
if isstruct(pred)
    store_for_plot{k}.pred = pred.yc;
end
% cv y
if isstruct(model.cv)
    if strcmp (model.cv.settings.cv_type,'vene') || strcmp (model.cv.settings.cv_type,'cont')
        k = k + 1;
        str_disp{k} = 'y calc cv';
        store_for_plot{k}.val = model.cv.yc;
        store_for_plot{k}.lab = 'cross validated response';
        store_for_plot{k}.pred = [];
        if isstruct(pred)
            store_for_plot{k}.pred = pred.yc;
        end
    end
end
% residuals
k = k + 1;
str_disp{k} = 'residuals';
store_for_plot{k}.val = model.r;
store_for_plot{k}.lab = 'residuals';
store_for_plot{k}.pred = [];
if isstruct(pred)
    if isfield(pred,'r')
        store_for_plot{k}.pred = pred.r;
    end
end
if sum(isnan(model.H)) ~= length(model.H) 
    % only if are calculated, i.e. n > p*2
    % std residuals
    k = k + 1;
    str_disp{k} = 'std residuals';
    store_for_plot{k}.val = model.r_std;
    store_for_plot{k}.lab = 'std residuals';
    store_for_plot{k}.pred = [];
    if isstruct(pred)
        if isfield(pred,'r_std')
            store_for_plot{k}.pred = pred.r_std;
        end
    end
    if ~strcmp(model.type,'knn') && ~strcmp(model.type,'bnn')
        % leverages
        k = k + 1;
        str_disp{k} = 'leverages';
        store_for_plot{k}.val = model.H;
        store_for_plot{k}.lab = 'leverages';
        store_for_plot{k}.pred = [];
        if isstruct(pred)
            store_for_plot{k}.pred = pred.H;
        end
    end
end
if strcmp(model.type,'pls') || strcmp(model.type,'pcr')
    % components
    if strcmp(model.type,'pls')
        name_comp = 'LV';
    else
        name_comp = 'PC';
    end
    for p = 1:size(model.T,2)
        k = k + 1;
        str_disp{k} = ['scores on ' name_comp ' ' num2str(p)];
        store_for_plot{k}.val = model.T(:,p);
        lab = (['scores on ' name_comp ' ' num2str(p) ' - EV = ' num2str(round(model.expvar(p)*10000)/100) '%']);
        store_for_plot{k}.lab = lab;
        store_for_plot{k}.pred = [];
        if isstruct(pred)
            store_for_plot{k}.pred = pred.T(:,p);
        end
    end
    % Q residuals
    k = k + 1;
    str_disp{k} = 'Q residuals';
    store_for_plot{k}.val = model.Qres;
    store_for_plot{k}.lab = 'Q residuals';
    store_for_plot{k}.pred = [];
    if isstruct(pred)
        store_for_plot{k}.pred = pred.Qres;
    end
    % Hoteling
    k = k + 1;
    str_disp{k} = 'Hotelling T^2';
    store_for_plot{k}.val = model.Thot;
    store_for_plot{k}.lab = 'Hotelling T^2';
    store_for_plot{k}.pred = [];
    if isstruct(pred)
        store_for_plot{k}.pred = pred.Thot;
    end
end
set(handles.pop_xaxis,'String',str_disp);
set(handles.pop_xaxis,'Value',2);
set(handles.pop_yaxis,'String',str_disp);
set(handles.pop_yaxis,'Value',3);
handles.store_for_plot = store_for_plot;
