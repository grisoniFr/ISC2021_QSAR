function varargout = reg_gui(varargin)

% reg_gui is the main routine to open the graphical interface of the Regression Toolbox.
% In order to open the graphical interface, just type on the matlab command line:
%
% reg_gui
%
% there are no inputs, data can be loaded and saved directly from the graphical interface
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
                   'gui_OpeningFcn', @reg_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @reg_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before reg_gui is made visible.
function reg_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
set(handles.output,'Position',[100 50 84 14]);
set(handles.listbox_model,'Position',[44 1 37 12]);
set(handles.listbox_data,'Position',[3 1 37 12]);
movegui(handles.reg_gui,'center');
% initialize handles
handles = init_handles(handles);
% enable/disable buttons and menu
handles = enable_disable(handles);
% updtae list boxes
update_listbox_data(handles)
update_listbox_model(handles)
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = reg_gui_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% --------------------------------------------------------------------
function m_file_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_file_load_data_Callback(hObject, eventdata, handles)
% ask for overwriting
if handles.present.data == 1
    q = questdlg('Data are alreday loaded. Do you wish to overwrite them?','loading data','yes','no','yes');
else
    q = 'yes';
end
if strcmp(q,'yes')
    res = visualize_load(1,0);
    if isnan(res.loaded_file)
        if handles.present.data  == 0
            handles.present.data  = 0;
            handles = reset_labels(handles);
        else
            handles.present.data  = 1;
        end
    elseif res.from_file == 1
        handles = reset_data(handles);
        handles.present.data  = 1;
        handles = reset_labels(handles);
        handles = reset_response(handles);
        if handles.present.model == 2; handles.present.model = 1; end % model becames loaded instead of calculated
        tmp_data = load(res.path);
        handles.data.X = getfield(tmp_data,res.name);
        handles.data.name_data = res.name;
        % make standard labels, do not set handles.present as 1
        for k=1:size(handles.data.X,1); handles.data.sample_labels{k} = ['S' num2str(k)]; end
        for k=1:size(handles.data.X,2); handles.data.variable_labels{k} = ['V' num2str(k)]; end
    else
        handles = reset_data(handles);
        handles.present.data  = 1;
        handles = reset_labels(handles);
        handles = reset_response(handles); 
        if handles.present.model == 2; handles.present.model = 1; end % model becames loaded instead of calculated
        handles.data.X = evalin('base',res.name);
        handles.data.name_data = res.name;
        % make standard labels, do not set handles.present as 1
        for k=1:size(handles.data.X,1); handles.data.sample_labels{k} = ['S' num2str(k)]; end
        for k=1:size(handles.data.X,2); handles.data.variable_labels{k} = ['V' num2str(k)]; end
    end
    handles = enable_disable(handles);
    update_listbox_data(handles);
    update_listbox_model(handles);
    guidata(hObject,handles)
end

% --------------------------------------------------------------------
function m_file_load_response_Callback(hObject, eventdata, handles)
% ask for overwriting
if handles.present.response == 1
    q = questdlg('Response is alreday loaded. Do you wish to overwrite it?','loading response','yes','no','yes');
else
    q = 'yes';
end
if strcmp(q,'yes') 
    res = visualize_load(6,size(handles.data.X,1));
    if isnan(res.loaded_file)
        if handles.present.response  == 0
            handles.present.response  = 0;
        else
            handles.present.response  = 1;
        end
    elseif res.from_file == 1
        handles.present.response  = 1;
        tmp_data = load(res.path);
        handles.data.response = getfield(tmp_data,res.name);
        if size(handles.data.response,2) > size(handles.data.response,1)
            handles.data.response = handles.data.response';
        end
        handles.data.name_response = res.name;
    else
        handles.present.response  = 1;
        handles.data.response = evalin('base',res.name);
        if size(handles.data.response,2) > size(handles.data.response,1)
            handles.data.response = handles.data.response';
        end
        handles.data.name_response = res.name;
    end
    handles = enable_disable(handles);
    update_listbox_data(handles)
    guidata(hObject,handles)
end

% --------------------------------------------------------------------
function m_file_load_model_Callback(hObject, eventdata, handles)
% ask for overwriting
if handles.present.model > 0
    q = questdlg('Model is alreday loaded/calculated. Do you wish to overwrite it?','loading model','yes','no','yes');
else
    q = 'yes';
end
if strcmp(q,'yes')
    res = visualize_load(3,0);
    if isnan(res.loaded_file)
        if handles.present.model  == 0
            handles.present.model  = 0;
        else
            handles.present.model  = 1;
        end
    else
        if res.from_file == 1
            handles.present.model  = 1;
            tmp_data = load(res.path);
            handles.data.model = getfield(tmp_data,res.name);
            handles.data.name_model = res.name;
            handles = reset_pred(handles);
        else
            handles.present.model  = 1;
            handles.data.model = evalin('base',res.name);
            handles.data.name_model = res.name;
            handles = reset_pred(handles);
        end
    end
    handles = enable_disable(handles);
    update_listbox_data(handles);
    update_listbox_model(handles);
    guidata(hObject,handles)
end

% --------------------------------------------------------------------
function m_file_load_labels_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_file_load_sample_labels_Callback(hObject, eventdata, handles)
res = visualize_load(4,size(handles.data.X,1));
if isnan(res.loaded_file)
    if handles.present.sample_labels == 0
        handles.present.sample_labels  = 0;
    else
        handles.present.sample_labels  = 1;
    end
elseif res.from_file == 1
    handles.present.sample_labels  = 1;
    tmp_data = load(res.path);
    handles.data.sample_labels = getfield(tmp_data,res.name);
    if size(handles.data.sample_labels,2) > size(handles.data.sample_labels,1)
        handles.data.sample_labels = handles.data.sample_labels';
    end
else
    handles.present.sample_labels  = 1;
    handles.data.sample_labels = evalin('base',res.name);
    if size(handles.data.sample_labels,2) > size(handles.data.sample_labels,1)
        handles.data.sample_labels = handles.data.sample_labels';
    end
end
handles = enable_disable(handles);
update_listbox_data(handles)
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_file_load_variable_labels_Callback(hObject, eventdata, handles)
res = visualize_load(5,size(handles.data.X,2));
if isnan(res.loaded_file)
    if handles.present.variable_labels == 0
        handles.present.variable_labels  = 0;
    else
        handles.present.variable_labels  = 1;
    end
elseif res.from_file == 1
    handles.present.variable_labels  = 1;
    tmp_data = load(res.path);
    handles.data.variable_labels = getfield(tmp_data,res.name);
    if size(handles.data.variable_labels,2) < size(handles.data.variable_labels,1)
        handles.data.variable_labels = handles.data.variable_labels';
    end
else
    handles.present.variable_labels  = 1;
    handles.data.variable_labels = evalin('base',res.name);
    if size(handles.data.variable_labels,2) < size(handles.data.variable_labels,1)
        handles.data.variable_labels = handles.data.variable_labels';
    end
