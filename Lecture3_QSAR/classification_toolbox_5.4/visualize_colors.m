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
% Ballabio D, Consonni V, (2013) Classification tools in chemistry. Part 1: Linear models. PLS-DA. Analytical Methods, 5, 3790-3798
% 
% Classification toolbox for MATLAB
% version 5.4 - November 2019
% Davide Ballabio
% Milano Chemometrics and QSAR Research Group
% http://www.michem.unimib.it/
  
col_default(1,:) = [0 0.447 0.741]; % default blue for plots

col_ass(1,:)  = [1.0 1.0 1.0]; % white, not assigned
col_ass(2,:)  = [0.5 0.5 1.0];
col_ass(3,:)  = [1.0 0.5 0.5];
col_ass(4,:)  = [0.5 1.0 0.5];   
col_ass(5,:) = [0.96551724137931 0.620689655172414 0.862068965517241];
col_ass(6,:) = [1 0.103448275862069 0.724137931034483];
col_ass(7,:) = [1 0.827586206896552 0];
col_ass(8,:) = [0 0.344827586206897 0];
col_ass(9,:) = [0.517241379310345 0.517241379310345 1];
col_ass(10,:) = [0.620689655172414 0.310344827586207 0.275862068965517];
col_ass(11,:) = [0 1 0.758620689655172];
col_ass(12,:) = [0 0.517241379310345 0.586206896551724];
col_ass(13,:) = [0 0 0.482758620689655];
col_ass(14,:) = [0.586206896551724 0.827586206896552 0.310344827586207];
col_ass(15,:) = [0 0 0.172413793103448];
col_ass(16,:) = [0.827586206896552 0.0689655172413793 1];
col_ass(17,:) = [0.482758620689655 0.103448275862069 0.413793103448276];
col_ass(18,:) = [0.96551724137931 0.0689655172413793 0.379310344827586];
col_ass(19,:) = [1 0.758620689655172 0.517241379310345];
col_ass(20,:) = [0.137931034482759 0.137931034482759 0.0344827586206897];
col_ass(21,:) = [0.551724137931035 0.655172413793103 0.482758620689655];



