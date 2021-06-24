function Xsel = ga_windows(X,var_in,num_windows)

% This is an internal routine of the toolbox.
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

window_size = floor(size(X,2)/num_windows);
W = [1:window_size:size(X,2)];
W = W(1:num_windows);
Xsel = [];
where = zeros(num_windows,1);
where(var_in) = 1;
for k=1:length(W)
    if where(k) == 1
        if k < length(W)
            in = W(k):W(k+1)-1;
        else
            in = W(k):size(X,2);
        end
        Xsel = [Xsel X(:,in)];
    end
end
