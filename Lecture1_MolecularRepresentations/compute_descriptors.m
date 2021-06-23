function [descriptors, labels] = compute_descriptors(smiles)
% insert description of the code function here
% describe inputs and outputs

nDB = []; % number of double bonds
nO = []; % number of oxygen atoms
nCl = [];  % number of chlorine atoms
nC = []; % number of carbon atoms

descriptors = [];
labels = {'nDB' 'nO' 'nCl' 'nC'};

end