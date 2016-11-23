function [Azim,Elev] = GetNearestAngle(az,el,matrix)

% calculate the distance from [az el] to all angles in the matrix
N = length(matrix);
difference = repmat( [az el] , [N 1] ) - matrix;
distance = sum( difference.^2 , 2 );

% get the matrix index of the angle with the smallest distance
[ans0, idx] = min( distance );          % TW: added ans0 for compatibility, 2014-12-02
angles = matrix( idx , : );
Azim = angles(1);
Elev = angles(2);


end