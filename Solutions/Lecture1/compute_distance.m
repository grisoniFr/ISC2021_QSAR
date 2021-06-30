function D = compute_distance(x, y, dist_type)

% describe your function here. It is good practice to explain the code
% scopes, and the type/meaning of inputs and outputs

diff = x - y;

switch dist_type
   case 'euclidean'
      square_diff = (diff).^2;
      D = sum(square_diff)^0.5;
   case 'manhattan'
      D = sum(abs(diff));
   case 'lagrange'
       
   otherwise
      disp 'Unknown type of distance selected'
      D = max(abs(diff));
end