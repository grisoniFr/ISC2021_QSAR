function [descriptors, labels] = compute_count_descriptors_solution(smiles)
% insert description of the code function here
% describe inputs and outputs

nDB = numel(strfind(smiles,"=")); % number of double bonds
nO = numel(strfind(smiles,"O")); % number of oxygen atoms
nCl = numel(strfind(smiles,"Cl"));  % number of chlorine atoms
nC = numel(strfind(smiles,"C"))+numel(strfind(smiles,"c"))-nCl; 
nN = numel(strfind(smiles,"N"))+numel(strfind(smiles,"n")); 

descriptors = [nDB nO nCl nC nN];
labels = {'nDB' 'nO' 'nCl' 'nC' 'nN'};

end