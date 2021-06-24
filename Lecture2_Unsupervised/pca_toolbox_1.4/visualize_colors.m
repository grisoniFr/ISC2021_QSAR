function [col_ass,col_default] = visualize_colors

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

col_ass(1,:)  = [1.0 1.0 1.0];   % white, not assigned
col_ass(2,:)  = [0.5 0.5 1.0];
col_ass(3,:)  = [1.0 0.5 0.5];
col_ass(4,:)  = [0.5 1.0 0.5];   
col_ass(5,:)  = [1.0 1.0 0.5];
col_ass(6,:)  = [0.6 0.6 0.6];
col_ass(7,:)  = [1.0 0.7 1.0];
col_ass(8,:)  = [0.5 1.0 1.0];   
col_ass(9,:)  = [0.7 0.7 1.0];   
col_ass(10,:) = [0.0 0.5 1.0];
col_ass(11,:) = [0.8 0.8 0.8];
col_default(1,:) = [0 0.447 0.741]; % default blue for plots