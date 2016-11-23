function ISpattern = createISpattern(N0, N1, discd_directions, discd_dir_ords)
% CREATEISPATTERN - Get positions and other informations of image sources for a 1x1x1 shoebox room
%
% Usage:
%   ISpattern = CREATEISPATTERN(N0, [N1], [discd_direction], [discd_dir_ords])
%
% Input:
%   N0                  Maximum image source order
%   N1                  Minimum image source order (optional, default: 0)
%                       The input parameters N0 and N1 are commutative
%   discd_directions    Directions (indices [-3, -2, -1, +1, +2, +3] <-> [-z, -y, -x, +x, +y, +z]),
%                       for which all image sources will be discarded
%                       (optional parameter, default: empty vector)
%   discd_dir_ords      Orders for which all image sources of specified directions
%                       ('discd_directions') are discarded. Set empty, if all orders (i.e. N0 to N1)
%                       shall be specified. Optional parameter, default: [].
%
% Output:
%   ISpattern   Matrix containing informations about the image sources:
%       columns 1:3     position of image source in coordinates of image rooms
%       columns 4:6     flag indicating if image source position component (x,y,z) within image
%                       room is given by the source position in the actual room (0) or if it is inverted
%                       by the room dimension (x,y,z) (1). This will help for the calculation of the actual
%                       image source positions depending on room dimensions, as well as for later application
%                       of source direction pattern
%       columns 7:12    Number of reflections at wall [-z -y -x +x +y +z]
%       column 13       Image source order

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



if nargin < 4
    discd_dir_ords = [];
    if nargin < 3
        discd_directions = [];
        if nargin < 2
            N1 = 0;
        end
    end
end

if N0 < 0 || N1 < 0
    ISpattern = [];
    return;
end

if isempty(discd_dir_ords)
    discd_dir_ords = min([N0, N1]):max([N0, N1]);
end

roomPattern = createRoomPattern(N0, N1);
numIS = size(roomPattern, 1);

% prealloc:
ISpattern = [roomPattern, zeros(numIS, 9)];

% IS position/direction flags:
% say whether i-th IS component is loacated at position x(i) or boxsize(i)-p(i)
ISpattern(:, 4:6) = mod(ISpattern(:, 1:3), 2);

% number of reflections at walls [-z -y -x] (order: [7 8 9] <-> [-z -y -x]):
ISpattern(:, 9:-1:7) = ...
    floor(abs(ISpattern(:, 1:3)/2)) + min(abs(min(sign(ISpattern(:, 1:3)), 0)), ISpattern(:, 4:6));

% number of reflections at walls [+x +y +z]:
ISpattern(:, 10:12) = ...
    floor(abs(ISpattern(:, 1:3)/2)) + min(abs(max(sign(ISpattern(:, 1:3)), 0)), ISpattern(:, 4:6));

for n = 1:length(discd_directions)
    sgndim = sign(discd_directions(n));
    absdim = abs(discd_directions(n));
    
    idx_discd_direction = sgndim*ISpattern(:, absdim) > 0;
    orders = sum(abs(ISpattern(:, 1:3)), 2);
    idx_idscd_orders = ismember(orders, discd_dir_ords);
    
    % discard all IS of specified direction:
    %ISpattern(idx_discd_direction, :) = [];
    
    % discard only first-order IS of specified direction:
    ISpattern(idx_discd_direction & idx_idscd_orders, :) = [];
end
