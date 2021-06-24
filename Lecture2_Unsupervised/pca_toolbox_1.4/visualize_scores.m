function varargout = visualize_scores(varargin)

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
set(handles.myuipanel,'Position',[3.5 10 30 28]);
set(handles.text_xaxis,'Position',[x_position 24.5+step_for_text 23 1]);
set(handles.pop_xaxis,'Position',[x_position 24.5 23 1.5]);
set(handles.text_yaxis,'Position',[x_position 21+step_for_text 23 1]);
set(handles.pop_yaxis,'Position',[x_position 21 23 1.5]);
set(handles.chk_labels,'Position',[x_position 18 23 1.5]);
set(handles.chk_legend,'Position',[x_position 16 23 1.5]);
set(handles.chk_hull,'Position',[x_position 14 23 1.5]);
set(handles.text_classpotential,'Position',[x_position 10.5+step_for_text 23 1]);
set(handles.pop_classpotential,'Position',[x_position 10.5 23 1.5]);
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
% set combo axis
handles = set_sample_combo(handles);
% set class potential combo
if length(handles.model.labels.class_labels) > 0
    class_labels = handles.model.labels.class_labels;
else
    for g=1:max(handles.model.settings.class); class_labels{g} = ['class ' num2str(g)]; end
end
str_disp{1} = 'none';
for g=1:max(handles.model.settings.class)
    str_disp{g+1} = class_labels{g};
end
if length(handles.model.settings.class) > 0
    str_disp{g+2} = ['all classes'];
end
set(handles.pop_classpotential,'String',str_disp);
set(handles.pop_classpotential,'Value',1);
handles = enable_disable(handles);
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

% --- Executes on selection change in pop_classpotential.
function pop_classpotential_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% --- Executes during object creation, after setting all properties.
function pop_classpotential_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_xaxis.
function pop_xaxis_Callback(hObject, eventdata, handles)
handles = enable_disable(handles);
update_plot(handles,0)

% --- Executes during object creation, after setting all properties.
function pop_xaxis_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_yaxis.
function pop_yaxis_Callback(hObject, eventdata, handles)
handles = enable_disable(handles);
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

% --- Executes on button press in chk_legend.
function chk_legend_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% --- Executes on button press in chk_hull.
function chk_hull_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% --- Executes on button press in chk_labels.
function chk_labels_Callback(hObject, eventdata, handles)
update_plot(handles,0)

% ---------------------------------------------------------
function handles = enable_disable(handles)
x = get(handles.pop_xaxis, 'Value');
y = get(handles.pop_yaxis, 'Value');
[Tx,Lab_Tx] = find_what_to_plot(handles,x);
[Ty,Lab_Ty] = find_what_to_plot(handles,y);
there_x = findstr(Lab_Tx,'samples');
there_y = findstr(Lab_Ty,'samples');
if length(handles.model.settings.class) == 0
    if length(handles.model.settings.response) == 0
        set(handles.chk_legend,'Enable','off');
    else
        set(handles.chk_legend,'Enable','on');
    end
    set(handles.chk_hull,'Value',0);
    set(handles.chk_hull,'Enable','off');
    set(handles.pop_classpotential,'Value',1);
    set(handles.pop_classpotential,'Enable','off');
else
    set(handles.chk_legend,'Enable','on');
    if length(there_x) > 0 || length(there_y) > 0
        set(handles.pop_classpotential,'Value',1);
        set(handles.pop_classpotential,'Enable','off');
        set(handles.chk_hull,'Value',0);
        set(handles.chk_hull,'Enable','off');
    else
        set(handles.pop_classpotential,'Enable','on');
        set(handles.chk_hull,'Enable','on');
    end
end

% ---------------------------------------------------------
function update_plot(handles,external)
[col_ass,col_default] = visualize_colors;
X = handles.model.settings.raw_data;
sample_labels  = handles.model.labels.sample_labels;
label_sample   = get(handles.chk_labels, 'Value');
show_legend    = get(handles.chk_legend, 'Value');
show_hull      = get(handles.chk_hull, 'Value');
show_potential = get(handles.pop_classpotential, 'Value');
x = get(handles.pop_xaxis, 'Value');
y = get(handles.pop_yaxis, 'Value');
[Tx,Lab_Tx,Tx_pred,x_class_number] = find_what_to_plot(handles,x);
[Ty,Lab_Ty,Ty_pred,y_class_number] = find_what_to_plot(handles,y);
class_for_plot = handles.model.settings.class;
response_for_plot = handles.model.settings.response;
if length(handles.model.labels.class_labels) > 0
    class_labels = handles.model.labels.class_labels;
