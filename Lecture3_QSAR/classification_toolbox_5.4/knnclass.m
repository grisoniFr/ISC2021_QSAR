function class_calc = knnclass(neighbors_class,neighbors_distance,num_class)

% find a class on the basis of K neighbors
% 
% This is an internal routine of the toolbox.
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

for g = 1:num_class
    freq(g) = length(find(neighbors_class == g));
end
unique_class = find(freq == max(freq));
if length(unique_class) == 1
    [M,class_calc] = max(freq);
else
    mean_dist = ones(num_class,1).*max(neighbors_distance);
    for g = 1:length(unique_class)
        in = find(neighbors_class == unique_class(g));
        mean_dist(unique_class(g)) = mean(neighbors_distance(in));
    end
    [m,class_calc] = min(mean_dist);
end
