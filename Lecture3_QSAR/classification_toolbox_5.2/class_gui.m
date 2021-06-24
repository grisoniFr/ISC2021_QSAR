function varargout = class_gui(varargin)

% class_gui is the main routine to open the graphical interface of the Classification Toolbox.
% In order to open the graphical interface, just type on the matlab command line:
%
% class_gui
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
                   'gui_OpeningFcn', @class_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @class_gui_OutputFcn, ...
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


% --- Executes just before class_gui is made visible.
function class_gui_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
set(handles.output,'Position',[100 50 84 14]);
set(handles.listbox_model,'Position',[44 1 37 12]);
set(handles.listbox_data,'Position',[3 1 37 12]);
movegui(handles.class_gui,'center');
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
function varargout = class_gui_OutputFcn(hObject, eventdata, handles)
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
        handles = reset_class(handles);
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
        handles = reset_class(handles); 
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
function m_file_load_class_Callback(hObject, eventdata, handles)
% ask for overwriting
if handles.present.class == 1
    q = questdlg('Class is alreday loaded. Do you wish to overwrite it?','loading class','yes','no','yes');
else
    q = 'yes';
end
if strcmp(q,'yes') 
    res = visualize_load(2,size(handles.data.X,1));
    if isnan(res.loaded_file)
        if handles.present.class  == 0
            handles.present.class  = 0;
        else
            handles.present.class  = 1;
        end
    elseif res.from_file == 1
        handles.present.class  = 1;
        tmp_data = load(res.path);
        handles.data.class = getfield(tmp_data,res.name);
        if size(handles.data.class,2) > size(handles.data.class,1)
            handles.data.class = handles.data.class';
        end
        handles.data.name_class = res.name;
    else
        handles.present.class  = 1;
        handles.data.class = evalin('base',res.name);
        if size(handles.data.class,2) > size(handles.data.class,1)
            handles.data.class = handles.data.class';
        end
        handles.data.name_class = res.name;
    end
    if iscell(handles.data.class)
        if handles.present.model
            if length(handles.data.model.labels.class_labels) > 0
                class_string_tmp = handles.data.class;
                handles.data.class_string = handles.data.class;
                [handles.data.class, handles.data.class_labels] = calc_class_string(handles.data.class_string,handles.data.model.labels.class_labels);
            else
                % the loaded model is caluclated on a numerical class vector
                handles.data.class_string = handles.data.class;
                [handles.data.class, handles.data.class_labels] = calc_class_string(handles.data.class_string);
            end
        else
            handles.data.class_string = handles.data.class;
            [handles.data.class, handles.data.class_labels] = calc_class_string(handles.data.class_string);
        end
        if sum(handles.data.class) == 0
            warndlg('The loaded class vector (as cell array) does not contain class labels corresponding to those used to train the loaded model','warning on loaded class')
            handles.data.class_string = class_string_tmp;
            [handles.data.class, handles.data.class_labels] = calc_class_string(handles.data.class_string);
        end
    else
        handles.data.class_string = {};
        handles.data.class_labels = {};
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
        if handles.present.class
            % if, when model is loaded, data with class (as string) is already
            % present, check correspondance of class labels
            if length(handles.data.model.labels.class_labels) > 0
                tmp_class = handles.data.class;
                tmp_class_labels = handles.data.class_labels;
                [handles.data.class, handles.data.class_labels] = calc_class_string(handles.data.class_string,handles.data.model.labels.class_labels);
                if sum(handles.data.class) == 0
                    warndlg('The loaded class vector (as cell array) does not contain class labels corresponding to those used to train the loaded model','warning on loaded class')
                    handles.data.class = tmp_class;
                    handles.data.class_labels = tmp_class_labels;
                end
            end
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
    if size(handles.data.variable_labels,2) > size(handles.data.variable_labels,1)
        handles.data.variable_labels = handles.data.variable_labels';
    end
else
    handles.present.variable_labels  = 1;
    handles.data.variable_labels = evalin('base',res.name);
    if size(handles.data.variable_labels,2) > size(handles.data.variable_labels,1)
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
function m_file_clear_data_Callback(hObject, eventdata, handles)
handles = reset_data(handles);
handles = reset_class(handles);
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
function m_view_class_Callback(hObject, eventdata, handles)
if length(handles.data.class_labels) == 0
    assignin('base','tmp_class',handles.data.class);
else
    assignin('base','tmp_class',handles.data.class_string);
end
openvar('tmp_class');

% --------------------------------------------------------------------
function m_view_plot_univariate_Callback(hObject, eventdata, handles)
visualize_univariate(handles.data)

% --------------------------------------------------------------------
function m_view_plot_profiles_Callback(hObject, eventdata, handles)
visualize_profiles_samples(handles.data);

% --------------------------------------------------------------------
function m_view_wilks_Callback(hObject, eventdata, handles)
var_in = visualize_lambda(handles.data);
if length(var_in) > 0
    samples_in = [1:size(handles.data.X,1)];
    handles = reduce_data(handles,samples_in,var_in);
    guidata(hObject,handles)
end

% --------------------------------------------------------------------
function m_view_delete_Callback(hObject, eventdata, handles)
out = visualize_delete_samples(size(handles.data.X,1),handles.data.class,handles.data.sample_labels,handles.data.class_string);
if ~isnan(out)
    if size(handles.data.X,1) > 1
        dodelete = 0;
        if handles.present.class
            in = ones(size(handles.data.X,1),1);
            in(out) = 0;
            in = find(in);
            tmpclass = handles.data.class(in);
            if max(tmpclass) < 2 
                h1 = 'sample can not be deleted sice the number of classes would be reduced to just one!';
                warndlg([h1],'Delete samples')
            else
                dodelete = 1;
            end
        else
            dodelete = 1;
        end
        if dodelete
            in = ones(size(handles.data.X,1),1);
            in(out) = 0;
            samples_in = find(in);
            variables_in = [1:size(handles.data.X,2)];
            handles = reduce_data(handles,samples_in,variables_in);
            guidata(hObject,handles)
        end
    else
        h1 = ['There is just one sample in the dataset. It is not possible to delete it!'];
        warndlg([h1],'Delete samples')
    end
end

% --------------------------------------------------------------------
function m_calculate_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_da_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_calculate_multinormality_Callback(hObject, eventdata, handles)
damultinormality(handles.data.X);