else
    for g=1:max(class_for_plot); class_labels{g} = ['class ' num2str(g)]; end
end
% set figure
if external; figure; title('sample plot'); set(gcf,'color','white'); else; axes(handles.myplot); end
cla;
hold on
% display class potential
if show_potential > 1
    if show_potential <= max(class_for_plot)+1
        [P,xx,yy,step_potential,LineStyle,LineColor,LineWidth,map] = calculate_classpotential([Tx Ty],class_for_plot,show_potential - 1);
        contourf(xx, yy, P, step_potential,'LineStyle',LineStyle,'LineColor',LineColor,'LineWidth',LineWidth)
        colormap(map)
    else
        for g=1:max(class_for_plot)
            [P{g},xx{g},yy{g},~,~,~,LineWidth] = calculate_classpotential([Tx Ty],class_for_plot,g);
            step_potential(g) = max(max(P{g}));
        end
        step_potential_here = max(step_potential);
        range_potential = [0:step_potential_here/10:step_potential_here];
        if min(step_potential) < step_potential_here/10
            range_potential = [range_potential(1) min(step_potential)/1.5 range_potential(2:end)];
        end
        for g=1:max(class_for_plot)
            contour(xx{g}, yy{g}, P{g}, range_potential,'LineStyle','-','LineColor',col_ass(g+1,:),'LineWidth',LineWidth)
            legend_label{g} = class_labels{g};
        end
    end
    set(gca,'layer','top') % to have box on
end
% display samples
num_classes = max(class_for_plot);
if length(class_for_plot) == 0
    num_classes = 0;
end
if show_potential <= num_classes + 1
    if length(class_for_plot) > 0
        for g=1:max(class_for_plot)
            color_in = col_ass(g+1,:);
            plegend(g) = plot(Tx(find(class_for_plot==g)),Ty(find(class_for_plot==g)),'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',color_in);
            legend_label{g} = class_labels{g};
        end
    elseif length(response_for_plot) > 0
        [My,wheremax] = max(response_for_plot);
        [my,wheremin] = min(response_for_plot);
        % add max and min for legend
        color_here = 1 - (response_for_plot(wheremax) - my)/(My - my);
        color_in = [color_here color_here color_here];
        plot(Tx(wheremax),Ty(wheremax),'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',color_in)
        legend_label{1} = ['max response'];
        color_here = 1 - (response_for_plot(wheremin) - my)/(My - my);
        color_in = [color_here color_here color_here];
        plot(Tx(wheremin),Ty(wheremin),'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',color_in)
        legend_label{2} = ['min response'];
        for g=1:length(response_for_plot)
            color_here = 1 - (response_for_plot(g) - my)/(My - my);
            color_in = [color_here color_here color_here];
            plot(Tx(g),Ty(g),'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor',color_in)
        end
    else
        plot(Tx,Ty,'o','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor','w')
    end
end
% display convex hull
for g=1:max(class_for_plot)
    color_in = col_ass(g+1,:);
    if show_hull
        xhull = Tx(find(class_for_plot==g));
        yhull = Ty(find(class_for_plot==g));
        k = convhull(xhull,yhull);
        plot(xhull(k),yhull(k),'Color',color_in)
    end