end
handles = enable_disable(handles);
update_listbox_data(handles)
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_file_save_model_Callback(hObject, eventdata, handles)
visualize_export(handles.data.model,'model')

% --------------------------------------------------------------------
function m_file_save_pred_Callback(hObject, eventdata, handles)
visualize_export(handles.data.pred,'pred')

% --------------------------------------------------------------------
function m_file_save_varselection_Callback(hObject, eventdata, handles)
visualize_export(handles.data.model.settings.selection_res,'ga')

% --------------------------------------------------------------------
function m_file_clear_data_Callback(hObject, eventdata, handles)
handles = reset_data(handles);
handles = reset_response(handles);
handles = reset_labels(handles);
handles = enable_disable(handles);
update_listbox_data(handles)
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_file_clear_model_Callback(hObject, eventdata, handles)
handles = reset_model(handles);
handles = enable_disable(handles);
update_listbox_model(handles)
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_file_exit_Callback(hObject, eventdata, handles)
close

% --------------------------------------------------------------------
function m_view_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_view_data_Callback(hObject, eventdata, handles)
assignin('base','tmp_data_matrix',handles.data.X);
openvar('tmp_data_matrix');

% --------------------------------------------------------------------
function m_view_correlation_Callback(hObject, eventdata, handles)
assignin('base','tmp_correlation_matrix',corrcoef(handles.data.X));
openvar('tmp_correlation_matrix');

% --------------------------------------------------------------------
function m_view_response_Callback(hObject, eventdata, handles)
assignin('base','tmp_response',handles.data.response);
openvar('tmp_response');

% --------------------------------------------------------------------
function m_view_plot_univariate_Callback(hObject, eventdata, handles)
visualize_univariate(handles.data)

% --------------------------------------------------------------------
function m_view_plot_profiles_Callback(hObject, eventdata, handles)
visualize_profiles_samples(handles.data);

% --------------------------------------------------------------------
function m_view_delete_Callback(hObject, eventdata, handles)
out = visualize_delete_samples(size(handles.data.X,1),handles.data.response,handles.data.sample_labels);
if ~isnan(out)
    if size(handles.data.X,1) > 1
        in = ones(size(handles.data.X,1),1);
        in(out) = 0;
        samples_in = find(in);
        variables_in = [1:size(handles.data.X,2)];
        handles = reduce_data(handles,samples_in,variables_in);
        guidata(hObject,handles)
    else
        h1 = ['There is just one sample in the dataset. It is not possible to delete it!'];
        warndlg([h1],'Delete samples')
    end
end

