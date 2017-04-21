function posRoomsXYZ = create_room_pattern(N, N1)
% CREATE_ROOM_PATTERN - Get positions of image rooms for a 1x1x1 shoebox room
%
% Usage:
%   posRoomsXYZ = CREATE_ROOM_PATTERN(N)
%   posRoomsXYZ = CREATE_ROOM_PATTERN(Nmin, Nmax)
%
% Input:
%   N               Maximum image source order (minimum defaults to 0)
%   N1, N2          Minimum and maximum image source orders
%
% Output:
%   posRoomsXYZ     Matrix containing positions of image rooms

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.91
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
% Universitaet Oldenburg.
%
% This work is licensed under the
% Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
% License (CC BY-NC-ND 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------


%%

if nargin == 1
    Nmin = 0;
    Nmax = N;
else
    Nmin = min(N, N1);
    Nmax = max(N, N1);
end

if Nmin < 0 || Nmax < 0
    warning('Image source order must be non-negative. An empty matrix is returned.')
    posRoomsXYZ = [];
    return;
end

% number of image rooms in x-y plane
numRoomsXY = 1 + 2*(Nmax + Nmax^2);
posRoomsXY = zeros(numRoomsXY, 3);


%% x-y plane

argpointer = 1;
for n = 1:(Nmax + 1)
    spread = (1 - n):(n - 1);
    posRoomsXY(argpointer:argpointer+2*(n - 1), :) = spreadRoom([(n - Nmax - 1), 0, 0], 2, spread);
    argpointer = argpointer + 2*(n - 1) + 1;
end
for n = 1:Nmax
    spread = (n - Nmax):(Nmax - n);
    posRoomsXY(argpointer:argpointer+2*(Nmax - n), :) = spreadRoom([n, 0, 0], 2, spread);
    argpointer = argpointer + 2*(Nmax - n) + 1;
end

%% expand into z direction

numRoomsXYZ = num_img_src([Nmin, Nmax]);
posRoomsXYZ = zeros(numRoomsXYZ, 3);
argpointer = 1;

for n = 1:numRoomsXY
    Ncurrent = round(norm(posRoomsXY(n, :), 1));
    if Ncurrent < Nmin
        spread = [(Ncurrent - Nmax):(Ncurrent - Nmin), (Nmin - Ncurrent):(Nmax - Ncurrent)];
    else
        spread = (Ncurrent - Nmax):(Nmax - Ncurrent);
    end
    
    posRoomsXYZ(argpointer:(argpointer + length(spread) - 1), :) = ...
        spreadRoom(posRoomsXY(n, :), 3, spread);
    argpointer = argpointer + length(spread);
end

end


function out = spreadRoom(baseRoom, dim, spread)
% Calculate positions of 'spread' neighbour rooms of 'baseRoom' in direction 'dim'.
% If spread = 0, only the position of 'baseRoom' is returned.

num = length(spread);
out = zeros(num, 3);

out(:, dim) = spread;                   % spread
out = out + repmat(baseRoom, num, 1);	% shift

end