end
% plot predicted samples
if length(Tx_pred) > 0 & length(Ty_pred) > 0
    if length(handles.pred.class) > 0
        class_test_for_plot = handles.pred.class;
        for g=1:max(class_test_for_plot)
            color_in = col_ass(g+1,:);
            plot(Tx_pred(find(class_test_for_plot==g)),Ty_pred(find(class_test_for_plot==g)),'*','MarkerEdgeColor',color_in,'MarkerSize',5,'MarkerFaceColor',color_in)
            legend_label{g} = class_labels{g};
        end
    else
        plot(Tx_pred,Ty_pred,'*','MarkerEdgeColor','k','MarkerSize',5,'MarkerFaceColor','k')
    end
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
qhere_x = findstr(Lab_Tx,'Q residuals');
there_x = findstr(Lab_Tx,'Hotelling T^2');
qhere_y = findstr(Lab_Ty,'Q residuals');
there_y = findstr(Lab_Ty,'Hotelling T^2');
if strcmp(Lab_Tx,'samples')
    range_x = size(X,1) + length(Tx_pred) - 1; add_space_x = range_x/20;      
    x_lim = [1-add_space_x (size(X,1) + length(Tx_pred))+add_space_x];       
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
elseif strcmp(Lab_Ty,'Q residuals')
    qlim = handles.model.settings.qlim;
    if ~isnan(qlim); this = find_max_axis(y_lim(2),qlim); y_lim = [y_lim(1) this]; end
elseif strcmp(Lab_Ty,'Hotelling T^2')
    tlim = handles.model.settings.tlim;
    if ~isnan(tlim); this = find_max_axis(y_lim(2),tlim); y_lim = [y_lim(1) this]; end    
end
% draw lines
if length(strfind(Lab_Tx,'scores')) > 0
    line([0 0],y_lim,'Color','k','LineStyle',':')
elseif strcmp(Lab_Tx,'Q residuals')
    qlim = handles.model.settings.qlim;
    if ~isnan(qlim); line([qlim qlim],y_lim,'Color','r','LineStyle',':'); end
elseif strcmp(Lab_Tx,'Hotelling T^2')
    tlim = handles.model.settings.tlim;
    if ~isnan(tlim); line([tlim tlim],y_lim,'Color','r','LineStyle',':'); end
end
if length(strfind(Lab_Ty,'scores')) > 0
    line(x_lim,[0 0],'Color','k','LineStyle',':')
elseif strcmp(Lab_Ty,'Q residuals')
    qlim = handles.model.settings.qlim;
    if ~isnan(qlim); line(x_lim,[qlim qlim],'Color','r','LineStyle',':'); end
elseif strcmp(Lab_Ty,'Hotelling T^2')
    tlim = handles.model.settings.tlim;
    if ~isnan(tlim); line(x_lim,[tlim tlim],'Color','r','LineStyle',':'); end
end
% set axis limits and labels
axis([x_lim(1) x_lim(2) y_lim(1) y_lim(2)])
xlabel(Lab_Tx)
ylabel(Lab_Ty)
if show_legend == 1
    if show_potential <= max(class_for_plot)+1
        legend(plegend,legend_label);
    else
        legend(legend_label);
    end
else
    legend off
end
box on; 
hold off

% -------------------------------------------------------------------
function [P,xx,yy,step_potential,LineStyle,LineColor,LineWidth,map] = calculate_classpotential(X,class,which_class)
step_grid = 50;
step_potential = 10;
col_ass = visualize_colors;
smoot = 0.2*ones(1,max(class));
LineStyle = 'none';
LineWidth = 0.2;
LineColor = [0.9 0.9 0.9];

