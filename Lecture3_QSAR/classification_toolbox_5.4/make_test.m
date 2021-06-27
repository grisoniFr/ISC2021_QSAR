function [X_train,X_test,class_train,class_test,in] = make_test(X,class,perc_in_test)

% select test set samples randomly, maintaining the class proportion
% 
% INPUT:
% X                 dataset [samples x variables]
% class             class numerical vector [samples x 1]
% perc_in_test      percentage of test samples to be selected, 
%                   e.g. perc_in_test=0.25 to select 25% of test samples
%
% OUTPUT:
% X_train           training set [samples_train x p]
% class_train       training class vector [samples_train x 1]
% X_test            test set [samples_test x p]
% class_test        test class vector [samples_test x 1]
% in                binary vector showing training/test sample positions in the
%                   original dataset X. 1: training, 0: test
%
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
% version 5.4 - November 2019
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/

in = ones(size(X,1),1);
num_out = round(size(X,1)*perc_in_test);

for g=1:max(class)
    samples_in_class = length(find(class==g));
    perc_in_class(g) = samples_in_class/size(X,1);
    num_out_in_class(g) = round(num_out*perc_in_class(g));
end

for g=1:max(class)
    out_tot = 0;
    in_class = ones(size(X(find(class==g)),1),1);
    while out_tot < num_out_in_class(g);
        r = ceil(rand*size(X(find(class==g)),1));
        if in_class(r) == 1
            in_class(r) = 0;
            out_tot = out_tot + 1;
        end
    end
    in(find(class==g)) = in_class;
end

X_train = X(find(in==1),:);
X_test  = X(find(in==0),:);
class_train = class(find(in==1));
class_test  = class(find(in==0));

disp(['expected samples out: ' num2str(num_out)])
disp(['total samples out: ' num2str(length(find(in==0)))])
for g=1:max(class)
    disp(['class ' num2str(g) ': percentage in X ' num2str(perc_in_class(g))])
    disp(['class ' num2str(g) ': percentage in X train ' num2str(length(find(class_train==g))/size(X_train,1))])
    disp(['class ' num2str(g) ': percentage in X test  ' num2str(length(find(class_test==g))/size(X_test,1))]) 
end
