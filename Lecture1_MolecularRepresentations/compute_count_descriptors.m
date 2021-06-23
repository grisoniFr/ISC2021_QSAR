function [descriptors, labels] = compute_count_descriptors(smiles)
% insert description of the code function here
% describe inputs and outputs

nDB = []; % number of double bonds
nO = []; % number of oxygen atoms
nCl = [];  % number of chlorine atoms
nC = []; % number of carbon atoms
nN = []; % number of nitrogen atoms

descriptors = [];
labels = {'nDB' 'nO' 'nCl' 'nC' 'nN'};

end