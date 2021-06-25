function D = compute_distance(x, y, dist_type)

% describe your function here. It is good practice to explain the code
% scopes, and the type/meaning of inputs and outputs

switch dist_type
   case 'euclidean'
      % put your code here
      
   case 'manhattan'
      % put your code here
      
   case 'lagrange'
      % put your code here
      
   otherwise
      disp 'Unknown type of distance selected'
      D = [];
end