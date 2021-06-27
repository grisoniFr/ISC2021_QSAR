function settings = backpropagationsettings(num_hidden_neurons,learning_rate)

% define network settings for Backpropagation Neural Networks (BPNN)
%
% settings = backpropagationsettings(num_hidden_neurons,learning_rate)
%
% INPUT:            
% num_hidden_neurons    number of hidden neurons in each hidden layer;
%                       e.g. num_hidden_neurons = 4 to have 1 hidden layer with 4 neurons, 
%                       num_hidden_neurons = [4 10 7] to have 3 hidden layers with 4, 10 and 7 neurons respectively
% learning_rate         learning rate, e.g. learning_rate = 0.01, the learning rate defines the size of the weight changes during training
%
% OUTPUT:
% settings is a structure containing the following fields:
% num_hidden_neurons	see function inputs
% learning_rate         see function inputs
% alpha                 momentum term, default value 0.5; alpha causes opposing components of the step at successive positions to be cancelled
%                       and reinforcing components to be enhanced. This allows acceleration across long regions of shallow but fairly constant gradient and escape
%                       from local minimum              
% iter                  number of iterations, default value 1000;
% assignation_type      type of asignation
%                       'thr' (default): a threshold is calculated with an AUC approach over the predicted outputs, samples can be not classified
%                       'max': samples are classified to the class corresponding to the maximum predicted output
% doplot                defines if the error plot  is shown during training(2), at the end of training (1, default) or not (0)
%                       note that showing the error plot can significantly increase the computational time
%
% RELATED ROUTINES:
% backpropagationfit        fit Backpropagation Neural Networks (BPNN)
% backpropagationpred       prediction of classes of new samples with Backpropagation Neural Networks (BPNN)
% backpropagationcv         cross-validatation of Backpropagation Neural Networks (BPNN)
% class_gui                 main routine to open the graphical interface
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

settings.num_hidden_neurons = num_hidden_neurons;
settings.learning_rate = learning_rate;
settings.alpha = 0.5;
settings.iter = 1000;
settings.assignation_type = 'thr';                           
settings.doplot = 1;
end