[x,y,Xgrid] = makegriddata(X,step_grid);
% gaussian kernel
Xclass = X(find(class == which_class),:);
[Xclass,param] = data_pretreatment(Xclass,'auto');
[Xgrid_scal] = test_pretreatment(Xgrid,param);
dh = pdist2(Xgrid_scal,Xclass);
k = exp(-dh./(size(X,2)*smoot(which_class)));
P(:,1) = sum(k')';
P = reshape(P, [length(x) length(y)]);
xx = reshape(Xgrid(:,1), [length(x) length(y)]);
yy = reshape(Xgrid(:,2), [length(x) length(y)]);
c = col_ass(which_class + 1,:);
d = 1;
for f=1:3
    step_color = (1-c(f))/step_potential;
    if c(f) == 1
        map(:,f) = ones(step_potential+1-d,1);
    else
        map(:,f) = 1-d*step_color:-step_color:c(f);
    end
end
map = [1 1 1; map];

%---------------------------------------------------
function [x,y,Xgrid] = makegriddata(X,step)
% make grid
rx = (max(X(:,1)) - min(X(:,1)));
ry = (max(X(:,2)) - min(X(:,2)));
xrange = [min(X(:,1))-rx/5 max(X(:,1))+rx/5];
yrange = [min(X(:,2))-ry/5 max(X(:,2))+ry/5];
x = xrange(1):(xrange(2)-xrange(1))/step:xrange(2);
y = yrange(1):(yrange(2)-yrange(1))/step:yrange(2);
[xx,yy] = meshgrid(x,y);
Xgrid = [xx(:),yy(:)];

% ---------------------------------------------------------
function plot_string_label(X,Y,col,lab,range_span)
add_span = range_span/100;
for j=1:length(X); text(X(j)+add_span,Y(j),lab{j},'Color',col); end;

% ---------------------------------------------------------
function [T,lab_T,T_pred,class_number] = find_what_to_plot(handles,x)
T = handles.store_for_plot{x}.val;
lab_T = handles.store_for_plot{x}.lab;
T_pred = handles.store_for_plot{x}.pred;
if isfield(handles.store_for_plot{x},'class_number')
    class_number = handles.store_for_plot{x}.class_number;
else
    class_number = NaN;
end

% ---------------------------------------------------------
function this = find_max_axis(x1,x2)
m = max([x1 x2]);
this = m + m/20;

% ---------------------------------------------------------
function select_sample(handles)
sample_labels = handles.model.labels.sample_labels;
if isstruct (handles.pred)
    if size(sample_labels,2)> size(sample_labels,1); sample_labels = sample_labels'; end
    if size(handles.pred.sample_labels,2)> size(handles.pred.sample_labels,1); handles.pred.sample_labels = handles.pred.sample_labels'; end
    sample_labels = [sample_labels;handles.pred.sample_labels];
end
variable_labels = handles.model.labels.variable_labels;
x = get(handles.pop_xaxis, 'Value');
y = get(handles.pop_yaxis, 'Value');
[Tx,Lab_Tx,Tx_pred,x_class_number] = find_what_to_plot(handles,x);
[Ty,Lab_Ty,Ty_pred,y_class_number] = find_what_to_plot(handles,y);
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
str = get(legend,'String');
str = str(1:end-2);
set(legend,'String',str);
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
if strcmp(handles.model.type,'mds')
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
else % pca
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
store_for_plot{k}.val = [1:size(model.T,1)]';
store_for_plot{k}.lab = 'samples';
store_for_plot{k}.pred = [];
if isstruct(pred)
    ntrain = size(model.T,1);
    store_for_plot{k}.pred = [ntrain + 1:ntrain + size(pred.X,1)]';
end
if strcmp(model.type,'pca')
    % components
    for p = 1:size(model.T,2)
        k = k + 1;
        str_disp{k} = ['scores on PC ' num2str(p)];
        store_for_plot{k}.val = model.T(:,p);
        lab = (['scores on PC ' num2str(p) ' - EV = ' num2str(round(model.exp_var(p)*10000)/100) '%']);
        store_for_plot{k}.lab = lab;
        store_for_plot{k}.pred = [];
        if isstruct(pred)
            store_for_plot{k}.pred = pred.T(:,p);
        end
    end
    % Q residuals
    k = k + 1;
    str_disp{k} = 'Q residuals';
    store_for_plot{k}.val = model.Qres';
    store_for_plot{k}.lab = 'Q residuals';
    store_for_plot{k}.pred = [];
    if isstruct(pred)
        store_for_plot{k}.pred = pred.Qres';
    end
    % Hoteling
    k = k + 1;
    str_disp{k} = 'Hotelling T^2';
    store_for_plot{k}.val = model.Thot';
    store_for_plot{k}.lab = 'Hotelling T^2';
    store_for_plot{k}.pred = [];
    if isstruct(pred)
        store_for_plot{k}.pred = pred.Thot';
    end
end
if strcmp(model.type,'mds')
    % coordinates
    for p = 1:size(model.T,2)
        k = k + 1;
        str_disp{k} = ['scores on dim. ' num2str(p)];
        store_for_plot{k}.val = model.T(:,p);
        lab = (['scores on dimension ' num2str(p) ' - eigen = ' num2str(round(model.E(p)*100)/100)]);
        store_for_plot{k}.lab = lab;
        store_for_plot{k}.pred = [];
        if isstruct(pred)
            store_for_plot{k}.pred = pred.T(:,p);
        end
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
