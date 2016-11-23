function posRoomsXYZ = createRoomPattern(N, N1)
% CREATEROOMPATTERN - Get positions of image rooms for a 1x1x1 shoebox room
%
% Usage:
%   posRoomsXYZ = CREATEROOMPATTERN(N, [N1])
%
% Input:
%   N               maximum image source order
%   N1              minimum image source order (optional, default: 0)
% The input parameters N and N1 are commutative.
%
% Output:
%   posRoomsXYZ     Matrix containing positions of image rooms

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.90
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2016, Torben Wendt, Steven van de Par, Stephan Ewert,
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
    N1 = 0;
end

if N1 < 0 || N < 0
    warning('Image source order must be non-negative. An empty matrix is returned.')
    posRoomsXYZ = [];
    return;
end

% input parameters shall be commutative:
if N < N1
    NN = [N, N1];
    N = NN(2);
    N1 = NN(1);
end

% number of image rooms in x-y plane
numRoomsXY = 1 + 2*(N + N^2);
posRoomsXY = zeros(numRoomsXY, 3);


%% x-y plane

argpointer = 1;
for n = 1:(N + 1)
    spread = (1 - n):(n - 1);
    posRoomsXY(argpointer:argpointer+2*(n - 1), :) = spreadRoom([(n - N - 1), 0, 0], 2, spread);
    argpointer = argpointer + 2*(n - 1) + 1;
end
for n = 1:N
    spread = (n - N):(N - n);
    posRoomsXY(argpointer:argpointer+2*(N - n), :) = spreadRoom([n, 0, 0], 2, spread);
    argpointer = argpointer + 2*(N - n) + 1;
end

%% expand into z direction

numRoomsXYZ = num_img_src([N1, N]);
posRoomsXYZ = zeros(numRoomsXYZ, 3);
argpointer = 1;

for n = 1:numRoomsXY
    Ncurrent = round(norm(posRoomsXY(n, :), 1));
    if Ncurrent < N1
        spread = [(Ncurrent - N):(Ncurrent - N1), (N1 - Ncurrent):(N - Ncurrent)];
    else
        spread = (Ncurrent - N):(N - Ncurrent);
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
