function ga_plot(best_chrom,best_resp,pred_resp,runs,num_windows,r,var_selected,num_var)

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

if nargin < 7
    var_selected = [];
    num_var = [];
end
if size(best_chrom,1) > 1
    xin = sum(best_chrom)/runs;    
else
    xin = best_chrom/runs;
end
[col_ass,col_default] = visualize_colors;
figure(1)
subplot(2,1,1)
cla
hold on
line([0 size(best_chrom,2)+1],[0.25 0.25],'Color',[0.753 0.753 0.753],'LineStyle',':')
line([0 size(best_chrom,2)+1],[0.50 0.50],'Color',[0.753 0.753 0.753],'LineStyle',':')
line([0 size(best_chrom,2)+1],[0.75 0.75],'Color',[0.753 0.753 0.753],'LineStyle',':')
bar(xin,'FaceColor',col_default(1,:),'EdgeColor','k');
if length(var_selected) > 0
    if num_windows > 1 % windows
        window_size = floor(num_var/num_windows);
        W = [1:window_size:num_var];
        W = W(1:num_windows);
        F = []; cnt = 0;
        for k=1:length(var_selected)
            % find just the forst variable of the window
            w = find(W == var_selected(k));
            if length(w) > 0
                cnt = cnt + 1;
                F(cnt) = w;
            end
        end
        var_selected = unique(F);
    end
    xintmp = zeros(length(xin),1);
    xintmp(var_selected) = xin(var_selected);
    bar(xintmp,'FaceColor',col_ass(3,:),'EdgeColor','k');
end
hold off
set(gca,'YTick',[0.25 0.50 0.75])
axis([0 size(best_chrom,2)+1 0 1])
set(gcf,'color','white'); 
box on;
title(['after ' num2str(r) ' runs']); 
if num_windows == 1
    xlabel('variables')
else
    xlabel('windows (intervals of variables)')
end
if length(xin) < 50
    set(gca,'XTick',[1:length(xin)])
else
    step = round(length(xin)/10);
    set(gca,'XTick',[1:step:length(xin)])
end
ylabel('frequency of selection')
drawnow
subplot(2,1,2)
cla
hold on
plot(best_resp,'ok');
plot(pred_resp,'.r');
m = min([best_resp pred_resp]);
M = max([best_resp pred_resp]);
R = M - m;
if R > 0
    m = m - R/10;
    M = M + R/10;
else
    m = 0;
    M = 1;
end
if m > 0.85; m = 0.85; end
axis([0.5 runs+0.5 m M])
line([0.5 runs+0.5],[mean(best_resp) mean(best_resp)],'Color','k','LineStyle',':')
line([0.5 runs+0.5],[mean(pred_resp) mean(pred_resp)],'Color','r','LineStyle',':')
set(gcf,'color','white'); 
box on;
xlabel('runs')
if sum(find(isnan(pred_resp))) > 0
    ylabel(['R2cv'])    
else
    ylabel(['R2cv (black) and R2test (red)'])
end
hold off
drawnow