% --------------------------------------------------------------------
function m_calculate_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_calculate_ols_Callback(hObject, eventdata, handles)
handles = do_ols(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_pls_Callback(hObject, eventdata, handles)
handles = do_pls(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_pcr_Callback(hObject, eventdata, handles)
handles = do_pcr(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_ridge_Callback(hObject, eventdata, handles)
handles = do_ridge(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_knn_Callback(hObject, eventdata, handles)
handles = do_knn(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_vs_Callback(hObject, eventdata, handles)
handles = do_vs(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_results_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_ols_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_ols_performance_Callback(hObject, eventdata, handles)
open_regression_performance(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_ols_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_ols_loadings_Callback(hObject, eventdata, handles)
visualize_loadings(handles.data.model)

% --------------------------------------------------------------------
function m_results_pls_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_pls_performance_Callback(hObject, eventdata, handles)
open_regression_performance(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_pls_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_pls_loadings_Callback(hObject, eventdata, handles)
visualize_loadings(handles.data.model)

% --------------------------------------------------------------------
function m_results_eigen_pls_Callback(hObject, eventdata, handles)
disp_eigen(handles)

% --------------------------------------------------------------------
function m_results_pcr_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_pcr_performance_Callback(hObject, eventdata, handles)
open_regression_performance(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_pcr_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_pcr_loadings_Callback(hObject, eventdata, handles)
visualize_loadings(handles.data.model)

% --------------------------------------------------------------------
function m_results_eigen_pcr_Callback(hObject, eventdata, handles)
disp_eigen(handles)

% --------------------------------------------------------------------
function m_results_ridge_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_ridge_performance_Callback(hObject, eventdata, handles)
open_regression_performance(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_ridge_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_ridge_loadings_Callback(hObject, eventdata, handles)
visualize_loadings(handles.data.model)

% --------------------------------------------------------------------
function m_results_knn_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_knn_performance_Callback(hObject, eventdata, handles)
open_regression_performance(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_knn_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_varselection_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_varselection_plots_Callback(hObject, eventdata, handles)
disp_varselection(handles)

% --------------------------------------------------------------------
function m_results_varselection_varlist_Callback(hObject, eventdata, handles)
variable_list = handles.data.model.labels.variable_labels;
visualize_variable_list(variable_list)

% --------------------------------------------------------------------
function m_predict_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_predict_samples_Callback(hObject, eventdata, handles)
handles = predict_samples(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_predict_samples_view_Callback(hObject, eventdata, handles)
if strcmp(handles.data.model.type,'pcaqda')
    visualize_scores(handles.data.model,handles.data.pred,'pca')
else
    visualize_scores(handles.data.model,handles.data.pred)
end

% --------------------------------------------------------------------
function m_predict_response_Callback(hObject, eventdata, handles)
assignin('base','tmp_response_predicted',handles.data.pred.yc);
openvar('tmp_response_predicted');

% --------------------------------------------------------------------
function m_help_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_help_html_Callback(hObject, eventdata, handles)
h1 = ['A complete HTML guide is provided.'];
hr = sprintf('\n');
h3 = ['Look for the help.htm file in the toolbox folder' sprintf('\n') 'and open it in your favourite browser!'];
web('help.htm','-browser')
helpdlg([h1 hr h3],'HTML help')

% --------------------------------------------------------------------
function m_how_to_cite_Callback(hObject, eventdata, handles)
h1 = ['The toolbox is freeware and may be used (but not modified) if proper reference is given to the authors. Preferably refer to the following paper:'];
hr = sprintf('\n');
h3 = ['D. Ballabio, G. Baccolo, V. Consonni. A MATLAB toolbox for multivariate regression. Submitted to Chemometrics and Intelligent Laboratory Systems'];
helpdlg([h1 hr hr h3 hr hr],'How to cite')

% --------------------------------------------------------------------
function m_about_Callback(hObject, eventdata, handles)
h1 = 'regression toolbox for MATLAB version 1.0';
hr = sprintf('\n');
h2 = 'Milano Chemometrics and QSAR Research Group ';
h3 = 'University of Milano-Bicocca, Italy';
h4 = 'http://www.michem.unimib.it/';
helpdlg([h1 hr h2 hr h3 hr h4],'About')

% --- Executes during object creation, after setting all properties.
function listbox_data_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in listbox_data.
function listbox_data_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function listbox_model_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in listbox_model.
function listbox_model_Callback(hObject, eventdata, handles)

% ------------------------------------------------------------------------
function handles = do_ols(handles)
% open do settings
[cv_groups,cv_type,domodel] = visualize_settings_small('ols',size(handles.data.X,1),size(handles.data.X,2),NaN,NaN);
if domodel > 0
    % activate pointer
    set(handles.reg_gui,'Pointer','watch')
    % run model
    model = olsfit(handles.data.X,handles.data.response);
    if strcmp('none',cv_type)
        cv = [];
    else
        cv = olscv(handles.data.X,handles.data.response,cv_type,cv_groups);
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.reg_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.reg_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_pls(handles)
% open do settings
maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
if maxcomp > 10; maxcomp = 10; end
[cv_groups,cv_type,num_comp,scaling,~,~,~,~,domodel] = visualize_settings_big('pls',size(handles.data.X,1),handles.present.model,handles.data.model,maxcomp,handles.data.X,handles.data.response);
if domodel
    % activate pointer
    set(handles.reg_gui,'Pointer','watch')
    % run model
    model = plsfit(handles.data.X,handles.data.response,num_comp,scaling);
    if strcmp('none',cv_type)
        cv = [];
    else
        cv = plscv(handles.data.X,handles.data.response,num_comp,scaling,cv_type,cv_groups);
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.reg_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.reg_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_pcr(handles)
% open do settings
maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
if maxcomp > 10; maxcomp = 10; end
[cv_groups,cv_type,num_comp,scaling,~,~,~,~,domodel] = visualize_settings_big('pcr',size(handles.data.X,1),handles.present.model,handles.data.model,maxcomp,handles.data.X,handles.data.response);
if domodel
    % activate pointer
    set(handles.reg_gui,'Pointer','watch')
    % run model
    model = pcrfit(handles.data.X,handles.data.response,num_comp,scaling);
    if strcmp('none',cv_type)
        cv = [];
    else
        cv = pcrcv(handles.data.X,handles.data.response,num_comp,scaling,cv_type,cv_groups);
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.reg_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.reg_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_ridge(handles)
% open do settings
[cv_groups,cv_type,K,~,~,~,~,~,domodel] = visualize_settings_big('ridge',size(handles.data.X,1),handles.present.model,handles.data.model,1,handles.data.X,handles.data.response);
if domodel
    % activate pointer
    set(handles.reg_gui,'Pointer','watch')
    % run model
    model = ridgefit(handles.data.X,handles.data.response,K);
    if strcmp('none',cv_type)
        cv = [];
    else
        cv = ridgecv(handles.data.X,handles.data.response,K,cv_type,cv_groups);
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.reg_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.reg_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_knn(handles)
% open do settings
[cv_groups,cv_type,param_here,scaling,dist_type,type_local_regression,~,~,domodel] = visualize_settings_big('lr',size(handles.data.X,1),handles.present.model,handles.data.model,10,handles.data.X,handles.data.response);
if domodel
    % activate pointer
    set(handles.reg_gui,'Pointer','watch')
    if strcmp(type_local_regression,'knn')
        model = knnfit(handles.data.X,handles.data.response,param_here,dist_type,scaling);
    else
        model = bnnfit(handles.data.X,handles.data.response,param_here,dist_type,scaling);
    end
    if strcmp('none',cv_type)
        cv = [];
    else
        if strcmp(type_local_regression,'knn')
            cv = knncv(handles.data.X,handles.data.response,param_here,dist_type,scaling,cv_type,cv_groups);
        else
            cv = bnncv(handles.data.X,handles.data.response,param_here,dist_type,scaling,cv_type,cv_groups);
        end
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        handles.data.model.labels.variable_labels = handles.data.variable_labels;
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.reg_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.reg_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_vs(handles)
% open do settings
[selectiontype,param_01,param_02,param_03,param_04,modelling_method,scaling,dist_type,cv_type,cv_groups,domodel] = visualize_settings_ga(size(handles.data.X,2),size(handles.data.X,1));

if domodel == 1 % variable selection
    % open settings
    if strcmp(selectiontype,'ga')
        set(handles.reg_gui,'Pointer','watch')
        gaopt = ga_options(modelling_method,scaling); % pret type none for ols
        gaopt.cv_groups = cv_groups;
        gaopt.cv_type   = cv_type;
        gaopt.maxvar    = param_02;
        gaopt.runs      = param_01;
        gaopt.perc_validation = 0/100;
        if ischar(param_04) || isnan(param_04); param_04 = 1; end
        gaopt.num_windows = param_04;
        gaopt.dist_type = dist_type; % only for knn and bnn
        gaopt.do_plot = 3;
        [domodel,selection_res] = do_ga(handles.data.X,handles.data.response,gaopt,handles.data.variable_labels);
        set(handles.reg_gui,'Pointer','arrow')
    elseif strcmp(selectiontype,'rsr')
        set(handles.reg_gui,'Pointer','watch')
        rsropt = rsr_options(modelling_method,scaling,param_01,param_02,param_03);
        rsropt.cv_groups = cv_groups;
        rsropt.cv_type   = cv_type;
        rsropt.dist_type = dist_type; % only for knn and bnn
        rsropt.do_plot = 2;
        rsropt.num_windows = 1; % no windows
        if strcmp(param_04,'inactive'); rsropt.tabu = 0; end
        [domodel,selection_res] = do_rsr(handles.data.X,handles.data.response,rsropt,handles.data.variable_labels);
        set(handles.reg_gui,'Pointer','arrow')
    elseif strcmp(selectiontype,'forward')
        set(handles.reg_gui,'Pointer','watch')
        forwardopt = forward_options(modelling_method,scaling,param_01);
        forwardopt.cv_groups = cv_groups;
        forwardopt.cv_type   = cv_type;
        forwardopt.dist_type = dist_type; % only for knn and bnn
        forwardopt.do_plot = 2;
        if ischar(param_04) || isnan(param_04); param_04 = 1; end
        forwardopt.num_windows = param_04;
        [domodel,selection_res] = do_forward(handles.data.X,handles.data.response,forwardopt,handles.data.variable_labels);
        set(handles.reg_gui,'Pointer','arrow')
    elseif strcmp(selectiontype,'allsubset')
        set(handles.reg_gui,'Pointer','watch')
        asopt.method = modelling_method;
        asopt.maxvar = param_01;
        asopt.pret_type = scaling;
        asopt.cv_groups = cv_groups;
        asopt.cv_type   = cv_type;
        asopt.dist_type = dist_type; % only for knn and bnn
        asopt.num_windows = 1;
        asopt.do_plot = 1;
        [domodel,selection_res] = do_allsubset(handles.data.X,handles.data.response,asopt,handles.data.variable_labels);
        set(handles.reg_gui,'Pointer','arrow')
    end
else
    selection_res = NaN;
end
if domodel
    % activate pointer
    set(handles.reg_gui,'Pointer','watch')
    % run model
    if strcmp(modelling_method,'pls')
        model = plsfit(handles.data.X(:,selection_res.var_selected),handles.data.response,selection_res.opt_param,scaling);
        cv = plscv(handles.data.X(:,selection_res.var_selected),handles.data.response,selection_res.opt_param,scaling,cv_type,cv_groups);
    elseif strcmp(modelling_method,'ols')
        model = olsfit(handles.data.X(:,selection_res.var_selected),handles.data.response);
        cv = olscv(handles.data.X(:,selection_res.var_selected),handles.data.response,cv_type,cv_groups);
    elseif strcmp(modelling_method,'pcr')
        model = pcrfit(handles.data.X(:,selection_res.var_selected),handles.data.response,selection_res.opt_param,scaling);
        cv = pcrcv(handles.data.X(:,selection_res.var_selected),handles.data.response,selection_res.opt_param,scaling,cv_type,cv_groups);
    elseif strcmp(modelling_method,'ridge')
        model = ridgefit(handles.data.X(:,selection_res.var_selected),handles.data.response,selection_res.opt_param);
        cv = ridgecv(handles.data.X(:,selection_res.var_selected),handles.data.response,selection_res.opt_param,cv_type,cv_groups);
    elseif strcmp(modelling_method,'knn')
        model = knnfit(handles.data.X(:,selection_res.var_selected),handles.data.response,selection_res.opt_param,dist_type,scaling);
        cv = knncv(handles.data.X(:,selection_res.var_selected),handles.data.response,selection_res.opt_param,dist_type,scaling,cv_type,cv_groups);    
    elseif strcmp(modelling_method,'bnn')    
        model = bnnfit(handles.data.X(:,selection_res.var_selected),handles.data.response,selection_res.opt_param,dist_type,scaling);
        cv = bnncv(handles.data.X(:,selection_res.var_selected),handles.data.response,selection_res.opt_param,dist_type,scaling,cv_type,cv_groups);
    end
    % check if model and cv are calculated
    if isstruct(model)
        handles = reset_model(handles);
        handles.data.model = model;
        handles.data.model.cv = cv;
        handles.data.model.labels.sample_labels = handles.data.sample_labels;
        if isstruct(selection_res)
            handles.data.model.labels.variable_labels = handles.data.variable_labels(selection_res.var_selected);
            handles.data.model.settings.selection_res = selection_res;
        else
            handles.data.model.labels.variable_labels = handles.data.variable_labels;
        end
        handles.present.model = 2;
        handles.data.name_model = 'calculated';
    end
    % update model listbox
    set(handles.reg_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.reg_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function [domodel,ga_res] = do_ga(X,y,gaopt,var_labels)
ga_res = ga_selection(X,y,gaopt);
[var_selected,opt_param,domodel] = visualize_gafrequencies(ga_res,var_labels,X,y);
ga_res.var_selected = var_selected;
ga_res.opt_param = opt_param;
ga_res.selection_type = 'ga';

% ------------------------------------------------------------------------
function [domodel,rsr_res] = do_rsr(X,y,rsropt,var_labels)
rsr_res = rsr_selection(X,y,rsropt);
for k=1:length(rsr_res.var_list)
    var_in = rsr_res.var_list{k};
    [R2cv,best_param,ycv,rmsecv,R2,rmse] = ga_cv(X,y,var_in,rsropt,10);
    res_selection(k,1).r2cv = R2cv;
    res_selection(k,1).rmsecv = rmsecv;
    res_selection(k,1).r2 = R2;
    res_selection(k,1).rmse = rmse;
    res_selection(k,1).selected_variables = var_in;
    res_selection(k,1).selected_variables_labels = var_labels(var_in);
    res_selection(k,1).param = best_param;
    res_selection(k,1).selected_windows = NaN;
end
[var_selected,opt_param,domodel] = visualize_gaselection(res_selection,X,var_labels,rsropt);
rsr_res.var_selected = var_selected;
rsr_res.opt_param = opt_param;
rsr_res.selection_type = 'rsr';

% ------------------------------------------------------------------------
function [domodel,forward_res] = do_forward(X,y,forwardopt,var_labels)
forward_res = forward_selection(X,y,forwardopt);
for k = 1:length(forward_res.step_selection)
    var_in = forward_res.included_var(1:k);
    if forwardopt.num_windows > 1
        W = ga_windows([1:size(X,2)],forward_res.step_selection(k).selected_variables,forwardopt.num_windows);
        forward_res.step_selection(k,1).selected_variables = W;
        forward_res.step_selection(k,1).selected_variables_labels = var_labels(W);
    else
        forward_res.step_selection(k,1).selected_variables_labels = var_labels(var_in);
    end
    forward_res.step_selection(k,1).selected_windows = k;
end
[var_selected,opt_param,domodel] = visualize_gaselection(forward_res.step_selection,X,var_labels,forwardopt);
forward_res.var_selected = var_selected;
forward_res.opt_param = opt_param;
forward_res.selection_type = 'forward';

% ------------------------------------------------------------------------
function [domodel,allsubset_res] = do_allsubset(X,y,asopt,var_labels)
allsubset_res = allsubset_selection(X,y,asopt);
for k=1:length(allsubset_res.var_list)
    var_in = allsubset_res.var_list{k};
    [R2cv,best_param,ycv,rmsecv,R2,rmse] = ga_cv(X,y,var_in,asopt,10);
    res_selection(k,1).r2cv = R2cv;
    res_selection(k,1).rmsecv = rmsecv;
    res_selection(k,1).r2 = R2;
    res_selection(k,1).rmse = rmse;
    res_selection(k,1).selected_variables = var_in;
    res_selection(k,1).selected_variables_labels = var_labels(var_in);
    res_selection(k,1).param = best_param;
    res_selection(k,1).selected_windows = NaN;
end
[var_selected,opt_param,domodel] = visualize_gaselection(res_selection,X,var_labels,asopt);
allsubset_res.var_selected = var_selected;
allsubset_res.opt_param = opt_param;
allsubset_res.selection_type = 'allsubset';

% ------------------------------------------------------------------------
function update_listbox_data(handles)
if handles.present.data == 0
    set(handles.listbox_data,'String','data not loaded');
else
    str{1} = ['data: loaded'];
    str{2} = ['data matrix: ' handles.data.name_data];
    str{3} = ['samples: ' num2str(size(handles.data.X,1))];
    str{4} = ['variables: ' num2str(size(handles.data.X,2))];
    if handles.present.sample_labels
        str{5} = ['sample labels: loaded'];
    else
        str{5} = ['sample labels: not loaded'];
    end
    if handles.present.variable_labels
        str{6} = ['variable labels: loaded'];
    else
        str{6} = ['variable labels: not loaded'];
    end
    if handles.present.response == 1
        str{7} = ['response: loaded'];
        str{8} = ['response label: ' handles.data.name_response];
    end
    set(handles.listbox_data,'String',str);
end

% ------------------------------------------------------------------------
function update_listbox_model(handles)
nformat3 = '%1.3f';
nformat4 = '%1.4f';
if handles.present.model == 0
    set(handles.listbox_model,'String','model not loaded/calculated');
elseif strcmp(handles.data.model.type,'ols')
    R2 = sprintf(nformat3,handles.data.model.reg_param.R2);
    rmse = sprintf(nformat4,handles.data.model.reg_param.rmse);
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    cnt = 3;
    if isfield(handles.data.model.settings,'selection_res')
        str{cnt} = ['selected variables: ' num2str(length(handles.data.model.settings.selection_res.var_selected))]; cnt = cnt + 1;
    end
    str{cnt} = ['R2: ' R2]; cnt = cnt + 1;
    str{cnt} = ['RMSE: ' rmse]; cnt = cnt + 1;
    if isstruct(handles.data.model.cv)
        R2 = sprintf(nformat3,handles.data.model.cv.reg_param.R2);
        rmse = sprintf(nformat4,handles.data.model.cv.reg_param.rmse);
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['R2 ' cvtype ': ' R2]; cnt = cnt + 1;
        str{cnt} = ['RMSE ' cvtype ': ' rmse]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'reg_param')
            R2 = sprintf(nformat3,handles.data.pred.reg_param.R2);
            rmse = sprintf(nformat4,handles.data.pred.reg_param.rmsep);
            str{cnt} = ['Q2 test: ' R2]; cnt = cnt + 1;
            str{cnt} = ['RMSEP: ' rmse]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
elseif strcmp(handles.data.model.type,'pls') || strcmp(handles.data.model.type,'pcr')
    R2 = sprintf(nformat3,handles.data.model.reg_param.R2);
    rmse = sprintf(nformat4,handles.data.model.reg_param.rmse);
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    nc = size(handles.data.model.T,2);
    ev = round(handles.data.model.cumvar(end,1)*100);
    scal = handles.data.model.settings.pret_type;
    if strcmp(scal,'none')
        set_this = 'none';
    elseif strcmp(scal,'cent')
        set_this = 'mean centering';
    else
        set_this = 'autoscaling';
    end
    str{3} = ['data scaling: ' set_this];
    str{4} = ['components in the model: ' num2str(nc)];
    str{5} = ['explained var. in X: ' num2str(ev) ' %'];
    cnt = 6;
    if isfield(handles.data.model.settings,'selection_res')
        str{cnt} = ['selected variables: ' num2str(length(handles.data.model.settings.selection_res.var_selected))]; cnt = cnt + 1;
    end
    str{cnt} = ['R2: ' R2]; cnt = cnt + 1;
    str{cnt} = ['RMSE: ' rmse]; cnt = cnt + 1;
    if isstruct(handles.data.model.cv)
        R2 = sprintf(nformat3,handles.data.model.cv.reg_param.R2);
        rmse = sprintf(nformat4,handles.data.model.cv.reg_param.rmse);
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['R2 ' cvtype ': ' R2]; cnt = cnt + 1;
        str{cnt} = ['RMSE ' cvtype ': ' rmse]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'reg_param')
            R2 = sprintf(nformat3,handles.data.pred.reg_param.R2);
            rmse = sprintf(nformat4,handles.data.pred.reg_param.rmsep);
            str{cnt} = ['Q2 test: ' R2]; cnt = cnt + 1;
            str{cnt} = ['RMSEP: ' rmse]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
elseif strcmp(handles.data.model.type,'ridge')
    R2 = sprintf(nformat3,handles.data.model.reg_param.R2);
    rmse = sprintf(nformat4,handles.data.model.reg_param.rmse);
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    nc = handles.data.model.settings.K;
    str{3} = ['Ridge parameter K: ' num2str(nc)];
    cnt = 4;
    if isfield(handles.data.model.settings,'selection_res')
        str{cnt} = ['selected variables: ' num2str(length(handles.data.model.settings.selection_res.var_selected))]; cnt = cnt + 1;
    end
    str{cnt} = ['R2: ' R2]; cnt = cnt + 1;
    str{cnt} = ['RMSE: ' rmse]; cnt = cnt + 1;
    if isstruct(handles.data.model.cv)
        R2 = sprintf(nformat3,handles.data.model.cv.reg_param.R2);
        rmse = sprintf(nformat4,handles.data.model.cv.reg_param.rmse);
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['R2 ' cvtype ': ' R2]; cnt = cnt + 1;
        str{cnt} = ['RMSE ' cvtype ': ' rmse]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'reg_param')
            R2 = sprintf(nformat3,handles.data.pred.reg_param.R2);
            rmse = sprintf(nformat4,handles.data.pred.reg_param.rmsep);
            str{cnt} = ['Q2 test: ' R2]; cnt = cnt + 1;
            str{cnt} = ['RMSEP: ' rmse]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
elseif strcmp(handles.data.model.type,'knn') || strcmp(handles.data.model.type,'bnn')
    R2 = sprintf(nformat3,handles.data.model.reg_param.R2);
    rmse = sprintf(nformat4,handles.data.model.reg_param.rmse);
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    scal = handles.data.model.settings.param.pret_type;
    if strcmp(scal,'none')
        set_this = 'none';
    elseif strcmp(scal,'cent')
        set_this = 'mean centering';
    else
        set_this = 'autoscaling';
    end
    str{3} = ['data scaling: ' set_this];
    if strcmp(handles.data.model.type,'knn')
        param_here = handles.data.model.settings.K;
        str{4} = ['K value: ' num2str(param_here)];
    else
        param_here = handles.data.model.settings.alpha;
        str{4} = ['alpha: ' num2str(param_here)];
    end   
    str{5} = ['distance: ' handles.data.model.settings.dist_type];
    cnt = 6;
    if isfield(handles.data.model.settings,'selection_res')
        str{cnt} = ['selected variables: ' num2str(length(handles.data.model.settings.selection_res.var_selected))]; cnt = cnt + 1;
    end
    str{cnt} = ['R2: ' R2]; cnt = cnt + 1;
    str{cnt} = ['RMSE: ' rmse]; cnt = cnt + 1;
    if isstruct(handles.data.model.cv)
        R2 = sprintf(nformat3,handles.data.model.cv.reg_param.R2);
        rmse = sprintf(nformat4,handles.data.model.cv.reg_param.rmse);
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['R2 ' cvtype ': ' R2]; cnt = cnt + 1;
        str{cnt} = ['RMSE ' cvtype ': ' rmse]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'reg_param')
            R2 = sprintf(nformat3,handles.data.pred.reg_param.R2);
            rmse = sprintf(nformat4,handles.data.pred.reg_param.rmsep);
            str{cnt} = ['Q2 test: ' R2]; cnt = cnt + 1;
            str{cnt} = ['RMSEP: ' rmse]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
end

% ------------------------------------------------------------------------
function disp_eigen(handles)
exp_var = handles.data.model.expvar;
cum_var = handles.data.model.cumvar;
if strcmp(handles.data.model.type,'pls')
    exp_var = exp_var(:,1);
    cum_var = cum_var(:,1);
end
num_comp = length(exp_var);
[~,col_default] = visualize_colors;
figure
subplot(2,1,1)
hold on
bar(exp_var*100,'k')
bar(exp_var*100,'FaceColor',col_default(1,:))
axis([0.5 (num_comp + 0.5) 0 100])
set(gca,'xtick',[1:num_comp]);
hold off
ylabel('exp var (%)')
box on
title('explained variance on X')
set(gca,'YGrid','on','GridLineStyle',':')

subplot(2,1,2)
hold on
bar(cum_var*100,'FaceColor',col_default(1,:))
axis([0.5 (num_comp + 0.5) 0 100])
set(gca,'xtick',[1:num_comp]);
hold off
ylabel('cum exp var (%)')
if strcmp(handles.data.model.type,'pcr')
    xlabel('principal components')
else
    xlabel('latent variables')    
end
title('cumulative variance on X')
set(gca,'YGrid','on','GridLineStyle',':')
box on
set(gcf,'color','white')

% ------------------------------------------------------------------------
function disp_varselection(handles)
res = handles.data.model.settings.selection_res;
for r=1:res.options.runs
    best_chrom(r,:) = res.pop{r}.chrom(1,:);
    best_resp(r) = res.pop{r}.resp(1);
    pred_resp(r) = res.pop{r}.pred_eval;
end
ga_plot(best_chrom,best_resp,pred_resp,res.options.runs,res.options.num_windows,res.options.runs,res.var_selected,res.options.original_data_size)

% ------------------------------------------------------------------------
function open_regression_performance(model,pred)
str_out_training = update_fitting(model);
table_measures{1,1} = 'measure'; 
table_measures{2,1} = 'rmse'; 
table_measures{3,1} = 'R2';
table_measures = [table_measures str_out_training];
if isstruct(model.cv)
    str_out_cv = update_cv(model.cv);
    table_measures = [table_measures str_out_cv];
end
if isstruct(pred)
    if isfield(pred,'reg_param')
        str_out_pred = update_pred(pred);
        table_measures = [table_measures str_out_pred];
    end
end
assignin('base','tmp_regression_performance',table_measures);
openvar('tmp_regression_performance');

% -------------------------------------------------------------------------
function str_out = update_pred(pred)
reg_param = pred.reg_param;
nformat3 = '%1.3f';
nformat4 = '%1.4f';
R2  = sprintf(nformat3,reg_param.R2);
rmse = sprintf(nformat4,reg_param.rmsep);    
% error
str_out{1,1} = 'external set';
str_out{2,1} = rmse;
str_out{3,1} = R2;

% -------------------------------------------------------------------------
function str_out = update_cv(cv)
if isstruct(cv)
    reg_param = cv.reg_param;
    nformat3 = '%1.3f';
    nformat4 = '%1.4f';
    R2  = sprintf(nformat3,reg_param.R2);
    rmse = sprintf(nformat4,reg_param.rmse);
    % error
    str_out{1,1} = 'cv';
    str_out{2,1} = rmse;
    str_out{3,1} = R2;
else
    str_out{1,1} = 'cv';
    str_out{2,1} = 'na';
    str_out{3,1} = 'na';
end

% -------------------------------------------------------------------------
function str_out = update_fitting(model)
reg_param = model.reg_param;
nformat3 = '%1.3f';
nformat4 = '%1.4f';
R2  = sprintf(nformat3,reg_param.R2);
rmse = sprintf(nformat4,reg_param.rmse);
% error
str_out{1,1} = 'training';
str_out{2,1} = rmse;
str_out{3,1} = R2;

% ------------------------------------------------------------------------
function handles = predict_samples(handles)
% check data and model size
Xpred = handles.data.X;
if isfield(handles.data.model.settings,'selection_res')
    Xpred = Xpred(:,handles.data.model.settings.selection_res.var_selected);
end
if size(handles.data.model.settings.raw_data,2) == size(Xpred,2)
    errortype = 'none';
else
    errortype = ['mismatch in the number of variables: data have ' num2str(size(Xpred,2)) ...
                 ' variables, but model was calculated with ' num2str(size(handles.data.model.settings.raw_data,2)) ' variables'];
end
if strcmp(errortype,'none')
    if strcmp(handles.data.model.type,'ols')
        pred = olspred(Xpred,handles.data.model);
    elseif strcmp(handles.data.model.type,'pls')
        pred = plspred(Xpred,handles.data.model);
    elseif strcmp(handles.data.model.type,'pcr')
        pred = pcrpred(Xpred,handles.data.model);
    elseif strcmp(handles.data.model.type,'ridge')
        pred = ridgepred(Xpred,handles.data.model);        
    elseif strcmp(handles.data.model.type,'knn')
        pred = knnpred(Xpred,handles.data.model.settings.raw_data,handles.data.model.settings.raw_y,handles.data.model.settings.K,handles.data.model.settings.dist_type,handles.data.model.settings.pret_type);
    elseif strcmp(handles.data.model.type,'bnn')
        pred = bnnpred(Xpred,handles.data.model.settings.raw_data,handles.data.model.settings.raw_y,handles.data.model.settings.alpha,handles.data.model.settings.dist_type,handles.data.model.settings.pret_type);
    end
    handles.present.pred = 1;
    handles.data.pred = pred;
    handles.data.pred.X = Xpred;
    if handles.present.sample_labels == 1
        handles.data.pred.sample_labels = handles.data.sample_labels;
    else
        for k=1:size(Xpred,1)
            handles.data.pred.sample_labels{k} = ['P' num2str(k)];
        end
        handles.data.pred.sample_labels = handles.data.pred.sample_labels';
    end
    if handles.present.response == 1
        handles.data.pred.response = handles.data.response;
        handles.data.pred.reg_param = calc_external_reg_param(handles.data.model.settings.raw_y,handles.data.pred.response,handles.data.pred.yc);
        % residuals
        r = handles.data.pred.response - handles.data.pred.yc;
        nobj = length(r);
        Hdiff = 1 - handles.data.pred.H;
        svar = sqrt(diag(r'*(r./(Hdiff.^2)))/(nobj-1))';
        r_std = r./svar(ones(nobj,1),:).*sqrt(Hdiff);
        handles.data.pred.r = r;
        handles.data.pred.r_std = r_std;
        update_listbox_model(handles)
    end
    h1 = 'Samples have been predicted.';
    helpdlg(h1)
    handles = enable_disable(handles);
else
    errordlg(errortype,'error comparing data and model sizes') 
end

% ------------------------------------------------------------------------
function handles = reduce_data(handles,samples_in,variables_in)
variables_in = sort(variables_in);
samples_in = sort(samples_in);
handles.data.X = handles.data.X(samples_in,variables_in);
if handles.present.response
    handles.data.response = handles.data.response(samples_in);
end
handles.data.sample_labels = handles.data.sample_labels(samples_in);
handles.data.variable_labels = handles.data.variable_labels(variables_in);
update_listbox_data(handles);
if handles.present.model == 2
    handles = reset_model(handles);
    update_listbox_model(handles);
    handles = enable_disable(handles);
end

% ------------------------------------------------------------------------
function handles = init_handles(handles)
handles.present.data  = 0;
handles.present.response = 0;
handles.present.model = 0;  % = 1 is loaded, = 2 is calculated
handles.present.sample_labels = 0;
handles.present.variable_labels = 0;
handles.present.pred = 0;
handles.data.name_response = [];
handles.data.name_data = [];
handles.data.name_model = [];
handles.data.X = [];
handles.data.response = [];
handles.data.model = [];
handles.data.pred = [];

% ------------------------------------------------------------------------
function handles = reset_data(handles)
handles.present.data  = 0;
handles.present.pred = 0;
handles.data.X = [];
handles.data.name_data = [];
handles.data.pred = [];

% ------------------------------------------------------------------------
function handles = reset_pred(handles)
handles.present.pred = 0;
handles.data.pred = [];

% ------------------------------------------------------------------------
function handles = reset_labels(handles)
handles.present.sample_labels = 0;
handles.present.variable_labels = 0;
handles.data.sample_labels = [];
handles.data.variable_labels = [];

% ------------------------------------------------------------------------
function handles = reset_response(handles)
handles.present.response = 0;
handles.data.name_response = [];
handles.data.response = [];

% ------------------------------------------------------------------------
function handles = reset_model(handles)
handles.present.model = 0;
handles.present.pred = 0;
handles.data.name_model = [];
handles.data.model = [];
handles.data.pred = [];

% ------------------------------------------------------------------------
function handles = enable_disable(handles)
if handles.present.data == 0
    set(handles.m_file_load_response,'Enable','off');    
    set(handles.m_file_clear_data,'Enable','off');
    set(handles.m_view_data,'Enable','off');
    set(handles.m_view_correlation,'Enable','off');
    set(handles.m_view_plot_profiles,'Enable','off');
    set(handles.m_view_plot_univariate,'Enable','off');
    set(handles.m_view_delete,'Enable','off');
    set(handles.m_file_load_sample_labels,'Enable','off');   
    set(handles.m_file_load_variable_labels,'Enable','off');
else
    set(handles.m_file_clear_data,'Enable','on');
    set(handles.m_file_load_response,'Enable','on');
    set(handles.m_view_data,'Enable','on');
    set(handles.m_view_correlation,'Enable','on');
    set(handles.m_view_plot_profiles,'Enable','on');
    set(handles.m_view_plot_univariate,'Enable','on');
    set(handles.m_view_delete,'Enable','on');    
    set(handles.m_file_load_sample_labels,'Enable','on');   
    set(handles.m_file_load_variable_labels,'Enable','on');
end
if handles.present.response == 0
    set(handles.m_calculate_ols,'Enable','off');
    set(handles.m_pls,'Enable','off');   
    set(handles.m_pcr,'Enable','off'); 
    set(handles.m_ridge,'Enable','off'); 
    set(handles.m_knn,'Enable','off');
    set(handles.m_vs,'Enable','off');
    set(handles.m_view_response,'Enable','off');
else
    if size(handles.data.X,1) > size(handles.data.X,2)
        set(handles.m_calculate_ols,'Enable','on');    
    else
        set(handles.m_calculate_ols,'Enable','off');
    end
    set(handles.m_pcr,'Enable','on');
    set(handles.m_pls,'Enable','on');   
    set(handles.m_ridge,'Enable','on'); 
    set(handles.m_knn,'Enable','on');
    set(handles.m_vs,'Enable','on');
    set(handles.m_view_response,'Enable','on');
end
if handles.present.model == 0
    set(handles.m_file_save_model,'Enable','off');
    set(handles.m_file_save_varselection,'Enable','off');
    set(handles.m_file_clear_model,'Enable','off');
    set(handles.m_results_ols,'Enable','off');
    set(handles.m_results_view_ols_scores,'Enable','off');
    set(handles.m_results_view_ols_loadings,'Enable','off');
    set(handles.m_results_view_ols_performance,'Enable','off');
    set(handles.m_results_pls,'Enable','off');
    set(handles.m_results_eigen_pls,'Enable','off');
    set(handles.m_results_view_pls_scores,'Enable','off');
    set(handles.m_results_view_pls_loadings,'Enable','off');
    set(handles.m_results_view_pls_performance,'Enable','off');
    set(handles.m_results_pcr,'Enable','off');
    set(handles.m_results_eigen_pcr,'Enable','off');
    set(handles.m_results_view_pcr_scores,'Enable','off');
    set(handles.m_results_view_pcr_loadings,'Enable','off');
    set(handles.m_results_view_pcr_performance,'Enable','off');
    set(handles.m_results_ridge,'Enable','off');
    set(handles.m_results_view_ridge_scores,'Enable','off');
    set(handles.m_results_view_ridge_loadings,'Enable','off');
    set(handles.m_results_view_ridge_performance,'Enable','off');
    set(handles.m_results_knn,'Enable','off');
    set(handles.m_results_view_knn_scores,'Enable','off');
    set(handles.m_results_view_knn_performance,'Enable','off');
    set(handles.m_results_varselection,'Enable','off');
    set(handles.m_results_varselection_plots,'Enable','off');
    set(handles.m_results_varselection_varlist,'Enable','off');
else
    set(handles.m_file_clear_model,'Enable','on');
    set(handles.m_file_save_model,'Enable','on');
    if isfield(handles.data.model.settings,'selection_res')
        set(handles.m_file_save_varselection,'Enable','on');
        set(handles.m_results_varselection,'Enable','on');
        if strcmp(handles.data.model.settings.selection_res.selection_type,'ga')
            set(handles.m_results_varselection_plots,'Enable','on');
        else
            set(handles.m_results_varselection_plots,'Enable','off');
        end
        set(handles.m_results_varselection_varlist,'Enable','on');
    else
        set(handles.m_results_varselection,'Enable','off');
        set(handles.m_results_varselection_plots,'Enable','off');
        set(handles.m_results_varselection_varlist,'Enable','off');
        set(handles.m_file_save_varselection,'Enable','off');
    end
    if strcmp(handles.data.model.type,'pcr')
        set(handles.m_results_ols,'Enable','off');
        set(handles.m_results_view_ols_scores,'Enable','off');
        set(handles.m_results_view_ols_loadings,'Enable','off');
        set(handles.m_results_view_ols_performance,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_view_pls_scores,'Enable','off');
        set(handles.m_results_view_pls_loadings,'Enable','off');
        set(handles.m_results_view_pls_performance,'Enable','off');
        set(handles.m_results_pcr,'Enable','on');
        set(handles.m_results_eigen_pcr,'Enable','on');
        set(handles.m_results_view_pcr_scores,'Enable','on');
        set(handles.m_results_view_pcr_loadings,'Enable','on');
        set(handles.m_results_view_pcr_performance,'Enable','on');
        set(handles.m_results_ridge,'Enable','off');
        set(handles.m_results_view_ridge_scores,'Enable','off');
        set(handles.m_results_view_ridge_loadings,'Enable','off');
        set(handles.m_results_view_ridge_performance,'Enable','off');
        set(handles.m_results_knn,'Enable','off');
        set(handles.m_results_view_knn_scores,'Enable','off');
        set(handles.m_results_view_knn_performance,'Enable','off');
    elseif strcmp(handles.data.model.type,'ols')
        set(handles.m_results_ols,'Enable','on');
        set(handles.m_results_view_ols_scores,'Enable','on');
        set(handles.m_results_view_ols_loadings,'Enable','on');
        set(handles.m_results_view_ols_performance,'Enable','on');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_view_pls_scores,'Enable','off');
        set(handles.m_results_view_pls_loadings,'Enable','off');
        set(handles.m_results_view_pls_performance,'Enable','off');
        set(handles.m_results_pcr,'Enable','off');
        set(handles.m_results_eigen_pcr,'Enable','off');
        set(handles.m_results_view_pcr_scores,'Enable','off');
        set(handles.m_results_view_pcr_loadings,'Enable','off');
        set(handles.m_results_view_pcr_performance,'Enable','off');
        set(handles.m_results_ridge,'Enable','off');
        set(handles.m_results_view_ridge_scores,'Enable','off');
        set(handles.m_results_view_ridge_loadings,'Enable','off');
        set(handles.m_results_view_ridge_performance,'Enable','off');
        set(handles.m_results_knn,'Enable','off');
        set(handles.m_results_view_knn_scores,'Enable','off');
        set(handles.m_results_view_knn_performance,'Enable','off');
    elseif strcmp(handles.data.model.type,'pls')
        set(handles.m_results_ols,'Enable','off');
        set(handles.m_results_view_ols_scores,'Enable','off');
        set(handles.m_results_view_ols_loadings,'Enable','off');
        set(handles.m_results_view_ols_performance,'Enable','off');
        set(handles.m_results_pls,'Enable','on');
        set(handles.m_results_eigen_pls,'Enable','on');
        set(handles.m_results_view_pls_scores,'Enable','on');
        set(handles.m_results_view_pls_loadings,'Enable','on');
        set(handles.m_results_view_pls_performance,'Enable','on');
        set(handles.m_results_pcr,'Enable','off');
        set(handles.m_results_eigen_pcr,'Enable','off');
        set(handles.m_results_view_pcr_scores,'Enable','off');
        set(handles.m_results_view_pcr_loadings,'Enable','off');
        set(handles.m_results_view_pcr_performance,'Enable','off');
        set(handles.m_results_ridge,'Enable','off');
        set(handles.m_results_view_ridge_scores,'Enable','off');
        set(handles.m_results_view_ridge_loadings,'Enable','off');
        set(handles.m_results_view_ridge_performance,'Enable','off');
        set(handles.m_results_knn,'Enable','off');
        set(handles.m_results_view_knn_scores,'Enable','off');
        set(handles.m_results_view_knn_performance,'Enable','off');
    elseif strcmp(handles.data.model.type,'knn') || strcmp(handles.data.model.type,'bnn')
        set(handles.m_results_ols,'Enable','off');
        set(handles.m_results_view_ols_scores,'Enable','off');
        set(handles.m_results_view_ols_loadings,'Enable','off');
        set(handles.m_results_view_ols_performance,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_view_pls_scores,'Enable','off');
        set(handles.m_results_view_pls_loadings,'Enable','off');
        set(handles.m_results_view_pls_performance,'Enable','off');
        set(handles.m_results_pcr,'Enable','off');
        set(handles.m_results_eigen_pcr,'Enable','off');
        set(handles.m_results_view_pcr_scores,'Enable','off');
        set(handles.m_results_view_pcr_loadings,'Enable','off');
        set(handles.m_results_view_pcr_performance,'Enable','off');
        set(handles.m_results_ridge,'Enable','off');
        set(handles.m_results_view_ridge_scores,'Enable','off');
        set(handles.m_results_view_ridge_loadings,'Enable','off');
        set(handles.m_results_view_ridge_performance,'Enable','off');
        set(handles.m_results_knn,'Enable','on');
        set(handles.m_results_view_knn_scores,'Enable','on');
        set(handles.m_results_view_knn_performance,'Enable','on');
    elseif strcmp(handles.data.model.type,'ridge')
        set(handles.m_results_ols,'Enable','off');
        set(handles.m_results_view_ols_scores,'Enable','off');
        set(handles.m_results_view_ols_loadings,'Enable','off');
        set(handles.m_results_view_ols_performance,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_view_pls_scores,'Enable','off');
        set(handles.m_results_view_pls_loadings,'Enable','off');
        set(handles.m_results_view_pls_performance,'Enable','off');
        set(handles.m_results_pcr,'Enable','off');
        set(handles.m_results_eigen_pcr,'Enable','off');
        set(handles.m_results_view_pcr_scores,'Enable','off');
        set(handles.m_results_view_pcr_loadings,'Enable','off');
        set(handles.m_results_view_pcr_performance,'Enable','off');
        set(handles.m_results_ridge,'Enable','on');
        set(handles.m_results_view_ridge_scores,'Enable','on');
        set(handles.m_results_view_ridge_loadings,'Enable','on');
        set(handles.m_results_view_ridge_performance,'Enable','on');
        set(handles.m_results_knn,'Enable','off');
        set(handles.m_results_view_knn_scores,'Enable','off');
        set(handles.m_results_view_knn_performance,'Enable','off');
    end
end
if handles.present.pred == 1
    set(handles.m_predict_response,'Enable','on');
    set(handles.m_file_save_pred,'Enable','on');
    set(handles.m_predict_samples_view,'Enable','on');
else
    set(handles.m_file_save_pred,'Enable','off');
    set(handles.m_predict_response,'Enable','off');
    set(handles.m_predict_samples_view,'Enable','off');
end
% predict new samples is active when
% 1. model is loaded and data are already loaded
% 2. data are loaded and model is already loaded
% is not active when
% 3. model is calculated with the loaded data
if handles.present.model == 1 && handles.present.data == 1
    set(handles.m_predict_samples,'Enable','on');
else
    set(handles.m_predict_samples,'Enable','off');
end