% --------------------------------------------------------------------
function m_calculate_da_Callback(hObject, eventdata, handles)
handles = do_da(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_calculate_pcada_comp_Callback(hObject, eventdata, handles)
do_pcada_comp(handles);

% --------------------------------------------------------------------
function m_calculate_pcada_Callback(hObject, eventdata, handles)
handles = do_pcada(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_calculate_cart_Callback(hObject, eventdata, handles)
handles = do_cart(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_pls_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_calculate_pls_comp_Callback(hObject, eventdata, handles)
do_pls_comp(handles);

% --------------------------------------------------------------------
function m_calculate_pls_Callback(hObject, eventdata, handles)
handles = do_pls(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_pf_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_calculate_pf_smoot_Callback(hObject, eventdata, handles)
do_pf_smoot(handles);

% --------------------------------------------------------------------
function m_calculate_pf_Callback(hObject, eventdata, handles)
handles = do_pf(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_svm_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_calculate_svm_param_Callback(hObject, eventdata, handles)
do_svm_param(handles);

% --------------------------------------------------------------------
function m_calculate_svm_Callback(hObject, eventdata, handles)
handles = do_svm(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_simca_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_calculate_simca_comp_Callback(hObject, eventdata, handles)
do_simca_comp(handles);

% --------------------------------------------------------------------
function m_calculate_simca_Callback(hObject, eventdata, handles)
handles = do_simca(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_uneq_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_calculate_uneq_comp_Callback(hObject, eventdata, handles)
do_uneq_comp(handles);

% --------------------------------------------------------------------
function m_calculate_uneq_Callback(hObject, eventdata, handles)
handles = do_uneq(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_knn_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_calculate_knn_k_Callback(hObject, eventdata, handles)
do_knn_selk(handles);

% --------------------------------------------------------------------
function m_calculate_knn_Callback(hObject, eventdata, handles)
handles = do_knn(handles);
guidata(hObject,handles)

% --------------------------------------------------------------------
function m_results_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_class_Callback(hObject, eventdata, handles)
visualize_classification_measures(handles.data.model,handles.data.pred);

% --------------------------------------------------------------------
function m_results_view_boundaries_Callback(hObject, eventdata, handles)
visualize_plotprediction(handles.data.model)

% --------------------------------------------------------------------
function m_results_da_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_canonical_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_canonical_loadings_Callback(hObject, eventdata, handles)
visualize_loadings(handles.data.model)

% --------------------------------------------------------------------
function m_results_view_pcada_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred,'pca')

% --------------------------------------------------------------------
function m_results_view_pcada_loadings_Callback(hObject, eventdata, handles)
visualize_loadings(handles.data.model,'pca')

% --------------------------------------------------------------------
function m_results_eigen_pcada_Callback(hObject, eventdata, handles)
disp_eigen_pca(handles)

% --------------------------------------------------------------------
function m_results_view_cart_Callback(hObject, eventdata, handles)
disp_tree(handles)

% --------------------------------------------------------------------
function m_results_pls_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_plsda_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_plsda_loadings_Callback(hObject, eventdata, handles)
visualize_loadings(handles.data.model)

% --------------------------------------------------------------------
function m_results_view_roc_Callback(hObject, eventdata, handles)
disp_roc(handles)

% --------------------------------------------------------------------
function m_results_view_roc_simca_Callback(hObject, eventdata, handles)
disp_roc(handles)

% --------------------------------------------------------------------
function m_results_view_roc_uneq_Callback(hObject, eventdata, handles)
disp_roc(handles)

% --------------------------------------------------------------------
function m_results_eigen_pls_Callback(hObject, eventdata, handles)
disp_eigen(handles)

% --------------------------------------------------------------------
function m_results_simca_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_simca_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_simca_loadings_Callback(hObject, eventdata, handles)
visualize_loadings(handles.data.model)

% --------------------------------------------------------------------
function m_results_eigen_simca_Callback(hObject, eventdata, handles)
disp_eigen_simca(handles)

% --------------------------------------------------------------------
function m_results_uneq_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_results_view_uneq_scores_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_uneq_loadings_Callback(hObject, eventdata, handles)
visualize_loadings(handles.data.model)

% --------------------------------------------------------------------
function m_results_eigen_uneq_Callback(hObject, eventdata, handles)
disp_eigen_simca(handles)

% --------------------------------------------------------------------
function m_results_view_pf_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

% --------------------------------------------------------------------
function m_results_view_svm_Callback(hObject, eventdata, handles)
visualize_scores(handles.data.model,handles.data.pred)

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
function m_predict_class_Callback(hObject, eventdata, handles)
if isfield(handles.data.pred,'class_pred_string')
    assignin('base','tmp_class_predicted',handles.data.pred.class_pred_string);
else
    assignin('base','tmp_class_predicted',handles.data.pred.class_pred);
end
openvar('tmp_class_predicted');

% --------------------------------------------------------------------
function m_predict_results_Callback(hObject, eventdata, handles)
visualize_classification_measures(handles.data.model,handles.data.pred);

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
h3 = ['Ballabio D, Consonni V, (2013) Classification tools in chemistry. Part 1: Linear models. PLS-DA. Analytical Methods, 5, 3790-3798'];
helpdlg([h1 hr hr h3 hr hr],'How to cite')

% --------------------------------------------------------------------
function m_about_Callback(hObject, eventdata, handles)
h1 = 'classification toolbox for MATLAB version 5.2';
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
function do_pls_comp(handles)
% open do settings
maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
if maxcomp > 20; maxcomp = 20; end
[cv_groups,cv_type,~,scaling,assign_method,~,~,domodel] = visualize_settings_big('plsda',size(handles.data.X,1),handles.present.model,handles.data.model,maxcomp,1);
if strcmp('none',cv_type) && domodel == 1
    domodel = 0;
    errortype = (['the optimal number of components should be choosen in cross validation. Choose a cross validation type.']);
    errordlg(errortype,'calculation error')
end
if domodel
    err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
    if err_cv == 1
        if strcmp(cv_type,'vene')
            meth = 'venetian blinds';
        else
            meth = 'contiguous blocks';
        end
        str = ['cross validation failed: samples are not correctly distributed with ' meth...
            '; try to use other cross validation procedures or'...
            ' a different number of cross-validation groups.'];
        warndlg(str,'cross validation')
    else
        % activate pointer
        set(handles.class_gui,'Pointer','watch')
        % run model
        res = plsdacompsel(handles.data.X,handles.data.class,scaling,cv_type,cv_groups,assign_method);
        if length(res.er) > 1
            plot_ercv(res,'plsda');
        end
        set(handles.class_gui,'Pointer','arrow')
    end
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function do_pf_smoot(handles)
maxpfclass = 5;
if max(handles.data.class) <= maxpfclass
    % open do settings
    maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
    if maxcomp > 10; maxcomp = 10; end
    [cv_groups,cv_type,num_comp,scaling,kernel,perc,~,domodel] = visualize_settings_classmodelling('pf',size(handles.data.X,1),handles.present.model,handles.data.model,max(handles.data.class),maxcomp,handles.data.class_labels,1);
    if ischar(num_comp)
        % exceptions
        if strcmp(num_comp,'automatic')
            num_comp = 0;
        else
            num_comp = NaN;
        end
    end
    if strcmp('none',cv_type) && domodel == 1
        domodel = 0;
        errortype = (['the optimal smoothing should be choosen in cross validation. Choose a cross validation type.']);
        errordlg(errortype,'calculation error')
    end
    if domodel
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
        if err_cv == 1
            if strcmp(cv_type,'vene')
                meth = 'venetian blinds';
            else
                meth = 'contiguous blocks';
            end
            str = ['cross validation failed: samples are not correctly distributed with ' meth...
                '; try to use other cross validation procedures or'...
                ' a different number of cross-validation groups.'];
            warndlg(str,'cross validation')
        else
            % activate pointer
            set(handles.class_gui,'Pointer','watch')
            % run model
            res = potsmootsel(handles.data.X,handles.data.class,kernel,perc,scaling,cv_type,cv_groups,num_comp);
            if numel(res.er) > 1
                plot_ercv_simca(res,'pf',res.settings.smoot_range,handles.data.class_labels);
            end
            set(handles.class_gui,'Pointer','arrow')
        end
    else
        set(handles.class_gui,'Pointer','arrow')
    end
else
    str = ['in the gui of the classification toolbox Potential Functions can be calculated '...
        'on a maximum of 5 classes;'...
        ' if you have more classes, please use the command line routine potfit.'];
    warndlg(str,'simca model')
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function do_svm_param(handles)
% open do settings
maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
if maxcomp > 10; maxcomp = 10; end
[cv_groups,cv_type,num_comp,scaling,kernel,~,~,domodel] = visualize_settings_big('svm',size(handles.data.X,1),handles.present.model,handles.data.model,maxcomp,1);
if ischar(num_comp)
    % exceptions
    if strcmp(num_comp,'automatic')
        num_comp = 0;
    else
        num_comp = NaN;
    end
end

if strcmp('none',cv_type) && domodel == 1
    domodel = 0;
    errortype = (['the optimal parameters should be choosen in cross validation. Choose a cross validation type.']);
    errordlg(errortype,'calculation error')
end
if domodel
    err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
    if err_cv == 1
        if strcmp(cv_type,'vene')
            meth = 'venetian blinds';
        else
            meth = 'contiguous blocks';
        end
        str = ['cross validation failed: samples are not correctly distributed with ' meth...
            '; try to use other cross validation procedures or'...
            ' a different number of cross-validation groups.'];
        warndlg(str,'cross validation')
    else
        % activate pointer
        set(handles.class_gui,'Pointer','watch')
        % run model
        res = svmcostsel(handles.data.X,handles.data.class,kernel,scaling,cv_type,cv_groups,num_comp);
        if numel(res.er) > 1
            plot_ercv_svm(res);
        end
        set(handles.class_gui,'Pointer','arrow')
    end
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function do_simca_comp(handles)
maxsimcaclass = 5;
if max(handles.data.class) <= maxsimcaclass
    % open do settings
    maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
    if maxcomp > 20; maxcomp = 20; end
    [cv_groups,cv_type,~,scaling,~,~,~,domodel] = visualize_settings_classmodelling('simca',size(handles.data.X,1),handles.present.model,handles.data.model,max(handles.data.class),maxcomp,handles.data.class_labels,1);
    if strcmp('none',cv_type) && domodel == 1
        domodel = 0;
        errortype = (['the optimal number of components should be choosen in cross validation. Choose a cross validation type.']);
        errordlg(errortype,'calculation error')
    end
    if domodel
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
        if err_cv == 1
            if strcmp(cv_type,'vene')
                meth = 'venetian blinds';
            else
                meth = 'contiguous blocks';
            end
            str = ['cross validation failed: samples are not correctly distributed with ' meth...
                '; try to use other cross validation procedures or'...
                ' a different number of cross-validation groups.'];
            warndlg(str,'cross validation')
        else
            % activate pointer
            set(handles.class_gui,'Pointer','watch')
            % run model
            res = simcacompsel(handles.data.X,handles.data.class,scaling,cv_type,cv_groups);
            if length(res.er) > 1
                plot_ercv_simca(res,'simca',[1:size(res.er,1)],handles.data.class_labels);
            end
            set(handles.class_gui,'Pointer','arrow')
        end
    else
        set(handles.class_gui,'Pointer','arrow')
    end
else
    str = ['in the gui of the classification toolbox SIMCA can be calculated '...
        'on a maximum of 5 classes;'...
        ' if you have more classes, please use the command line routine simcafit.'];
    warndlg(str,'simca model')
    set(handles.class_gui,'Pointer','arrow')
end
% ------------------------------------------------------------------------
function do_uneq_comp(handles)
maxuneqclass = 5;
if max(handles.data.class) <= maxuneqclass
    % open do settings
    maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
    if maxcomp > 20; maxcomp = 20; end
    [cv_groups,cv_type,~,scaling,~,~,~,domodel] = visualize_settings_classmodelling('uneq',size(handles.data.X,1),handles.present.model,handles.data.model,max(handles.data.class),maxcomp,handles.data.class_labels,1);
    if strcmp('none',cv_type) && domodel == 1
        domodel = 0;
        errortype = (['the optimal number of components should be choosen in cross validation. Choose a cross validation type.']);
        errordlg(errortype,'calculation error')
    end
    if domodel
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
        if err_cv == 1
            if strcmp(cv_type,'vene')
                meth = 'venetian blinds';
            else
                meth = 'contiguous blocks';
            end
            str = ['cross validation failed: samples are not correctly distributed with ' meth...
                '; try to use other cross validation procedures or'...
                ' a different number of cross-validation groups.'];
            warndlg(str,'cross validation')
        else
            % activate pointer
            set(handles.class_gui,'Pointer','watch')
            % run model
            res = uneqcompsel(handles.data.X,handles.data.class,scaling,cv_type,cv_groups);
            if length(res.er) > 1
                plot_ercv_simca(res,'uneq',[1:size(res.er,1)],handles.data.class_labels);
            end
            set(handles.class_gui,'Pointer','arrow')
        end
    else
        set(handles.class_gui,'Pointer','arrow')
    end
else
    str = ['in the gui of the classification toolbox UNEQ can be calculated '...
        'on a maximum of 5 classes;'...
        ' if you have more classes, please use the command line routine uneqfit.'];
    warndlg(str,'simca model')
    set(handles.class_gui,'Pointer','arrow')
end
% ------------------------------------------------------------------------
function do_pcada_comp(handles)
% open do settings
maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
if maxcomp > 20; maxcomp = 20; end
[cv_groups,cv_type,~,scaling,method,~,~,domodel] = visualize_settings_big('pcada',size(handles.data.X,1),handles.present.model,handles.data.model,maxcomp,1);
if strcmp('none',cv_type) && domodel == 1
    domodel = 0;
    errortype = (['the optimal number of components should be choosen in cross validation. Choose a cross validation type.']);
    errordlg(errortype,'calculation error')
end
if domodel
    err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
    if err_cv == 1
        if strcmp(cv_type,'vene')
            meth = 'venetian blinds';
        else
            meth = 'contiguous blocks';
        end
        str = ['cross validation failed: samples are not correctly distributed with ' meth...
            '; try to use other cross validation procedures or'...
            ' a different number of cross-validation groups.'];
        warndlg(str,'cross validation')
    else
        % activate pointer
        set(handles.class_gui,'Pointer','watch')
        % run model
        res = dacompsel(handles.data.X,handles.data.class,cv_type,cv_groups,2,method,scaling,maxcomp);
        if length(res.er) > 1
            plot_ercv(res,'pcada');
        end
        set(handles.class_gui,'Pointer','arrow')
    end
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function do_knn_selk(handles)
% open do settings
[cv_groups,cv_type,~,scaling,dist_type,~,~,domodel] = visualize_settings_big('knn',size(handles.data.X,1),handles.present.model,handles.data.model,10,1);
if strcmp('none',cv_type) && domodel == 1
    domodel = 0;
    errortype = (['the optimal number of K should be choosen in cross validation. Choose a cross validation type.']);
    errordlg(errortype,'calculation error')
end
if domodel
    err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
    if err_cv == 1
        if strcmp(cv_type,'vene')
            meth = 'venetian blinds';
        else
            meth = 'contiguous blocks';
        end
        str = ['cross validation failed: samples are not correctly distributed with ' meth...
            '; try to use other cross validation procedures or'...
            ' a different number of cross-validation groups.'];
        warndlg(str,'cross validation')
    else
        % activate pointer
        set(handles.class_gui,'Pointer','watch')
        % run model
        res = knnksel(handles.data.X,handles.data.class,dist_type,scaling,cv_type,cv_groups);
        if length(res.er) > 1
            plot_ercv_knn(res);
        end
        set(handles.class_gui,'Pointer','arrow')
    end
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_da(handles)
% open do settings
[cv_groups,cv_type,model_type,domodel] = visualize_settings_small('da',size(handles.data.X,1),handles.present.model,handles.data.model);
noinvert = 0;
errortype = [''];
if strcmp(model_type,'lda')
    method = 'linear';
    if size(handles.data.X,2) > size(handles.data.X,1)
        noinvert = 1;
        errortype = (['LDA can be calculated only if the number of samples is greater than the number of variables']);
    end
else
    method = 'quadratic';
    for g=1:max(handles.data.class)
        objinclass(g) = length(find(handles.data.class==g));
    end
    if size(handles.data.X,2) > min(objinclass)
        noinvert = 1;
        errortype = (['QDA can be calculated only if the number of samples of each class is greater than the number of variables']);
    end
end
% check for more variable than samples
if noinvert
    domodel = 0;
    errordlg(errortype,'calculation error') 
end
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = dafit(handles.data.X,class_to_fit,2,method);
    if strcmp('none',cv_type)
        cv = [];
    else
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
        if err_cv == 1
            if strcmp(cv_type,'vene')
                meth = 'venetian blinds';
            else
                meth = 'contiguous blocks';
            end
            str = ['cross validation failed: samples are not correctly distributed with ' meth...
                    '; try to use other cross validation procedures or'...
                    ' a different number of cross-validation groups.'];
            warndlg(str,'cross validation')
            cv = [];
        else
            cv = dacv(handles.data.X,class_to_fit,cv_type,cv_groups,2,method);
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
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_cart(handles)
% open do settings
[cv_groups,cv_type,~,domodel] = visualize_settings_small('cart',size(handles.data.X,1),NaN,NaN);
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = cartfit(handles.data.X,class_to_fit,handles.data.variable_labels);
    if strcmp('none',cv_type)
        cv = [];
    else
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
        if err_cv == 1
            if strcmp(cv_type,'vene')
                meth = 'venetian blinds';
            else
                meth = 'contiguous blocks';
            end
            str = ['cross validation failed: samples are not correctly distributed with ' meth...
                    '; try to use other cross validation procedures or'...
                    ' a different number of cross-validation groups.'];
            warndlg(str,'cross validation')
            cv = [];
        else
            cv = cartcv(handles.data.X,class_to_fit,cv_type,cv_groups);
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
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_pls(handles)
% open do settings
maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
if maxcomp > 20; maxcomp = 20; end
[cv_groups,cv_type,num_comp,scaling,assign_method,~,~,domodel] = visualize_settings_big('plsda',size(handles.data.X,1),handles.present.model,handles.data.model,maxcomp,0);
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = plsdafit(handles.data.X,class_to_fit,num_comp,scaling,assign_method,1);
    if strcmp('none',cv_type)
        cv = [];
    else
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
        if err_cv == 1
            if strcmp(cv_type,'vene')
                meth = 'venetian blinds';
            else
                meth = 'contiguous blocks';
            end
            str = ['cross validation failed: samples are not correctly distributed with ' meth...
                    '; try to use other cross validation procedures or'...
                    ' a different number of cross-validation groups.'];
            warndlg(str,'cross validation')
            cv = [];
        else
            cv = plsdacv(handles.data.X,class_to_fit,num_comp,scaling,cv_type,cv_groups,assign_method);
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
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_simca(handles)
maxsimcaclass = 5;
if max(handles.data.class) <= maxsimcaclass
    % open do settings
    maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
    if maxcomp > 20; maxcomp = 20; end
    [cv_groups,cv_type,assign_method,scaling,~,~,num_comp,domodel] = visualize_settings_classmodelling('simca',size(handles.data.X,1),handles.present.model,handles.data.model,max(handles.data.class),maxcomp,handles.data.class_labels,0);
    if domodel
        % activate pointer
        set(handles.class_gui,'Pointer','watch')
        % run model
        if length(handles.data.class_labels) == 0
            class_to_fit = handles.data.class;
        else
            class_to_fit = handles.data.class_string;
        end
        model = simcafit(handles.data.X,class_to_fit,num_comp,scaling,assign_method);
        if strcmp('none',cv_type)
            cv = [];
        else
            err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
            if err_cv == 1
                if strcmp(cv_type,'vene')
                    meth = 'venetian blinds';
                else
                    meth = 'contiguous blocks';
                end
                str = ['cross validation failed: samples are not correctly distributed with ' meth...
                    '; try to use other cross validation procedures or'...
                    ' a different number of cross-validation groups.'];
                warndlg(str,'cross validation')
                cv = [];
            else
                cv = simcacv(handles.data.X,class_to_fit,num_comp,scaling,cv_type,cv_groups,assign_method);
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
        set(handles.class_gui,'Pointer','arrow')
        update_listbox_model(handles)
        handles = enable_disable(handles);
    else
        set(handles.class_gui,'Pointer','arrow')
    end
else
    str = ['in the gui of the classification toolbox SIMCA can be calculated '...
        'on a maximum of 5 classes;'...
        ' if you have more classes, please use the command line routine simcafit.'];
    warndlg(str,'simca model')
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_uneq(handles)
maxuneqclass = 5;
if max(handles.data.class) <= maxuneqclass
    % open do settings
    maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
    if maxcomp > 20; maxcomp = 20; end
    [cv_groups,cv_type,assign_method,scaling,~,~,num_comp,domodel] = visualize_settings_classmodelling('uneq',size(handles.data.X,1),handles.present.model,handles.data.model,max(handles.data.class),maxcomp,handles.data.class_labels,0);
    if domodel
        % activate pointer
        set(handles.class_gui,'Pointer','watch')
        % run model
        if length(handles.data.class_labels) == 0
            class_to_fit = handles.data.class;
        else
            class_to_fit = handles.data.class_string;
        end
        model = uneqfit(handles.data.X,class_to_fit,num_comp,scaling,assign_method);
        if strcmp('none',cv_type)
            cv = [];
        else
            err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
            if err_cv == 1
                if strcmp(cv_type,'vene')
                    meth = 'venetian blinds';
                else
                    meth = 'contiguous blocks';
                end
                str = ['cross validation failed: samples are not correctly distributed with ' meth...
                    '; try to use other cross validation procedures or'...
                    ' a different number of cross-validation groups.'];
                warndlg(str,'cross validation')
                cv = [];
            else
                cv = uneqcv(handles.data.X,class_to_fit,num_comp,scaling,cv_type,cv_groups,assign_method);
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
        set(handles.class_gui,'Pointer','arrow')
        update_listbox_model(handles)
        handles = enable_disable(handles);
    else
        set(handles.class_gui,'Pointer','arrow')
    end
else
    str = ['in the gui of the classification toolbox UNEQ can be calculated '...
        'on a maximum of 5 classes;'...
        ' if you have more classes, please use the command line routine uneqfit.'];
    warndlg(str,'simca model')
    set(handles.class_gui,'Pointer','arrow')
end
% ------------------------------------------------------------------------
function handles = do_pf(handles)
maxpfclass = 5;
if max(handles.data.class) <= maxpfclass
    maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
    if maxcomp > 10; maxcomp = 10; end
    [cv_groups,cv_type,num_comp,scaling,kernel,perc,smoot,domodel] = visualize_settings_classmodelling('pf',size(handles.data.X,1),handles.present.model,handles.data.model,max(handles.data.class),maxcomp,handles.data.class_labels,0);
    if ischar(num_comp)
        % exceptions
        if strcmp(num_comp,'automatic')
            num_comp = 0;
        else
            num_comp = NaN;
        end
    end
    if domodel
        % activate pointer
        set(handles.class_gui,'Pointer','watch')
        % run model
        if length(handles.data.class_labels) == 0
            class_to_fit = handles.data.class;
        else
            class_to_fit = handles.data.class_string;
        end
        model = potfit(handles.data.X,class_to_fit,kernel,smoot,perc,scaling,num_comp);
        if strcmp('none',cv_type)
            cv = [];
        else
            err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
            if err_cv == 1
                if strcmp(cv_type,'vene')
                    meth = 'venetian blinds';
                else
                    meth = 'contiguous blocks';
                end
                str = ['cross validation failed: samples are not correctly distributed with ' meth...
                    '; try to use other cross validation procedures or'...
                    ' a different number of cross-validation groups.'];
                warndlg(str,'cross validation')
                cv = [];
            else
                cv = potcv(handles.data.X,class_to_fit,kernel,smoot,perc,scaling,cv_type,cv_groups,num_comp);
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
        set(handles.class_gui,'Pointer','arrow')
        update_listbox_model(handles)
        handles = enable_disable(handles);
    else
        set(handles.class_gui,'Pointer','arrow')
    end
else
    str = ['in the gui of the classification toolbox potential functions can be calculated '...
        'on a maximum of 5 classes;'...
        ' if you have more classes, please use the command line routine potfit.'];
    warndlg(str,'simca model')
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_svm(handles)
% open do settings
maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
if maxcomp > 10; maxcomp = 10; end
[cv_groups,cv_type,num_comp,scaling,kernel,param,cost,domodel] = visualize_settings_big('svm',size(handles.data.X,1),handles.present.model,handles.data.model,maxcomp,0);
if ischar(num_comp)
    % exceptions
    if strcmp(num_comp,'automatic')
        num_comp = 0;
    else
        num_comp = NaN;
    end
end
if ischar(param)
    param = [];
end
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = svmfit(handles.data.X,class_to_fit,kernel,cost,param,scaling,num_comp);
    if strcmp('none',cv_type)
        cv = [];
    else
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
        if err_cv == 1
            if strcmp(cv_type,'vene')
                meth = 'venetian blinds';
            else
                meth = 'contiguous blocks';
            end
            str = ['cross validation failed: samples are not correctly distributed with ' meth...
                    '; try to use other cross validation procedures or'...
                    ' a different number of cross-validation groups.'];
            warndlg(str,'cross validation')
            cv = [];
        else
            cv = svmcv(handles.data.X,class_to_fit,kernel,cost,param,scaling,cv_type,cv_groups,num_comp);
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
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_pcada(handles)
% open do settings
maxcomp = min([size(handles.data.X,2) size(handles.data.X,1)]);
if maxcomp > 20; maxcomp = 20; end
[cv_groups,cv_type,num_comp,scaling,method,~,~,domodel] = visualize_settings_big('pcada',size(handles.data.X,1),handles.present.model,handles.data.model,maxcomp,0);
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = dafit(handles.data.X,class_to_fit,2,method,num_comp,scaling);    
    if strcmp('none',cv_type)
        cv = [];
    else
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
        if err_cv == 1
            if strcmp(cv_type,'vene')
                meth = 'venetian blinds';
            else
                meth = 'contiguous blocks';
            end
            str = ['cross validation failed: samples are not correctly distributed with ' meth...
                    '; try to use other cross validation procedures or'...
                    ' a different number of cross-validation groups.'];
            warndlg(str,'cross validation')
            cv = [];
        else
            cv = dacv(handles.data.X,class_to_fit,cv_type,cv_groups,2,method,num_comp,scaling);
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
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function handles = do_knn(handles)
% open do settings
[cv_groups,cv_type,num_k,scaling,dist_type,~,~,domodel] = visualize_settings_big('knn',size(handles.data.X,1),handles.present.model,handles.data.model,10,0);
if domodel
    % activate pointer
    set(handles.class_gui,'Pointer','watch')
    % run model
    if length(handles.data.class_labels) == 0
        class_to_fit = handles.data.class;
    else
        class_to_fit = handles.data.class_string;
    end
    model = knnfit(handles.data.X,class_to_fit,num_k,dist_type,scaling);
    if strcmp('none',cv_type)
        cv = [];
    else
        err_cv = check_cv_err(handles.data.class,cv_type,cv_groups);
        if err_cv == 1
            if strcmp(cv_type,'vene')
                meth = 'venetian blinds';
            else
                meth = 'contiguous blocks';
            end
            str = ['cross validation failed: samples are not correctly distributed with ' meth...
                    '; try to use other cross validation procedures or'...
                    ' a different number of cross-validation groups.'];
            warndlg(str,'cross validation')
            cv = [];
        else
            cv = knncv(handles.data.X,class_to_fit,num_k,dist_type,scaling,cv_type,cv_groups);
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
    set(handles.class_gui,'Pointer','arrow')
    update_listbox_model(handles)
    handles = enable_disable(handles);
else
    set(handles.class_gui,'Pointer','arrow')
end

% ------------------------------------------------------------------------
function update_listbox_data(handles)
if handles.present.data == 0
    set(handles.listbox_data,'String','data not loaded');
else
    str{1} = ['data: loaded'];
    str{2} = ['name: ' handles.data.name_data];
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
    if handles.present.class == 1
        str{7} = ['class: loaded'];
        str{8} = ['name: ' handles.data.name_class];
        str{9} = ['number of classes: ' num2str(max(handles.data.class))];
    end
    set(handles.listbox_data,'String',str);
end

% ------------------------------------------------------------------------
function update_listbox_model(handles)
if handles.present.model == 0
    set(handles.listbox_model,'String','model not loaded/calculated');
elseif strcmp(handles.data.model.type,'lda') || strcmp(handles.data.model.type,'qda') || strcmp(handles.data.model.type,'cart')
    er = round(handles.data.model.class_param.er*100)/100;
    ner = round(handles.data.model.class_param.ner*100)/100;
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    str{3} = ['error rate: ' num2str(er)];
    cnt = 4;
    if isstruct(handles.data.model.cv)
        ercv = round(handles.data.model.cv.class_param.er*100)/100;
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['error rate ' cvtype ': ' num2str(ercv)]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'class_param')
            ertest = round(handles.data.pred.class_param.er*100)/100;
            nertest = round(handles.data.pred.class_param.ner*100)/100;
            str{cnt} = ['error rate test: ' num2str(ertest)]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
elseif strcmp(handles.data.model.type,'plsda') || strcmp(handles.data.model.type,'pcalda') || strcmp(handles.data.model.type,'pcaqda') 
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    if strcmp(handles.data.model.type,'plsda')
        nc = size(handles.data.model.T,2);
        ev = round(handles.data.model.cumvar(end,1)*100);
        scal = handles.data.model.settings.pret_type;
    else
        nc = size(handles.data.model.settings.modelpca.T,2);
        ev = round(handles.data.model.settings.modelpca.cum_var(end,1)*100);
        scal = handles.data.model.settings.modelpca.settings.param.pret_type;
    end
    if strcmp(scal,'none')
        set_this = 'none';
    elseif strcmp(scal,'cent')
        set_this = 'mean centering';
    else
        set_this = 'autoscaling';
    end
    str{3} = ['data scaling: ' set_this];
    str{4} = ['components in the model: ' num2str(nc)];
    str{5} = ['explained var. (X): ' num2str(ev) ' %'];
    er = round(handles.data.model.class_param.er*100)/100;
    ner = round(handles.data.model.class_param.ner*100)/100;
    str{6} = ['error rate: ' num2str(er)];
    cnt = 7;
    if isstruct(handles.data.model.cv)
        ercv = round(handles.data.model.cv.class_param.er*100)/100;
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['error rate ' cvtype ': ' num2str(ercv)]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'class_param')
            ertest = round(handles.data.pred.class_param.er*100)/100;
            nertest = round(handles.data.pred.class_param.ner*100)/100;
            str{cnt} = ['error rate test: ' num2str(ertest)]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
elseif strcmp(handles.data.model.type,'simca') || strcmp(handles.data.model.type,'uneq')
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    nc = num2str(size(handles.data.model.T{1},2));
    for g = 2:length(handles.data.model.T); nc = [nc ', ' num2str(size(handles.data.model.T{g},2))]; end
    ev = num2str(round(handles.data.model.modelpca{1}.cum_var(end)*100));
    for g = 2:length(handles.data.model.T); ev = [ev ', ' num2str(round(handles.data.model.modelpca{g}.cum_var(end)*100))]; end
    scal = handles.data.model.settings.pret_type;
    if strcmp(scal,'none')
        set_this = 'none';
    elseif strcmp(scal,'cent')
        set_this = 'mean centering';
    else
        set_this = 'autoscaling';
    end
    str{3} = ['data scaling: ' set_this];
    str{4} = ['PCs in each model: ' nc];
    str{5} = ['explained var. (%): ' ev];
    er = round(handles.data.model.class_param.er*100)/100;
    ner = round(handles.data.model.class_param.ner*100)/100;
    str{6} = ['error rate: ' num2str(er)];
    cnt = 7;
    if isstruct(handles.data.model.cv)
        ercv = round(handles.data.model.cv.class_param.er*100)/100;
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['error rate ' cvtype ': ' num2str(ercv)]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'class_param')
            ertest = round(handles.data.pred.class_param.er*100)/100;
            nertest = round(handles.data.pred.class_param.ner*100)/100;
            str{cnt} = ['error rate test: ' num2str(ertest)]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
elseif strcmp(handles.data.model.type,'knn')
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    num_k = handles.data.model.settings.K;
    scal = handles.data.model.settings.param.pret_type;
    if strcmp(scal,'none')
        set_this = 'none';
    elseif strcmp(scal,'cent')
        set_this = 'mean centering';
    else
        set_this = 'autoscaling';
    end
    str{3} = ['data scaling: ' set_this];
    str{4} = ['K value: ' num2str(num_k)];
    str{5} = ['distance: ' handles.data.model.settings.dist_type];
    er = round(handles.data.model.class_param.er*100)/100;
    ner = round(handles.data.model.class_param.ner*100)/100;
    str{6} = ['error rate: ' num2str(er)];
    cnt = 7;
    if isstruct(handles.data.model.cv)
        ercv = round(handles.data.model.cv.class_param.er*100)/100;
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['error rate ' cvtype ': ' num2str(ercv)]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'class_param')
            ertest = round(handles.data.pred.class_param.er*100)/100;
            nertest = round(handles.data.pred.class_param.ner*100)/100;
            str{cnt} = ['error rate test: ' num2str(ertest)]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
elseif strcmp(handles.data.model.type,'pf')
    sm = num2str(handles.data.model.settings.smoot(1));
    for g = 2:length(handles.data.model.settings.smoot); sm = [sm ', ' num2str(handles.data.model.settings.smoot(g))]; end
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    scal = handles.data.model.settings.pret_type;
    if strcmp(scal,'none')
        set_this = 'none';
    elseif strcmp(scal,'cent')
        set_this = 'mean centering';
    else
        set_this = 'autoscaling';
    end
    str{3} = ['data scaling: ' set_this];
    str{4} = ['kernel: ' handles.data.model.settings.type];
    str{5} = ['percentile: ' num2str(handles.data.model.settings.perc)];
    er = round(handles.data.model.class_param.er*100)/100;
    ner = round(handles.data.model.class_param.ner*100)/100;
    str{6} = ['smoothing: ' sm];
    if isnan(handles.data.model.settings.num_comp)
        str{7} = ['not calculated on PCs'];
    else
        set_this = num2str(size(handles.data.model.settings.Xclass{1},2));
        str{7} = ['calculated on ' num2str(set_this) ' PCs'];
    end
    str{8} = ['error rate: ' num2str(er)];
    cnt = 9;
    if isstruct(handles.data.model.cv)
        ercv = round(handles.data.model.cv.class_param.er*100)/100;
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['error rate ' cvtype ': ' num2str(ercv)]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'class_param')
            ertest = round(handles.data.pred.class_param.er*100)/100;
            nertest = round(handles.data.pred.class_param.ner*100)/100;
            str{cnt} = ['error rate test: ' num2str(ertest)]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);
elseif strcmp(handles.data.model.type,'svm')
    if handles.present.model == 1
        str{1} = ['model: loaded'];
    elseif handles.present.model == 2
        str{1} = ['model: calculated'];
    end    
    str{2} = ['model type: ' upper(handles.data.model.type)];
    scal = handles.data.model.settings.pret_type;
    if strcmp(scal,'none')
        set_this = 'none';
    elseif strcmp(scal,'cent')
        set_this = 'mean centering';
    else
        set_this = 'autoscaling';
    end
    str{3} = ['data scaling: ' set_this];
    str{4} = ['kernel: ' handles.data.model.settings.kernel];
    if strcmp(handles.data.model.settings.kernel,'linear')
        str{5} = ['kernel param: ' 'none'];
    else
        str{5} = ['kernel param: ' num2str(handles.data.model.settings.kernelpar)];
    end
    str{6} = ['cost: ' num2str(handles.data.model.settings.C)];
    str{7} = ['support vectors: ' num2str(length(handles.data.model.svind))];
    er = round(handles.data.model.class_param.er*100)/100;
    ner = round(handles.data.model.class_param.ner*100)/100;
    if isnan(handles.data.model.settings.num_comp)
        str{8} = ['not calculated on PCs'];
    else
        set_this = num2str(size(handles.data.model.settings.svind_data_scaled,2));
        str{8} = ['calculated on ' num2str(set_this) ' PCs'];
    end
    str{9} = ['error rate: ' num2str(er)];
    cnt = 10;
    if isstruct(handles.data.model.cv)
        ercv = round(handles.data.model.cv.class_param.er*100)/100;
        cvtype = handles.data.model.cv.settings.cv_type;
        if strcmp(cvtype,'rand')
            cvtype = 'montecarlo';
        elseif strcmp(cvtype,'cont') || strcmp(cvtype,'vene')
            cvtype = 'cv';
        elseif strcmp(cvtype,'boot')
            cvtype = 'bootstrap';
        end
        str{cnt} = ['error rate ' cvtype ': ' num2str(ercv)]; cnt = cnt + 1;
    end
    if isstruct(handles.data.pred)
        if isfield(handles.data.pred,'class_param')
            ertest = round(handles.data.pred.class_param.er*100)/100;
            nertest = round(handles.data.pred.class_param.ner*100)/100;
            str{cnt} = ['error rate test: ' num2str(ertest)]; cnt = cnt + 1;
        end
    end
    set(handles.listbox_model,'String',str);    
end

% ------------------------------------------------------------------------
function disp_tree(handles)
view(handles.data.model.tree,'Mode','graph')

% ------------------------------------------------------------------------
function disp_roc(handles)
[~,col_default] = visualize_colors;
model = handles.data.model;
num_class = max(model.settings.class);
figure
hold on
cnt = 0;
set(gcf,'color','white')
for g=1:num_class
    % roc curve
    cnt = cnt + 1;
    subplot(num_class,2,cnt)
    TPR = model.settings.sn(:,g)';
    FPR = 1 - model.settings.sp(:,g)';
    area(FPR,TPR,'FaceColor',col_default(1,:));
    box on
    xlabel('1 - specificity')
    ylabel('sensitivity')
    % area under ROC curve
    FPRarea = [0 FPR 1 0];
    TPRarea = [0 TPR 0 0];
    AUC = polyarea(FPRarea,TPRarea);
    AUC = round(AUC*100)/100;
    if length(model.labels.class_labels) == 0
        title(['ROC curve - class ' num2str(g) ' (AUC: ' num2str(AUC) ')'])
    else
        title(['ROC curve - ' model.labels.class_labels{g} ' (AUC: ' num2str(AUC) ')'])
    end
    % specificity and sensitivity
    cnt = cnt + 1;
    subplot(num_class,2,cnt)
    hold on;
    plot(model.settings.thr_val(g,2:end-1),model.settings.sn(2:end-1,g)','b')
    plot(model.settings.thr_val(g,2:end-1),model.settings.sp(2:end-1,g)','r')
    axis([min(model.settings.thr_val(g,2:end-1)) max(model.settings.thr_val(g,2:end-1)) 0 1])
    xlabel('threshold')
    ylabel('sn and sp ')
    if length(model.labels.class_labels) == 0
        title(['sensitivity (blue) and specificity (red) - class ' num2str(g)])
    else
        title(['sensitivity (blue) and specificity (red) - ' model.labels.class_labels{g}])
    end  
    hold off
    box on
end
hold off

% ------------------------------------------------------------------------
function disp_eigen(handles)
[~,col_default] = visualize_colors;
exp_var = handles.data.model.expvar;
num_comp = length(exp_var);
figure
subplot(1,2,1)
hold on
bar(exp_var(:,1)*100,'FaceColor',col_default(1,:))
ylim = get(gca, 'YLim');
axis([0.5 (num_comp + 0.5) 0 100])
set(gca,'xtick',[1:num_comp]);
hold off
ylabel('exp var (%)')
xlabel('latent variables')
box on
set(gca,'YGrid','on','GridLineStyle',':')
title('variance on X')
subplot(1,2,2)
hold on
bar(exp_var(:,2)*100,'FaceColor',col_default(1,:))
ylim = get(gca, 'YLim');
axis([0.5 (num_comp + 0.5) 0 100])
set(gca,'xtick',[1:num_comp]);
hold off
ylabel('exp var (%)')
xlabel('latent variables')
box on
set(gca,'YGrid','on','GridLineStyle',':')
title('variance on Y')
box on
set(gcf,'color','white')

% ------------------------------------------------------------------------
function disp_eigen_pca(handles)
[~,col_default] = visualize_colors;
exp_var = handles.data.model.settings.modelpca.exp_var;
eigen = handles.data.model.settings.modelpca.E;
num_comp = length(exp_var);
figure
subplot(1,2,1)
hold on
plot(eigen,'Color',col_default(1,:))
plot(eigen,'o','MarkerSize',6,'MarkerFaceColor','w','MarkerEdgeColor',col_default(1,:))
ylim = get(gca, 'YLim');
axis([0.6 (num_comp + 0.4) ylim(1) ylim(2)])
set(gca,'xtick',[1:num_comp]);
hold off
ylabel('eigenvalues')
xlabel('principal components')
box on
set(gca,'YGrid','on','GridLineStyle',':')
subplot(1,2,2)
hold on
bar(exp_var(:,1)*100,'FaceColor',col_default(1,:))
ylim = get(gca, 'YLim');
axis([0.5 (num_comp + 0.5) 0 100])
set(gca,'xtick',[1:num_comp]);
hold off
ylabel('exp var (%)')
xlabel('principal components')
set(gca,'YGrid','on','GridLineStyle',':')
box on
set(gcf,'color','white')

% ------------------------------------------------------------------------
function disp_eigen_simca(handles)
[~,col_default] = visualize_colors;
for g=1:max(handles.data.model.settings.class)
    eigen{g} = handles.data.model.modelpca{g}.E;
    exp_var{g} = handles.data.model.modelpca{g}.exp_var;
    num_comp{g} = length(exp_var{g});
end
figure
cnt = 0;
for g=1:max(handles.data.model.settings.class)
    cnt = cnt + 1;
    subplot(max(handles.data.model.settings.class),2,cnt)
    hold on
    plot(eigen{g},'Color',col_default(1,:))
    plot(eigen{g},'o','MarkerSize',6,'MarkerFaceColor','w','MarkerEdgeColor',col_default(1,:))
    ylim = get(gca, 'YLim');
    axis([0.6 (num_comp{g} + 0.4) ylim(1) ylim(2)])
    set(gca,'xtick',[1:num_comp{g}]);
    hold off
    ylabel('eigenvalues')
    xlabel(['PCs - class ' num2str(g)])
    box on
    set(gca,'YGrid','on','GridLineStyle',':')
    hold off
    cnt = cnt + 1;
    subplot(max(handles.data.model.settings.class),2,cnt)
    hold on
    bar(exp_var{g}*100,'FaceColor',col_default(1,:))
    ylim = get(gca, 'YLim');
    axis([0.5 (num_comp{g} + 0.5) 0 100])
    set(gca,'xtick',[1:num_comp{g}]);
    hold off
    ylabel('exp var (%)')
    xlabel(['PCs - class ' num2str(g)])
    box on
    set(gca,'YGrid','on','GridLineStyle',':')
    hold off
    set(gcf,'color','white')
end

% ------------------------------------------------------------------------
function plot_ercv(res,model_type)
[~,col_default] = visualize_colors;
num_comp = length(res.er);
figure
set(gcf,'color','white')
if length(find(res.not_ass > 0)) > 0
    subplot(2,1,1)    
end
hold on
plot(res.er,'Color',col_default(1,:))
plot(res.er,'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
ylabel('error rate cv')
ylim = get(gca, 'YLim');
axis([0.6 (num_comp + 0.4) ylim(1) ylim(2)])
set(gca,'xtick',[1:num_comp]);
hold off
if strcmp(model_type,'plsda')
    lab = 'latent variables';
else
    lab = 'principal components';
end
xlabel(lab)
set(gca,'YGrid','on','GridLineStyle',':')
box on
if length(find(res.not_ass > 0)) > 0
    subplot(2,1,2)
    hold on
    plot(res.not_ass,'Color',col_default(1,:))
    plot(res.not_ass,'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
    ylabel('not assigned samples')
    ylim = get(gca, 'YLim');
    axis([0.6 (num_comp + 0.4) ylim(1) ylim(2)])
    set(gca,'xtick',[1:num_comp]);
    hold off
    lab = 'latent variables';
    xlabel(lab)
    set(gca,'YGrid','on','GridLineStyle',':')
    box on
    hold off
end

% ------------------------------------------------------------------------
function plot_ercv_simca(res,type,xvalues,class_labels)
[~,col_default] = visualize_colors;
if strcmp(type,'simca') || strcmp(type,'uneq')
    labaxis = 'principal components';
else
    labaxis = 'smoothing values';
end
num_values = length(xvalues);
num_classes = size(res.er,2);
figure
set(gcf,'color','white')
cnt = 0;
for g = 1:num_classes
    lab_xaxis = labaxis;
    if length(class_labels) == 0
        lab_yaxis = ['class ' num2str(g)];
    else
        lab_yaxis = class_labels{g};
    end
    cnt = cnt + 1;
    subplot(num_classes,2,cnt)
    hold on
    plot(res.er(:,g),'Color',col_default(1,:))
    plot(res.er(:,g),'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
    if cnt == 1
        title(['class error rate in cv'])
    end
    ylabel(lab_yaxis)
    ylim = get(gca, 'YLim');
    axis([0.6 (num_values + 0.4) ylim(1) ylim(2)])
    set(gca,'xtick',[1:num_values]);
    set(gca,'xticklabel',xvalues);
    hold off
    xlabel(lab_xaxis)
    set(gca,'YGrid','on','GridLineStyle',':')
    box on
    
    cnt = cnt + 1;
    subplot(num_classes,2,cnt)
    hold on
    plot(res.sensitivity(:,g),'k')
    plot(res.sensitivity(:,g),'o','MarkerEdgeColor','k','MarkerSize',6,'MarkerFaceColor','k')
    plot(res.specificity(:,g),'k')
    plot(res.specificity(:,g),'o','MarkerEdgeColor','k','MarkerSize',6,'MarkerFaceColor','w')    
    if cnt == 2
        title(['sensitivity (black) and specificity(white) in cv'])
    end
    ylabel(lab_yaxis)
    ylim = get(gca, 'YLim');
    axis([0.6 (num_values + 0.4) ylim(1) ylim(2)])
    set(gca,'xtick',[1:num_values]);
    set(gca,'xticklabel',xvalues);
    hold off
    xlabel(lab_xaxis)
    set(gca,'YGrid','on','GridLineStyle',':')
    box on
end

% ------------------------------------------------------------------------
function plot_ercv_knn(res)
[~,col_default] = visualize_colors;
num_k = length(res.er);
figure
set(gcf,'color','white');
hold on
plot(res.er,'Color',col_default(1,:))
plot(res.er,'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
ylim = get(gca, 'YLim');
axis([0.6 (num_k + 0.4) ylim(1) ylim(2)])
set(gca,'xtick',[1:num_k]);
hold off
ylabel('error rate cv')
lab = 'K values';
xlabel(lab)
set(gca,'YGrid','on','GridLineStyle',':')
box on

% ------------------------------------------------------------------------
function plot_ercv_svm(res)
[~,col_default] = visualize_colors;
for k=1:length(res.cost_seq); cost_labels{k} = res.cost_seq(k); end
if strcmp(res.settings.kernel,'linear')
    num_val = length(res.er);
    figure
    subplot(2,1,1)
    set(gcf,'color','white');
    hold on
    plot(res.er,'Color',col_default(1,:))
    plot(res.er,'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
    ylim = get(gca, 'YLim');
    axis([0.6 (num_val + 0.4) ylim(1) ylim(2)])
    set(gca,'xtick',[1:num_val]);
    set(gca,'xticklabel',cost_labels);
    hold off
    ylabel('error rate cv')
    lab = 'cost values';
    xlabel(lab)
    set(gca,'YGrid','on','GridLineStyle',':')
    box on
    subplot(2,1,2)
    set(gcf,'color','white');
    hold on
    plot(res.average_svind,'Color',col_default(1,:))
    plot(res.average_svind,'o','MarkerEdgeColor',col_default(1,:),'MarkerSize',6,'MarkerFaceColor','w')
    ylim = get(gca, 'YLim');
    axis([0.6 (num_val + 0.4) ylim(1) ylim(2)])
    set(gca,'xtick',[1:num_val]);
    set(gca,'xticklabel',cost_labels);
    hold off
    ylabel('average number of support vectors')
    lab = 'cost values';
    xlabel(lab)
    set(gca,'YGrid','on','GridLineStyle',':')
    box on
else
    for k=1:length(res.kernalparam_seq); param_labels{k} = res.kernalparam_seq(k); end
    [num_cost,num_param] = size(res.er);
    figure
    subplot(2,1,1)
    set(gcf,'color','white');
    hold on
    [C,h] = contourf(res.er,'ShowText','on');
    colormap(autumn);
    clabel(C,h,'FontSize',8,'Color','black');
    ylim = get(gca, 'YLim');
    %axis([0.6 (num_val + 0.4) ylim(1) ylim(2)])
    set(gca,'ytick',[1:num_cost]);
    set(gca,'yticklabel',cost_labels);
    set(gca,'xtick',[1:num_param]);
    set(gca,'xticklabel',param_labels);    
    hold off
    xlabel('kernel parameter')
    title('error rate cv')
    lab = 'cost values';
    ylabel(lab)
    set(gca,'YGrid','on','GridLineStyle',':')
    box on
    subplot(2,1,2)
    set(gcf,'color','white');
    hold on
    [C,h] = contourf(res.average_svind,'ShowText','on');
    colormap(autumn);
    clabel(C,h,'FontSize',8,'Color','black');
    ylim = get(gca, 'YLim');
    %axis([0.6 (num_val + 0.4) ylim(1) ylim(2)])
    set(gca,'ytick',[1:num_cost]);
    set(gca,'yticklabel',cost_labels);
    set(gca,'xtick',[1:num_param]);
    set(gca,'xticklabel',param_labels);      
    hold off
    xlabel('kernel parameter')
    title('average number of support vectors')
    lab = 'cost values';
    ylabel(lab)
    set(gca,'YGrid','on','GridLineStyle',':')
    box on
end

% ------------------------------------------------------------------------
function handles = predict_samples(handles)
% check data and model size
if size(handles.data.model.settings.raw_data,2) == size(handles.data.X,2)
    errortype = 'none';
else
    errortype = ['mismatch in the number of variables: data have ' num2str(size(handles.data.X,2)) ...
                 ' variables, but model was calculated with ' num2str(size(handles.data.model.settings.raw_data,2)) ' variables'];
end
if strcmp(errortype,'none')
    if strcmp(handles.data.model.type,'lda') || strcmp(handles.data.model.type,'qda') || strcmp(handles.data.model.type,'pcalda') || strcmp(handles.data.model.type,'pcaqda')
        pred = dapred(handles.data.X,handles.data.model);
    elseif strcmp(handles.data.model.type,'cart')
        pred = cartpred(handles.data.X,handles.data.model);
    elseif strcmp(handles.data.model.type,'plsda')
        pred = plsdapred(handles.data.X,handles.data.model);
    elseif strcmp(handles.data.model.type,'simca')
        pred = simcapred(handles.data.X,handles.data.model);
    elseif strcmp(handles.data.model.type,'uneq')
        pred = uneqpred(handles.data.X,handles.data.model);
    elseif strcmp(handles.data.model.type,'knn')
        if length(handles.data.model.labels.class_labels) == 0
            class_to_fit = handles.data.model.settings.class;
        else
            class_to_fit = handles.data.model.settings.class_string;
        end
        pred = knnpred(handles.data.X,handles.data.model.settings.raw_data,class_to_fit,handles.data.model.settings.K,handles.data.model.settings.dist_type,handles.data.model.settings.pret_type);
    elseif strcmp(handles.data.model.type,'pf')
        pred = potpred(handles.data.X,handles.data.model);
    elseif strcmp(handles.data.model.type,'svm')
        pred = svmpred(handles.data.X,handles.data.model);
    end
    handles.present.pred = 1;
    handles.data.pred = pred;
    handles.data.pred.X = handles.data.X;
    if handles.present.sample_labels == 1
        handles.data.pred.sample_labels = handles.data.sample_labels;
    else
        for k=1:size(handles.data.X,1)
            handles.data.pred.sample_labels{k} = ['P' num2str(k)];
        end
        handles.data.pred.sample_labels = handles.data.pred.sample_labels';
    end
    if handles.present.class == 1
        handles.data.pred.class = handles.data.class;
        handles.data.pred.class_param = calc_class_param(handles.data.pred.class_pred,handles.data.pred.class);
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
if handles.present.class
    handles.data.class = handles.data.class(samples_in);
    if length(handles.data.class_labels) > 0
        handles.data.class_string = handles.data.class_string(samples_in);
    end
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
handles.present.class = 0;
handles.present.model = 0;  % = 1 is loaded, = 2 is calculated
handles.present.sample_labels = 0;
handles.present.variable_labels = 0;
handles.present.pred = 0;
handles.data.name_class = [];
handles.data.name_data = [];
handles.data.name_model = [];
handles.data.X = [];
handles.data.class = [];
handles.data.class_string = {};
handles.data.class_labels = {};
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
function handles = reset_class(handles)
handles.present.class = 0;
handles.data.name_class = [];
handles.data.class = [];
handles.data.class_string = {};
handles.data.class_labels = {};

% ------------------------------------------------------------------------
function handles = reset_model(handles)
handles.present.model = 0;
handles.present.pred = 0;
handles.data.name_model = [];
handles.data.model = [];
handles.data.pred = [];

% ------------------------------------------------------------------------
function err_cv = check_cv_err(class,cv_type,cv_groups)
nobj = length(class);
err_cv = 0;
obj_in_block = fix(nobj/cv_groups);
left_over = mod(nobj,cv_groups);
st = 1;
en = obj_in_block;
for i=1:cv_groups
    % prepares objects
    in = ones(nobj,1);
    if strcmp(cv_type,'vene')
        out = [i:cv_groups:nobj];
    else % contiguous blocks
        if left_over == 0
            out = [st:en];
            st =  st + obj_in_block;  en = en + obj_in_block;
        else
            if i < cv_groups - left_over
                out = [st:en];
                st =  st + obj_in_block;  en = en + obj_in_block;
            elseif i < cv_groups
                out = [st:en + 1];
                st =  st + obj_in_block + 1;  en = en + obj_in_block + 1;
            else
                out = [st:nobj];
            end
        end
    end
    in(out) = 0;
    class_training = class(find(in==1));
    class_test = class(find(in==0));
    % check class partition
    cin = [1:max(class)];
    for g = 1:length(cin)
        rep_train = length(find(class_training == g));
        rep_test = length(find(class_test == g));
        if rep_train == 0 || rep_test == 0
            err_cv = 1;
            return
        end
    end
end

% -------------------------------------------------------------------------
function dobound = chkboundaries(model)
dobound = 0;
if size(model.settings.raw_data,2) == 2
    dobound = 1; 
elseif strcmp(model.type,'plsda')
    if size(model.T,2) == 2
        dobound = 1; 
    end
elseif strcmp(model.type,'pcalda') || strcmp(model.type,'pcaqda')
    if size(model.settings.modelpca.T,2) == 2
        dobound = 1; 
    end
elseif strcmp(model.type,'svm') || strcmp(model.type,'pf')
    if isstruct(model.settings.model_pca) && model.settings.num_comp == 2
        dobound = 1; 
    end
end

% ------------------------------------------------------------------------
function handles = enable_disable(handles)
if ~license('test','statistics_toolbox')
    statistics_toolbox = 0;
else
    statistics_toolbox = 1;
end
if handles.present.data == 0
    set(handles.m_file_load_class,'Enable','off');    
    set(handles.m_file_clear_data,'Enable','off');
    set(handles.m_view_data,'Enable','off');
    set(handles.m_view_plot_profiles,'Enable','off');
    set(handles.m_view_plot_univariate,'Enable','off');
    set(handles.m_view_delete,'Enable','off');
    set(handles.m_file_load_sample_labels,'Enable','off');   
    set(handles.m_file_load_variable_labels,'Enable','off');
else
    set(handles.m_file_clear_data,'Enable','on');
    set(handles.m_file_load_class,'Enable','on');
    set(handles.m_view_data,'Enable','on');
    set(handles.m_view_plot_profiles,'Enable','on');
    set(handles.m_view_plot_univariate,'Enable','on');
    set(handles.m_view_delete,'Enable','on');    
    set(handles.m_file_load_sample_labels,'Enable','on');   
    set(handles.m_file_load_variable_labels,'Enable','on');
end
if handles.present.class == 0
    set(handles.m_da,'Enable','off');
    set(handles.m_calculate_da,'Enable','off');
    set(handles.m_calculate_multinormality,'Enable','off');
    set(handles.m_calculate_cart,'Enable','off');
    set(handles.m_calculate_pcada,'Enable','off');   
    set(handles.m_calculate_pcada_comp,'Enable','off');
    set(handles.m_pls,'Enable','off');   
    set(handles.m_calculate_pls,'Enable','off');   
    set(handles.m_calculate_pls_comp,'Enable','off');
    set(handles.m_pf,'Enable','off');   
    set(handles.m_calculate_pf,'Enable','off');   
    set(handles.m_calculate_pf_smoot,'Enable','off');
    set(handles.m_svm,'Enable','off'); 
    set(handles.m_calculate_svm,'Enable','off');   
    set(handles.m_calculate_svm_param,'Enable','off');
    set(handles.m_simca,'Enable','off'); 
    set(handles.m_calculate_simca,'Enable','off');   
    set(handles.m_calculate_simca_comp,'Enable','off');
    set(handles.m_uneq,'Enable','off'); 
    set(handles.m_calculate_uneq,'Enable','off');   
    set(handles.m_calculate_uneq_comp,'Enable','off');
    set(handles.m_knn,'Enable','off');
    set(handles.m_calculate_knn_k,'Enable','off');
    set(handles.m_calculate_knn,'Enable','off');
    set(handles.m_view_class,'Enable','off');
    set(handles.m_view_wilks,'Enable','off');
else
    if statistics_toolbox == 1
        set(handles.m_da,'Enable','on');
        set(handles.m_calculate_da,'Enable','on');
        set(handles.m_calculate_multinormality,'Enable','on');
        set(handles.m_calculate_cart,'Enable','on');
        set(handles.m_calculate_pcada,'Enable','on');   
        set(handles.m_calculate_pcada_comp,'Enable','on');
        set(handles.m_simca,'Enable','on'); 
        set(handles.m_calculate_simca,'Enable','on');   
        set(handles.m_calculate_simca_comp,'Enable','on');
        set(handles.m_uneq,'Enable','on'); 
        set(handles.m_calculate_uneq,'Enable','on');   
        set(handles.m_calculate_uneq_comp,'Enable','on');       
    else
        set(handles.m_da,'Enable','off');
        set(handles.m_calculate_da,'Enable','off');
        set(handles.m_calculate_multinormality,'Enable','off');
        set(handles.m_calculate_cart,'Enable','off');
        set(handles.m_calculate_pcada,'Enable','off');   
        set(handles.m_calculate_pcada_comp,'Enable','off');
        set(handles.m_simca,'Enable','off'); 
        set(handles.m_calculate_simca,'Enable','off');   
        set(handles.m_calculate_simca_comp,'Enable','off');     
        set(handles.m_uneq,'Enable','off'); 
        set(handles.m_calculate_uneq,'Enable','off');   
        set(handles.m_calculate_uneq_comp,'Enable','off');    
    end
    set(handles.m_pls,'Enable','on');   
    set(handles.m_calculate_pls_comp,'Enable','on');
    set(handles.m_calculate_pls,'Enable','on');
    set(handles.m_pf,'Enable','on');
    set(handles.m_calculate_pf,'Enable','on');   
    set(handles.m_calculate_pf_smoot,'Enable','on');
    if max(handles.data.class) == 2 && statistics_toolbox == 1
        set(handles.m_svm,'Enable','on');
        set(handles.m_calculate_svm,'Enable','on');
        set(handles.m_calculate_svm_param,'Enable','on');
    else
        set(handles.m_svm,'Enable','off');
        set(handles.m_calculate_svm,'Enable','off');
        set(handles.m_calculate_svm_param,'Enable','off');        
    end
    set(handles.m_knn,'Enable','on');
    set(handles.m_calculate_knn_k,'Enable','on');
    set(handles.m_calculate_knn,'Enable','on');
    set(handles.m_view_class,'Enable','on');
    set(handles.m_view_wilks,'Enable','on');
end
if handles.present.model == 0
    set(handles.m_file_save_model,'Enable','off');
    set(handles.m_file_clear_model,'Enable','off');
    set(handles.m_results_view_class,'Enable','off');
    set(handles.m_results_view_boundaries,'Enable','off');
    set(handles.m_results_da,'Enable','off');
    set(handles.m_results_view_canonical_scores,'Enable','off');
    set(handles.m_results_view_canonical_loadings,'Enable','off');
    set(handles.m_results_view_cart,'Enable','off');
    set(handles.m_results_eigen_pls,'Enable','off');
    set(handles.m_results_pls,'Enable','off');
    set(handles.m_results_view_plsda_scores,'Enable','off');
    set(handles.m_results_view_plsda_loadings,'Enable','off');
    set(handles.m_results_eigen_simca,'Enable','off');
    set(handles.m_results_simca,'Enable','off');
    set(handles.m_results_view_simca_scores,'Enable','off');
    set(handles.m_results_view_simca_loadings,'Enable','off');
    set(handles.m_results_view_roc,'Enable','off');
    set(handles.m_results_view_roc_simca,'Enable','off');    
    set(handles.m_results_eigen_uneq,'Enable','off');
    set(handles.m_results_uneq,'Enable','off');
    set(handles.m_results_view_uneq_scores,'Enable','off');
    set(handles.m_results_view_uneq_loadings,'Enable','off');
    set(handles.m_results_view_roc_uneq,'Enable','off');  
    set(handles.m_results_view_pcada_scores,'Enable','off');
    set(handles.m_results_view_pcada_loadings,'Enable','off');
    set(handles.m_results_eigen_pcada,'Enable','off');
    set(handles.m_results_view_pf,'Enable','off');
    set(handles.m_results_view_svm,'Enable','off');
else
    set(handles.m_file_clear_model,'Enable','on');   
    set(handles.m_file_save_model,'Enable','on');
    set(handles.m_results_view_class,'Enable','on');
    dobound = chkboundaries(handles.data.model);
    if dobound
        set(handles.m_results_view_boundaries,'Enable','on');
    else
        set(handles.m_results_view_boundaries,'Enable','off');
    end
    if strcmp(handles.data.model.type,'qda') || strcmp(handles.data.model.type,'knn')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
    elseif strcmp(handles.data.model.type,'lda')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','on');
        set(handles.m_results_view_canonical_scores,'Enable','on');
        set(handles.m_results_view_canonical_loadings,'Enable','on');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
    elseif strcmp(handles.data.model.type,'cart')
        set(handles.m_results_view_cart,'Enable','on');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
    elseif strcmp(handles.data.model.type,'plsda')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','on');
        set(handles.m_results_pls,'Enable','on');
        set(handles.m_results_view_plsda_scores,'Enable','on');
        set(handles.m_results_view_plsda_loadings,'Enable','on');
        set(handles.m_results_view_roc,'Enable','on');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
    elseif strcmp(handles.data.model.type,'pcalda')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','on');
        set(handles.m_results_view_canonical_scores,'Enable','on');
        set(handles.m_results_view_canonical_loadings,'Enable','on');
        set(handles.m_results_view_pcada_scores,'Enable','on');
        set(handles.m_results_view_pcada_loadings,'Enable','on');
        set(handles.m_results_eigen_pcada,'Enable','on');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
    elseif strcmp(handles.data.model.type,'pcaqda')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','on');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','on');
        set(handles.m_results_view_pcada_loadings,'Enable','on');
        set(handles.m_results_eigen_pcada,'Enable','on');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
    elseif strcmp(handles.data.model.type,'simca')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');     
        if ~isnan(handles.data.model.settings.thr(1))
            set(handles.m_results_view_roc_simca,'Enable','on');
        else
            set(handles.m_results_view_roc_simca,'Enable','off');
        end
        set(handles.m_results_eigen_simca,'Enable','on');
        set(handles.m_results_simca,'Enable','on');
        set(handles.m_results_view_simca_scores,'Enable','on');
        set(handles.m_results_view_simca_loadings,'Enable','on');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
    elseif strcmp(handles.data.model.type,'uneq')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');     
        if ~isnan(handles.data.model.settings.thr(1))
            set(handles.m_results_view_roc_uneq,'Enable','on');
        else
            set(handles.m_results_view_roc_uneq,'Enable','off');
        end
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_uneq,'Enable','on');
        set(handles.m_results_view_uneq_scores,'Enable','on');
        set(handles.m_results_view_uneq_loadings,'Enable','on');
        set(handles.m_results_eigen_uneq,'Enable','on');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','off');
    elseif strcmp(handles.data.model.type,'pf')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','on');
        set(handles.m_results_view_svm,'Enable','off');
    elseif strcmp(handles.data.model.type,'svm')
        set(handles.m_results_view_cart,'Enable','off');
        set(handles.m_results_eigen_pls,'Enable','off');
        set(handles.m_results_pls,'Enable','off');
        set(handles.m_results_view_plsda_scores,'Enable','off');
        set(handles.m_results_view_plsda_loadings,'Enable','off');
        set(handles.m_results_eigen_simca,'Enable','off');
        set(handles.m_results_simca,'Enable','off');
        set(handles.m_results_view_simca_scores,'Enable','off');
        set(handles.m_results_view_simca_loadings,'Enable','off');
        set(handles.m_results_view_roc,'Enable','off');
        set(handles.m_results_view_roc_simca,'Enable','off');
        set(handles.m_results_uneq,'Enable','off');
        set(handles.m_results_view_uneq_scores,'Enable','off');
        set(handles.m_results_view_uneq_loadings,'Enable','off');
        set(handles.m_results_view_roc_uneq,'Enable','off');
        set(handles.m_results_eigen_uneq,'Enable','off');
        set(handles.m_results_da,'Enable','off');
        set(handles.m_results_view_canonical_scores,'Enable','off');
        set(handles.m_results_view_canonical_loadings,'Enable','off');
        set(handles.m_results_view_pcada_scores,'Enable','off');
        set(handles.m_results_view_pcada_loadings,'Enable','off');
        set(handles.m_results_eigen_pcada,'Enable','off');
        set(handles.m_results_view_pf,'Enable','off');
        set(handles.m_results_view_svm,'Enable','on');
    end
end
if handles.present.pred == 1
    set(handles.m_predict_class,'Enable','on');
    set(handles.m_file_save_pred,'Enable','on');
    if strcmp(handles.data.model.type,'plsda') || strcmp(handles.data.model.type,'pcaqda') ...
            || strcmp(handles.data.model.type,'pcalda') || strcmp(handles.data.model.type,'simca')...
            || strcmp(handles.data.model.type,'uneq') || strcmp(handles.data.model.type,'lda')...
            || strcmp(handles.data.model.type,'pf') || strcmp(handles.data.model.type,'svm')
        set(handles.m_predict_samples_view,'Enable','on');
    else
        set(handles.m_predict_samples_view,'Enable','off');
    end
else
    set(handles.m_file_save_pred,'Enable','off');
    set(handles.m_predict_class,'Enable','off');
    set(handles.m_predict_samples_view,'Enable','off');
end
if handles.present.pred == 1 && handles.present.class == 1 && isfield(handles.data.pred,'class_param')
    set(handles.m_predict_results,'Enable','on');
else
    set(handles.m_predict_results,'Enable','off');
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
