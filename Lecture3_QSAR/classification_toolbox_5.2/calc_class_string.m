function [class_output,class_labels] = calc_class_string(class,class_labels)

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

if iscell(class)
    if nargin > 1
        % convert strings (of a cell array) to numbers, given a class label
        class_output = zeros(length(class),1);
        for k=1:length(class); if isnumeric(class{k}); class{k} = num2str(class{k}); end; end
        for g=1:length(class_labels)
            w = strcmpi(class_labels{g},strtrim(class));
            class_output(w) = g;
        end
    else
        % convert strings (of a cell array) to numbers
        for k=1:length(class); if isnumeric(class{k}); class{k} = num2str(class{k}); end; end
        class_labels{1} = strtrim(class{1});
        cnt_class = 1;
        for k=1:length(class)
            w = strcmpi(strtrim(class{k}),class_labels);
            if w == 0
                cnt_class = cnt_class + 1;
                class_labels{cnt_class} = strtrim(class{k});
            end
        end
        class_output = zeros(length(class),1);
        for g=1:length(class_labels)
            w = strcmpi(class_labels{g},strtrim(class));
            class_output(w) = g;
        end
    end
else
    % convert numbers to strings
    for k=1:length(class)
        if class(k) > 0 && class(k) <= length(class_labels)
            class_output{k,1} = class_labels{class(k)};
        elseif class(k) == 0
            class_output{k,1} = 'not assigned';
        else
            class_output{k,1} = 'undefined';
        end
    end
end